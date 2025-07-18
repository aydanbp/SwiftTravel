// TFLAPIViewModel.swift

import Foundation
import CoreLocation
import SwiftUI

@MainActor
class TFLAPIViewModel: ObservableObject {
    @Published var scheduel : [TFLAPITEST] = []

    // The user has named this function `loadSpecificData`
    func loadSpecificData(naptanCode: String) async {
        
        // 1. Check for a valid Naptan code first.
        guard naptanCode != "0" else {
            print("Skipping API call for invalid naptanCode: \(naptanCode)")
            self.scheduel = [] // Ensure schedule is empty
            return
        }

        // 2. Safely create the URL
        guard let url = URL(string: "https://api.tfl.gov.uk/StopPoint/\(naptanCode)/Arrivals") else {
            print("Error: Could not create a valid URL with naptanCode: \(naptanCode)")
            return
        }
        
        // 3. Make the async call
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let arrivals = try JSONDecoder().decode([TFLAPITEST].self, from: data)
            // Sort by arrival time
            self.scheduel = arrivals.sorted(by: { $0.timeToStation < $1.timeToStation })
        } catch {
            // Provide a more specific error message
            print("Error fetching or decoding TFL arrivals for naptanCode \(naptanCode): \(error)")
            self.scheduel = [] // Clear schedule on error
        }
    }
}
