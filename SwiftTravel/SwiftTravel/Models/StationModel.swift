//
//  Station.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import Foundation
import MapKit



class Station : Codable, Identifiable {
    
    let stationName: String
    var coordinates: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    let latitude: Double
    let longitude: Double
    let LinesServed : String?
    let neighbour : [Station]?
    let type : String
    
    
    
    enum CodingKeys : String, CodingKey {
        case stationName
        case latitude = "lat"
        case longitude = "long"
        case LinesServed
        case neighbour
        case type = "serviceType"
    }

}
