// TFLAPITEST.swift

import Foundation

struct TFLAPITEST: Codable, Identifiable {
    let id: String
    let lineName: String
    let lineId: String
    let platformName: String
    let direction: String
    let destinationName: String
    let timeToStation: Int // Time in seconds
    
    // Add CodingKeys to handle potential mismatches if needed,
    // though these names match the API response.
    enum CodingKeys: String, CodingKey {
        case id
        case lineName
        case lineId
        case platformName
        case direction
        case destinationName
        case timeToStation
    }
}
