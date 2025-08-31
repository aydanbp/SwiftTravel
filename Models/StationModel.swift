//
//  Station.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import Foundation
import MapKit


class Station : Codable, Identifiable, Equatable {
    
    var id = UUID()
    let stationName: String
    var coordinates: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    let latitude: Double
    let longitude: Double
    let type : String

    static func == (lhs: Station, rhs: Station) -> Bool {
        // Compare the unique identifier or a key property
        // The stationName is a good candidate for this.
        return lhs.stationName == rhs.stationName
    }
    
    private enum CodingKeys : String, CodingKey {
        case stationName
        case latitude = "lat"
        case longitude = "long"
        case type = "serviceType"
    }

    init(stationName: String, latitude: Double, longitude: Double, type: String) {
        self.stationName = stationName
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
    }

}
