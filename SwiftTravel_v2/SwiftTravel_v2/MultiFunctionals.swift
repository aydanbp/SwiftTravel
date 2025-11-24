//
//  MultiFunctionals.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 31/08/2025.
//

import SwiftUI
import SwiftData
import MapKit

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
    case "Elizabeth", "Elizabeth Line", "Elizabeth line":
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

func clearButton(for text : Binding<String>) -> some View {
    Button("", systemImage: "xmark.circle.fill", action: {
        text.wrappedValue = ""
    })
    .foregroundStyle(Color.gray)
    .opacity(0.5)
}
// Custom search field view for reusability
func searchField(text: Binding<String>, placeholder: String) -> some View {
    HStack {
        TextField(placeholder, text: text)
            .padding(12)
        if !text.wrappedValue.isEmpty {
            clearButton(for: text)
                .padding(.trailing)
        }
    }
}

func colourRGB(_ r: Int? , _ g: Int?, _ b: Int?) -> Color { //Returns percise colours
    return Color(red: Double(r ?? 0) / 255, green: Double(g ?? 0) / 255, blue: Double(b ?? 0) / 255)
}
func colourRGB (_ values : [Int]) -> Color {
    guard values.count == 3 else {
        return .black
    }
    return Color(
        red: Double(values[0]) / 255.0,
        green: Double(values[1]) / 255.0,
        blue: Double(values[2]) / 255.0
    )
}
func colourRGB() -> Color { //used as temp colour
    print("Temp Colour used")
    return .black
}

func locationExtractor(_ items: [String]) -> [CLLocationCoordinate2D] {
    var locations: [CLLocationCoordinate2D] = []
    for item in items {
        let components = item.split(separator: ",")
        guard components.count == 2,
              let latitude = Double(components[0]),
              let longitude = Double(components[1]) else {
            print("Error: Invalid coordinate format for item: \(item)")
            continue
        }

        locations.append(CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        ))
    }
    
    // Return the array of locations
    return locations
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

func getCoordinates(query : String) async throws -> CLLocationCoordinate2D {
    var coordinates : CLLocationCoordinate2D?
    let geocoder = CLGeocoder()
    if let placemarks = try? await geocoder.geocodeAddressString(query),
       let location = placemarks.first?.location?.coordinate {
        
        DispatchQueue.main.async {
            coordinates = location
        }
        
    } else {
        print("Error: Unable to find the coordinates for the Station.")
        
    }
    return coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
}

func findNearestStation(_ location: String, stations : [TrainStation]) async -> TrainStation? {
    do{
        var coordinates = try await getCoordinates(query: location)
        var nearestStation : TrainStation?
        var minDistance = Double.greatestFiniteMagnitude
        for station in stations {
            let statLocation = CLLocation(latitude: station.latitude,
                                          longitude: station.longitude)
            let currentLocation = CLLocation(latitude: coordinates.latitude,
                                             longitude: coordinates.longitude)
            let distance = statLocation.distance(from: currentLocation)
            if distance < minDistance{
                minDistance = distance
                nearestStation = station
            }
        }
        return nearestStation
    } catch{
        return nil
    }
    

}
struct PriorityQueue<T> {
    private var elements: [T] = []
    private let sort: (T, T) -> Bool

    init(sort: @escaping (T, T) -> Bool) {
        self.sort = sort
    }

    var isEmpty: Bool { return elements.isEmpty }
    var count: Int { return elements.count }

    mutating func enqueue(_ element: T) {
        elements.append(element)
        elements.sort(by: sort)
    }

    mutating func dequeue() -> T? {
        return isEmpty ? nil : elements.removeFirst()
    }
}
func drawMapLine(_ coordinates : [CLLocationCoordinate2D]) -> some MapContent{
    MapPolyline(coordinates: coordinates)
}
extension String {
    func sanitizedForTopic() -> String {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01223456789-_.~")
        return self.components(separatedBy: allowedCharacters.inverted)
            .joined()
            .lowercased()
            .replacingOccurrences(of: "&", with: "and")
    }
}
