//
//  LineDataViewModel.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 09/07/2025.
//
import Foundation
import SwiftData
import SwiftUI

class TrainLine: Codable, Identifiable {
    
    var id: String
    var RGB : [Double]
    var status: Bool?
    var detail: String?
    
    
    var colour : Color{
        Color( red: RGB[0], green: RGB[1], blue: RGB[2])
    }
    

    enum CodingKeys : String, CodingKey{
        case id
        case RGB
    }

}

