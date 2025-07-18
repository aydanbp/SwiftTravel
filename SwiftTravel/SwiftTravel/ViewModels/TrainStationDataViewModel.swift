//
//  StationDataViewModel.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import Foundation
import CoreLocation

// Create a class that conforms to ObservableObject
class StationDataViewModel: ObservableObject {
    
    // Use @Published so views can automatically update when this changes
    @Published var stations: [TrainStation] = []
    @Published var londonStations: [TrainStation] = []
    @Published var selectedStation: TrainStation?

    
    func loadData() async {
        guard let url = Bundle.main.url(forResource: "stations", withExtension: "json") else {
            fatalError("stations.json file not found.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let allstations = try JSONDecoder().decode([TrainStation].self, from: data)

            self.stations = allstations
            
            await filterStations()
        } catch {
            // ERROR HANDLING
            print("Error loading or decoding stations.json: \(error)")
        }
    }

    func filterStations() async {
        let londonCenter = CLLocation(latitude: 51.5074, longitude: -0.1278)
        let radius: CLLocationDistance = 27000

        
        let filtered = stations.filter { station in
            
            let stationLocation = CLLocation(latitude: station.latitude, longitude: station.longitude)
            return londonCenter.distance(from: stationLocation) <= radius
        }

        
        await MainActor.run {
            self.londonStations = filtered
        }
    }
}
