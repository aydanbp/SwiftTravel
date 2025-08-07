//
//  StatusModel.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 20/07/2025.
//

import Foundation

struct StatusModel: Codable {
    var status: String
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
    }
}
