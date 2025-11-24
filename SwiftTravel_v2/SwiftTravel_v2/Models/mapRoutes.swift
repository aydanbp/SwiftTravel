//
//  mapRoutes.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 31/08/2025.
//
//Watered down version of routes

import SwiftUI
import SwiftData
import MapKit



struct DecodableMapRoute: Decodable {
    var line: String
    var location: [String]
    var type: String
    
    init(line: String, location: [String], type: String) {
        self.line = line
        self.location = location
        self.type = type
    }
}

@Model
class savedMapRoutes: ObservableObject {
    var locations: [String]
    var lines: String
    var type: String
    
    var locationsAsCoordinates: [CLLocationCoordinate2D] {
        return locationExtractor(locations)
    }
    
    var colour: Color {
        colorFor(line: lines)
    }
    
    init(locations: [String], lines: String, type: String) {
        self.locations = locations
        self.lines = lines
        self.type = type
    }
}

