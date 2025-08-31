//
//  CustomMapLine.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 24/08/2025.
//

import SwiftUI
import MapKit

func displayRoute(_ route: MapRouteModel, _ priority: Bool) -> some MapContent {

    var routeColour: Color {
        switch route.line {
        case "Transfer", "Walking":
            return .gray
        default:
            return route.colour
        }
    }
    var strokeStyle: StrokeStyle {
        switch route.line {
        case "Transfer", "Walking":
            return StrokeStyle(lineWidth: 3, dash: [5,5])
        default:
            return StrokeStyle(lineWidth: 3)
        }
    }
    return MapPolyline(coordinates: route.locations)
        .stroke(routeColour.opacity(priority ? 0.3 : 1), style: strokeStyle)
        
}
