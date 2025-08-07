//
//  StationDataViewModel.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import Foundation
import CoreLocation

@MainActor
class StationDataViewModel: ObservableObject {
    
    @Published var stations: [TrainStation] = []
    @Published var selectedStation: TrainStation?
    @Published var stationLookup : [String: TrainStation] = [:]
    @Published var routes : [Route] = []
    @Published var MapRoutes : [Route] = [] //So map isn't drawing same route twice
    private var possibleRoutes : [String : [Route]] = [:]

    
    func loadData() async {
        await loadStations()
        await loadRoutes()
    }
    private func loadStations() async {
        guard let url = Bundle.main.url(forResource: "stations", withExtension: "json") else {
            fatalError("stations.json file not found.")
        }


        
        do {
            let data = try Data(contentsOf: url)

            let allstations = try JSONDecoder().decode([TrainStation].self, from: data)

            
            self.stations = allstations

            self.stationLookup = Dictionary(uniqueKeysWithValues: allstations.map{($0.uuid, $0)})
            
            
        } catch {
            // ERROR HANDLING
            print("Error loading or decoding stations.json: \(error)")
        }
    }
    private func loadRoutes() async {
        guard let url = Bundle.main.url(forResource: "routes", withExtension: "json") else {
            fatalError("stations.json file not found.")
        }
        do {
            let data = try Data(contentsOf: url)
            let oneWay = try JSONDecoder().decode([Route].self, from: data)
            let reverseWay = oneWay.map {route in
                return Route(from: route.to, to: route.from, line: route.line, weight: route.weight)
            }
            self.MapRoutes = oneWay
            self.routes = oneWay + reverseWay
        } catch{
            print("Error With routes.json")
        }
    }
    private func buildRoutes(){
        for route in routes{
            possibleRoutes[route.from, default: []].append(route)
        }
        
    }
    func findBestRoute(from startCode: String, to endCode: String) -> [Route]? {
        var distances: [String: Int] = [:]
        var previous: [String: Route] = [:]
        var priorityQueue = PriorityQueue<String>(sort: { distances[$0, default: .max] < distances[$1, default: .max] })

        // Initialize distances: 0 for the start, infinity for all others.
        for station in stations {
            distances[station.crsCode] = .max
        }
        distances[startCode] = 0
        
        priorityQueue.enqueue(startCode)

        while let currentCode = priorityQueue.dequeue() {
            // If we've reached the end, we can stop.
            if currentCode == endCode { break }
            
            // Get all routes leaving the current station.
            guard let outgoingRoutes = possibleRoutes[currentCode] else { continue }
            
            for route in outgoingRoutes {
                let newDistance = distances[currentCode, default: .max] + (route.weight ?? 60)
                
                // If we've found a cheaper path to the neighbour, update it.
                if newDistance < distances[route.to, default: .max] {
                    distances[route.to] = newDistance
                    previous[route.to] = route
                    priorityQueue.enqueue(route.to)
                }
            }
        }
        
        // Reconstruct the path by backtracking from the end.
        var path: [Route] = []
        var current = endCode
        while let prevRoute = previous[current] {
            path.insert(prevRoute, at: 0)
            current = prevRoute.from
        }
        
        // If the path starts at our desired start station, we found a valid route.
        return path.first?.from == startCode ? path : nil
    }


}
struct PriorityQueue<T> {
    private var elements: [T] = []
    private let sort: (T, T) -> Bool

    init(sort: @escaping (T, T) -> Bool) {
        self.sort = sort
    }

    var isEmpty: Bool { return elements.isEmpty }
    var count: Int { return elements.count }

    mutating func enqueue(_ element: T) {
        elements.append(element)
        elements.sort(by: sort)
    }

    mutating func dequeue() -> T? {
        return isEmpty ? nil : elements.removeFirst()
    } 
}

