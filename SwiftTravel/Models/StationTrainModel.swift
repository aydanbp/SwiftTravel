//
//  Station.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import Foundation
import MapKit


class TrainStation : Station {
    
    
    let crsCode: String
    let natpanCode : String?
    let FareZone : String?
    let Wifi : Bool?
    
    var uuid: String{
        "\(crsCode)|\(natpanCode ?? "")"
    }
    
    
    
    enum CodingKeys : String, CodingKey {
        case crsCode
        case natpanCode
        case FareZone
        case Wifi

    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all subclass properties
        crsCode = try container.decode(String.self, forKey: .crsCode)
        natpanCode = try container.decode(String.self, forKey: .natpanCode)
        FareZone = try container.decodeIfPresent(String.self, forKey: .FareZone)
        Wifi = try container.decodeIfPresent(Bool.self, forKey: .Wifi)
        
        // Call the superclass's decoder to handle base class properties
        try super.init(from: decoder)
    }

    
}
