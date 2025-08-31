//
//  mapRouteModel.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 23/08/2025.
//




import SwiftUI
import MapKit


struct DecodableMapRoute: Decodable {
    var line: String
    var comment: String
    var location: [String] // coordinates are initially strings
}

struct MapRouteModel: Identifiable {
    var id: UUID = UUID()
    var line: String
    var comment: String
    var locations: [CLLocationCoordinate2D] //  coordinates are now CLLocationCoordinate2D
    var colour: Color {
        colorFor(line:line)
    }
}


