//
//  Station.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import Foundation
import MapKit
import CoreLocation

struct Route : Codable, Identifiable {
    
    let id = UUID()
    let from : String
    let to : String
    let line : String
    let weight : Int?
    
    private enum CodingKeys : String, CodingKey {
        case from
        case to
        case line
        case weight
    }
}


class Station : Codable, Identifiable {
    
    let stationName: String
    var coordinates: CLLocationCoordinate2D{
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    let latitude: Double
    let longitude: Double
    let type : String

    
    
    enum CodingKeys : String, CodingKey {
        case stationName
        case latitude = "lat"
        case longitude = "long"
        case type = "serviceType"
    }



}
