//
//  LineColours.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 03/08/2025.
//
import SwiftUI
import MapKit
import SwiftData
typealias Colour = Color

class line : Codable, Identifiable {
    let name : String
    let type : String
    let code : String
    let colourValues : [Int]
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
}



public func colorFor(line: String) -> Color {
    switch line {
    case "Bakerloo":
        return colourRGB(178, 99, 0)
    case "Central":
        return colourRGB(227, 32, 23)
    case "Circle":
        return colourRGB(255, 200, 10)
    case "District":
        return colourRGB(0, 120, 42)
    case "DLR":
        return colourRGB(0, 175, 173)
    case "Elizabeth":
        return colourRGB(96, 57, 158)
    case "Hammersmith & City","H&C":
        return colourRGB(245, 137, 166)
    case "Jubilee":
        return colourRGB(131, 141, 147)
    case "Metropolitan", "Metro":
        return colourRGB(155, 0, 88)
    case "Northern":
        return .black
    case "Piccadilly":
        return colourRGB(0, 15, 168)
    case "Victoria":
        return colourRGB(3, 155, 229)
    case "W&C", "Waterloo & City":
        return colourRGB(118, 208, 189)
    case "Tram":
        return colourRGB(95, 181, 38)
    //Seperate new overground lines
    case "Liberty":
        return colourRGB(93, 93, 97)
    case "Lioness":
        return colourRGB(250, 166, 26)
    case "Mildmay":
        return colourRGB(0, 119, 173)
    case "Suffragette":
        return colourRGB(91, 189, 114)
    case "Weaver":
        return colourRGB(130, 58, 98)
    case "Windrush":
        return colourRGB(237, 27, 0)
    //Seperate NR lines
    case "SWR":
        return colourRGB(36, 57, 140)
    case "GWR":
        return colourRGB(11, 45, 39)
    case "xCountry":
        return colourRGB(102, 15, 33)
    case "Avanti", "Avanti West Coast":
        return colourRGB(0, 67, 84)
    case "c2c":
        return colourRGB(183, 0, 124)
    case "Chilt", "Chiltern":
        return colourRGB(0, 191, 255)
    case "eastM":
        return colourRGB(113, 53, 99)
    case "gAng":
        return colourRGB(215, 4, 40)
    case "heathrowX", "Heathrow Experess":
        return colourRGB(83, 46, 99)
    case "LNER":
        return colourRGB(153, 204, 103) //Change
    case "SE", "Southeastern": //Southeastern
        return colourRGB(56, 156, 255)
    case "Southern":
        return colourRGB(140, 198, 62)
    case "Thameslink":
        return colourRGB(255, 90, 164)
        //Transfers, usually Walkable
    case "Transfer":
        return .gray

    default:
        print ("\(line) not found, returning white")
        return .white // A default color for any other lines
    }
}



