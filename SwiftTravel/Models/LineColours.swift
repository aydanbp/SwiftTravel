//
//  LineColours.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 03/08/2025.
//
import SwiftUI
func colorFor(line: String) -> Color {
    switch line {
    case "Bakerloo":
        return Color(red: 178/255, green: 99/255, blue: 0/255)
    case "Central":
        return Color(red: 227/255, green: 32/255, blue: 23/255)
    case "Circle":
        return Color(red: 255/255, green: 200/255, blue: 10/255)
    case "District":
        return Color(red: 0/255, green: 120/255, blue: 42/255)
    case "DLR":
        return Color(red: 0/255, green: 175/255, blue: 173/255)
    case "Elizabeth":
        return Color(red: 96/255, green: 57/255, blue: 158/255)
    case "Hammersmith & City":
        return Color(red: 245/255, green: 137/255, blue: 166/255)
    case "Jubilee":
        return Color(red: 131/255, green: 141/255, blue: 147/255)
    case "Metropolitan":
        return Color(red: 155/255, green: 0/255, blue: 88/255)
    case "Northern":
        return .black
    case "Piccadilly":
        return Color(red: 0/255, green: 25/255, blue: 168/255)
    case "Victoria":
        return Color(red: 3/255, green: 155/255, blue: 229/255)
    case "Waterloo & City":
        return Color(red: 118/255, green: 208/255, blue: 189/255)
    case "Tram":
        return Color(red: 95/255, green: 181/255, blue: 38/255)
    //Seperate new overground lines
        case "Liberty":
            return Color(red: 93/255, green: 93/255, blue: 97/255)
    case "Lioness":
        return Color(red: 250/255, green: 166/255, blue: 26/255)
    case "Mildmay":
        return Color(red: 0/255, green: 119/255, blue: 173/255)
    case "Suffragette":
        return Color(red: 91/255, green: 189/255, blue: 114/255)
    case "Weaver":
        return Color(red: 130/255, green: 58/255, blue: 98/255)
    case "Windrush":
        return Color(red: 237/255, green: 27/255, blue: 0/255)
    //Seperate NR lines
    case "SWR":
        return Color(red: 36/255, green: 57/255, blue: 140/255)
    case "GWR":
        return Color(red: 11/255, green: 45/255, blue: 39/255)
    case "xCountry":
        return Color(red: 255/255, green: 149/255, blue: 0/255) //Change
    case "Avanti":
        return Color(red: 255/255, green: 149/255, blue: 0/255) //Change
    case "c2c":
        return Color(red: 255/255, green: 149/255, blue: 0/255) //Change
    case "chilt":
        return Color(red: 255/255, green: 149/255, blue: 0/255) //Change
    case "eastM":
        return Color(red: 255/255, green: 149/255, blue: 0/255) //Change
    case "gAng":
        return Color(red: 255/255, green: 149/255, blue: 0/255) //Change
    case "heathrowX":
        return Color(red: 255/255, green: 149/255, blue: 0/255) //change
    case "LNER":
        return Color(red: 255/255, green: 149/255, blue: 0/255) //Change
    case "SE": //Southeastern
        return Color(red: 255/255, green: 149/255, blue: 0/255) //Change

    default:
        return .white // A default color for any other lines
    }
}
