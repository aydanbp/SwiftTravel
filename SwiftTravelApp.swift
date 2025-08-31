//
//  SwiftTravelApp.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import SwiftUI
import SwiftData
import CoreLocation

@main
struct SwiftTravelApp: App {


    var body: some Scene {
        let routeSettings = routeSettings()
        let stationSettings = stationSettings()
        WindowGroup {
            MainTabView()
                .environmentObject(routeSettings)
                .environmentObject(stationSettings)
                .environmentObject(stationPassData())
        }
        
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
    @Published var sortTypes = ["Time", "Line"]
    @Published var showStations = ["All", "TfL", "National Rail", "Tram", "None"]
    @Published var showNodes : showStationNodes = .all

}
class stationPassData: ObservableObject {
    @Published var activeString : String = ""
    @Published var searchResults : [Station] = []
}
enum showStationNodes: String, CaseIterable {
    case all
    case tfl
    case nationalRail
    case tram
    case none
}
