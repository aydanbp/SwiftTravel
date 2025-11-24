//
//  DatabaseManager.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 31/08/2025.
//

import MapKit
import SwiftUI
import SwiftData

@MainActor
public class DatabaseManager : ObservableObject {
    private var modelContext : ModelContext
    @Published var isLoading : Bool = false
    @Published var progress = 0.0
    @Published var stationLookup : [String : TrainStation] = [:]
    @Published var selectedRoute : [Route] = []
    @Published var showStationDetails : Bool = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    private func clearDatabase<T: PersistentModel>(for modelType: T.Type) throws {
        try modelContext.delete(model: modelType)
    }
    
    func binAllData() {
        do {
            try clearDatabase(for: TrainStation.self)
            try clearDatabase(for: line.self)
            try clearDatabase(for: Route.self)
            try clearDatabase(for: savedMapRoutes.self)
            try modelContext.save()
            print("✅ All database data has been cleared.")
        } catch {
            print("❌ Error clearing all database data: \(error)")
        }
    }
    func loadAllData() async {
        if isDatabaseEmpty() {
            print("Database is empty, starting import...")
            isLoading = true
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.importStations() }
                group.addTask { await self.importLines() }
                group.addTask { await self.importRoutes() }
                group.addTask { await self.importMapRoutes() }
            }
            
            isLoading = false
            print("Data Sucessfully imported")
            
        } else {
            print("Data already present")
            return
        }

    }
    
    func importStations() async {
        guard let url = URL(string: "https://aydanbp.pythonanywhere.com/DBRetrival?request=stations") else {
            return
        }
        do{
            let (data,_) = try await URLSession.shared.data(from: url)
            let allStations = try JSONDecoder().decode([TrainStation].self, from: data)
            try clearDatabase(for: TrainStation.self)
            self.stationLookup = Dictionary(uniqueKeysWithValues: allStations.map{($0.id, $0)})
            for station in allStations {
                modelContext.insert(station)
            }
            try modelContext.save()
            progress+=25
            print("Stations Sucessfully Imported")
            
        } catch{
            print("Error importing Stations: \(error)")
        }
    }
    
    func importLines() async {
        guard let url = URL(string: "https://aydanbp.pythonanywhere.com/DBRetrival?request=lines") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let allLines = try JSONDecoder().decode([line].self, from: data)
            
            try clearDatabase(for: line.self)
            
            for line in allLines {
                modelContext.insert(line)
            }
            
            try modelContext.save()
            progress+=25
            print("Successfully Imported Lines")
        } catch {
            print("Error Importing Lines: \(error)")
        }
    }
    func importRoutes() async {
        guard let url = URL(string: "https://aydanbp.pythonanywhere.com/DBRetrival?request=routes") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let oneWay = try JSONDecoder().decode([Route].self, from: data)
            
            let reverseWay = oneWay.map { route in
                return Route(from: route.to, to: route.from, line: route.line, weight: route.weight, type: route.type)
            }
            
            try clearDatabase(for: Route.self)
            
            for route in (oneWay + reverseWay) {
                modelContext.insert(route)
            }
            
            try modelContext.save()
            progress+=25
            print("Successfully Imported Full Routes")
        } catch {
            print("Error Importing Full Routes: \(error)")
        }
    }
    
    func importMapRoutes() async {
        guard let url = URL(string: "https://aydanbp.pythonanywhere.com/DBRetrival?request=mapRoutes")
        else {
            print("Error fetching Displayed Routes URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedRoutes = try JSONDecoder().decode([DecodableMapRoute].self, from: data)
            
            try clearDatabase(for: savedMapRoutes.self)
            
            // Restoring the mapping to include the 'type' property.
            let savingRoute = decodedRoutes.map{ decodedRoute in
                return savedMapRoutes(locations: decodedRoute.location, lines: decodedRoute.line, type: decodedRoute.type)
            }
            
            for route in savingRoute {
                modelContext.insert(route)
            }
            
            try modelContext.save()
            progress+=25
            print("✅ Successfully imported and saved map routes.")
            
        } catch {
            print("❌ Error importing map routes: \(error)")
        }
    }
    private func isDatabaseEmpty<T: PersistentModel>(for modelType: T.Type) -> Bool {
       let descriptor = FetchDescriptor<T>()
       do {
           let count = try modelContext.fetchCount(descriptor)
           return count == 0
       } catch {
           print("Failed to fetch count for \(modelType): \(error)")
           return false // Assume not empty to be safe
       }
   }
    func isDatabaseEmpty() -> Bool {
        return isDatabaseEmpty(for: TrainStation.self)
    }
    
}

