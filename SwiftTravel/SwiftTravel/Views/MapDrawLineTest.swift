//
//  MapDrawLineTest.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 28/06/2025.
//

import SwiftUI
import MapKit

struct LineOnMapView: View {
    /// The provided walking route
    let walkingRoute: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 40.836456,longitude: 14.307014),
        CLLocationCoordinate2D(latitude: 40.835654,longitude: 14.304346),
        CLLocationCoordinate2D(latitude: 40.836478,longitude: 14.302593),
        CLLocationCoordinate2D(latitude: 40.836936,longitude: 14.302464)
    ]
    let strokeStyle = StrokeStyle(
        lineWidth: 3,
        lineCap: .round,
        lineJoin: .round,
        dash: [5, 5]
    )
    let gradient = Gradient(colors: [.red, .green, .blue])
    
    var body: some View {
        Map {
            /// The Map Polyline map content object
            MapPolyline(coordinates: walkingRoute)
                .stroke(gradient, style: strokeStyle)
        }
    }
}

#Preview{
    LineOnMapView()
}
