

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
    
    let timeToEventSeconds: Int?
    
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
        case timeToEventSeconds
        case coachCount
    }
}
