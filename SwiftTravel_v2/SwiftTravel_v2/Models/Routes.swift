import SwiftData
import Foundation
import CoreLocation


@Model
final class Route: Codable, Hashable {
    var id = UUID()
    var from: String
    var to: String
    var line: String
    var weight: Int
    var type : String

    // initiliser
    init(from: String, to: String, line: String, weight: Int, type : String) {
        
        self.from = from
        self.to = to
        self.line = line
        self.weight = weight
        self.type = type
    }

    
    enum CodingKeys: String, CodingKey {
        case id, from, to, line, weight, type
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.from = try container.decode(String.self, forKey: .from)
        self.to = try container.decode(String.self, forKey: .to)
        self.line = try container.decode(String.self, forKey: .line)
        self.weight = try container.decode(Int.self, forKey: .weight)
        self.type = try container.decode(String.self, forKey: .type)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(line, forKey: .line)
        try container.encode(weight, forKey: .weight)
        try container.encode(type, forKey: .type)
    }

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
}
extension Array where Element == Route {
    // Calculates total weight of the journey by summing the weights of all its segments.
    var totalWeight: Int {
        self.reduce(0) { $0 + $1.weight }
    }
}
