//
//  lines.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 31/08/2025.
//

import SwiftData
import SwiftUI

@Model
final class line : Decodable {
    var name : String
    var type : String
    var code : String
    var colourValues : [Int]
    var colour : Color{
        colourRGB(colourValues)
    }
    var status : DisruptionStatus?
    
    enum CodingKeys : String, CodingKey {
        case name
        case colourValues = "colour"
        case type
        case code
    }
    init(name: String, type: String, code: String, colourValues: [Int]) {
        self.name = name
        self.type = type
        self.code = code
        self.colourValues = colourValues
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(String.self, forKey: .type)
        self.code = try container.decode(String.self, forKey: .code)
        self.colourValues = try container.decode([Int].self, forKey: .colourValues)
    }
}

struct DisruptionStatus: Codable, Identifiable {
    var id = UUID()
    var source: String
    var statusType: String?
    var descrp: String?
    
    enum CodingKeys: String, CodingKey {
        case source
        case statusType
        case descrp = "description"
    }
}
