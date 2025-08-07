//
//  Station.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import Foundation
import MapKit


class BusStation : Station {
    let natpanCode : String
    let detail : String //towards
    
    
    
    enum CodingKeys : String, CodingKey {
        case stationName
        case latitude = "lat"
        case longitude = "long"
        case natpanCode
        case LinesServed
        case neighbour
        case detail
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.natpanCode = try container.decode(String.self, forKey: .natpanCode)
        self.detail = try container.decode(String.self, forKey: .detail)
        
        try super.init(from: decoder)
    }

}
