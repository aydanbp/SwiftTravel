//
//  ArrivalsModel.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 05/09/2025.
//



import Foundation


struct UnifiedArrivalModel: Codable, Identifiable {
    let id: String
    
    let source: String
    
    let serviceType: String
    
    let stationName: String
    let lineName: String
    let destinationName: String
    let platformName: String
    
    let scheduledTime: String?
    
    let estimatedTime: String?
    
    let timeToStation: Int?
    
    let coachCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case source
        case serviceType
        case stationName
        case lineName
        case destinationName
        case platformName
        case scheduledTime
        case estimatedTime
        case timeToStation
        case coachCount
    }
}
