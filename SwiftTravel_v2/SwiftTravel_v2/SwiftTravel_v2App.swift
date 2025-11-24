//
//  SwiftTravel_v2App.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 31/08/2025.
//

import SwiftUI
import SwiftData

@main
struct SwiftTravelApp: App {
    @StateObject private var databaseManager: DatabaseManager
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var locationManager: LocationManager

    let container: ModelContainer = {
        let schema = Schema([TrainStation.self, Route.self, line.self, savedMapRoutes.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()

    init() {
        let context = container.mainContext
        _databaseManager = StateObject(wrappedValue: DatabaseManager(modelContext: context))
        _locationManager = StateObject(wrappedValue: LocationManager())
    }

    var body: some Scene {
        WindowGroup {
                MainTabView()
                    .environmentObject(databaseManager)
                    .environmentObject(routeSettings())
                    .environmentObject(stationSettings())
                    .environmentObject(stationPassData())
                    .environmentObject(locationManager)
        }
        .modelContainer(container)
    }
}

class routeSettings: ObservableObject {
    @Published var showTfLRoutes: Bool = true
    @Published var showNRRoutes: Bool = true
    @Published var showTramRoutes: Bool = true
    @Published var showTransfers: Bool = true
}

class stationSettings : ObservableObject {
    @Published var nodesDisplayed : String = "All"
    @Published var sortArrivals : String = "Time"
    @Published var sortTypes = ["Time", "Provider"]
    @Published var showStations = ["All", "TfL", "National Rail", "None"]
    @Published var showNodes : showStationNodes = .all

}
class stationPassData: ObservableObject {
    @Published var activeString : String = ""
    @Published var searchResults : [TrainStation] = []
}
enum showStationNodes: String, CaseIterable {
    case all
    case tfl
    case nationalRail
    case tram
    case none
}
