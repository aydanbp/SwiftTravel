//
//  RouteModel.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 10/08/2025.
//


import SwiftUI
import MapKit

struct Route: Codable, Identifiable, Hashable {

    let id = UUID()
    var from: String
    var to: String
    let line: String
    let weight: Int?
    
    // --- Manual Hashable Conformance ---

    static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.from == rhs.from &&
               lhs.to == rhs.to &&
               lhs.line == rhs.line
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(from)
        hasher.combine(to)
        hasher.combine(line)
    }
    

    private enum CodingKeys: String, CodingKey {
        case from
        case to
        case line
        case weight
    }
}
