//
//  StatusModel.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 20/07/2025.
//

import Foundation

struct DisruptionStatus: Codable, Identifiable {
    var id = UUID()
    
    var source: String?
    var statusType: String?
    var descrp: String?
    
    enum CodingKeys: String, CodingKey {
        case source
        case statusType
        case descrp = "description"
    }
}
