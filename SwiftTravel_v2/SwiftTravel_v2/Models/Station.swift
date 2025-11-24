//
//  Station.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 31/08/2025.
//
import MapKit
import SwiftData

@Model
final class TrainStation: Codable, Identifiable {
    @Attribute(.unique) var id: String
    
    
    var stationName: String
    var latitude: Double
    var longitude: Double
    
    // Properties from  old StationTrainModel
    var type: String
    var crsCode: String
    var natpanCode: String?
    var FareZone: String?
    var Wifi: Bool?
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    
    init(id: String, stationName: String, latitude: Double, longitude: Double, type: String, crsCode: String, natpanCode: String? = nil, FareZone: String? = nil, Wifi: Bool? = false) {
        self.id = id
        self.stationName = stationName
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
        self.crsCode = crsCode
        self.natpanCode = natpanCode
        self.FareZone = FareZone
        self.Wifi = Wifi
    }
    
    enum CodingKeys: String, CodingKey {
        case stationName, crsCode, natpanCode, FareZone, Wifi
        case latitude = "lat"      // Use "lat" for latitude
        case longitude = "long"    // Use "long" for longitude
        case type = "serviceType"
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let stationName = try container.decode(String.self, forKey: .stationName)
        let type = try container.decode(String.self, forKey: .type)
        let crsCode = try container.decode(String.self, forKey: .crsCode)
        let natpanCode = try container.decodeIfPresent(String.self, forKey: .natpanCode)
        let FareZone = try container.decodeIfPresent(String.self, forKey: .FareZone)
        let Wifi = try container.decodeIfPresent(Bool.self, forKey: .Wifi)
        
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        
        let id = "\(crsCode)|\(natpanCode ?? "")"
        
        self.init(id: id, stationName: stationName, latitude: latitude, longitude: longitude, type: type, crsCode: crsCode, natpanCode: natpanCode, FareZone: FareZone, Wifi: Wifi)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(stationName, forKey: .stationName)
        try container.encode(type, forKey: .type)
        try container.encode(crsCode, forKey: .crsCode)
        try container.encodeIfPresent(natpanCode, forKey: .natpanCode)
        try container.encodeIfPresent(FareZone, forKey: .FareZone)
        try container.encodeIfPresent(Wifi, forKey: .Wifi)
        
        // Encode latitude and longitude using own separate keys
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}


