//
//  DatabaseViewModel.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 28/08/2025.
//

import Foundation
import MapKit
import SwiftUI

struct AllDataResponse: Decodable {
    let lines: [line]
    let stations: [TrainStation]
    let routes: [Route]
    let mapRoutes: [DecodableMapRoute] // Use the decodable helper struct first
}

@MainActor
class DatabaseViewModel: ObservableObject {
    @Published var TrainLines : [line] = []
    @Published var lineLookup : [String : line] = [:]
    @Published var stations: [TrainStation] = []
    @Published var routes: [Route] = []
    @Published var mapRoutes: [MapRouteModel] = []
    @Published var NRStations: [TrainStation] = []
    @Published var TfLStations: [TrainStation] = []
    @Published var stationLookup : [String: TrainStation] = [:]
    @Published var selectedStation : TrainStation?
    @Published var displayRoutes : [MapRouteModel] = []
    @Published var MapRoutes : [Route] = [] //So map isn't drawing same route twice
    @Published var possibleRoutes : [String : [Route]] = [:]
    
    @Published var shortestPath : [Route]?
    @Published var allPaths : [[Route]] = []
    
    @Published var isLoading = false
    
    func loadAllData() async {
        isLoading = true
        
        await importMapRoutes()
        await importFullRoutes()
        await importStations()
        await importLines()


        
        isLoading = false
    }
    func deleteDatabase() {
        TrainLines.removeAll()
        stations.removeAll()
        mapRoutes.removeAll()
        routes.removeAll()
    }
    func importMapRoutes() async {
        guard let url = URL(string: "https://aydanbp.pythonanywhere.com/DBRetrival?request=mapRoutes")
        else {
            print("Error fetching Displayed Routes URL")
            return
        }
        
        do {
            let (data,_) = try await URLSession.shared.data(from: url)
            let decodedRoutes = try JSONDecoder().decode([DecodableMapRoute].self, from: data)
            
            let finalRoutes = decodedRoutes.map { decodedRoutes in
                let line = decodedRoutes.line
                let comment = decodedRoutes.comment
                
                let locations = decodedRoutes.location.compactMap { coordinateString -> CLLocationCoordinate2D? in
                    let components = coordinateString.split(separator: ",")
                    guard components.count == 2, let latitude = Double(components[0]), let longitude = Double(components[1]) else {
                        return nil
                    }
                    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                return MapRouteModel(line: line, comment: comment, locations: locations)
            }
            displayRoutes = finalRoutes
            
        } catch {
            print ("Error importing map routes: \(error)")
        }
    }
    func importFullRoutes() async {
        guard let url = URL(string: "https://aydanbp.pythonanywhere.com/DBRetrival?request=routes")
        else {
            print("Error fetching Full Routes URL")
            return
        }
        do {
            let (data,_) = try await URLSession.shared.data(from: url)
            let oneWay = try JSONDecoder().decode([Route].self, from: data)
            
            let reverseWay = oneWay.map { route in
                return Route(
                    from: route.to,
                    to: route.from,
                    line: route.line,
                    weight: route.weight)
                
            }
            self.routes = oneWay + reverseWay
        } catch {
            print("Error Importing Full Routes: \(error.localizedDescription)")
        }
        
    }
    func importStations() async {
        guard let url = URL(string: "https://aydanbp.pythonanywhere.com/DBRetrival?request=stations")
        else {
            print("Error fetching URL")
            return
        }
        do {
            let (data,_) = try await URLSession.shared.data(from: url)
            let allStations = try JSONDecoder().decode([TrainStation].self, from: data)
            self.stations = allStations
            self.stationLookup = Dictionary(uniqueKeysWithValues: allStations.map{($0.uuid, $0)})
            self.NRStations = allStations.filter { $0.type == "N" || $0.type == "C" }
            self.TfLStations = allStations.filter { $0.type == "T" || $0.type == "C" }
        } catch {
            print("Error Importing Stations: \(error.localizedDescription)")
        }
    }
    func importLines() async {
        guard let url = URL(string: "https://aydanbp.pythonanywhere.com/DBRetrival?request=lines")
        else {
            print("Error fetching URL")
            return
        }
        do {
            let (data,_) = try await URLSession.shared.data(from: url)
            let allLines = try JSONDecoder().decode([line].self, from: data)
            self.TrainLines = allLines
            self.lineLookup = Dictionary(uniqueKeysWithValues: allLines.map{($0.name, $0)})
        } catch {
            print("Error Importing Lines: \(error.localizedDescription)")
        }

    }
    func fetchURL(request: String) async throws -> URL {
        guard let url = URL(string: "https://aydanbp.pythonanywhere.com/DBRetrival?request=\(request)")
        else {
            print("Error fetching URL")
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        return url

    }
    
    
    func getStatus() async {
        isLoading = true
        // Use a TaskGroup to fetch all statuses concurrently for better performance.
        await withTaskGroup(of: Void.self) { group in
            for line in self.TrainLines {
                group.addTask {
                    // Use URLComponents for safe URL creation
                    guard var components = URLComponents(string: "https://aydanbp.pythonanywhere.com/disruption_api") else {
                        return
                    }
                    components.queryItems = [
                        URLQueryItem(name: "id", value: line.code),
                        URLQueryItem(name: "type", value: line.type)
                    ]

                    guard let url = components.url else {
                        print("Error creating URL for \(line.name)")
                        return
                    }

                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        let disruptions = try JSONDecoder().decode([DisruptionStatus].self, from: data)
                        
                        // Update the status property on the main thread.
                        line.status = disruptions.first
                        
                    } catch {
                        print("Error fetching or decoding status for \(line.name): \(error)")
                    }
                }
            }
        }

        self.TrainLines = self.TrainLines
        isLoading = false
    }
    enum DatabaseRequest {
        case all
        case stations
        case routes
        case map
        
        
    }
}

