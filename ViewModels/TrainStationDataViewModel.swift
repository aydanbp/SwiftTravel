//
//  StationDataViewModel.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import Foundation
import CoreLocation
import SwiftUICore


@MainActor
class StationDataViewModel: ObservableObject {
    @ObservedObject var database = DatabaseViewModel()
    @Published var possibleRoutes : [String : [Route]] = [:]
    
    @Published var shortestPath : [Route]?
    @Published var allPaths : [[Route]] = []
    
    

    private func buildRoutes()async{
        for route in database.routes{
            possibleRoutes[route.from, default: []].append(route)
        }
        
    }
    

    public func calculateAlternativeRoutes(from startUUID: String, to endUUID: String) {
        //Get all routes from the starting station
        guard let initialRoutes = possibleRoutes[startUUID] else {
            self.allPaths = []
            return
        }

        var bestPathPerLine: [String: [Route]] = [:]

        // Loop through each route
        for route in initialRoutes {
            if bestPathPerLine[route.line] == nil {
                if let subsequentPath = findBestRoute(from: route.to, to: endUUID) {
                    let fullPath = [route] + subsequentPath
                    bestPathPerLine[route.line] = fullPath
                }
            }
        }
        
        let foundPaths = Array(bestPathPerLine.values)
        self.allPaths = foundPaths.sorted { $0.count < $1.count }
    }
    
    public func calculateAndShowShortestRoute(from startUUID: String, to endUUID: String) {
        self.shortestPath = findBestRoute(from: startUUID, to: endUUID)
    }

    /// Finds the best route between two stations using Dijkstra's algorithm.
    private func findBestRoute(from startUUID: String, to endUUID: String) -> [Route]? {
        var distances: [String: Int] = [:]
        var previous: [String: Route] = [:]
        var priorityQueue = PriorityQueue<String>(sort: { distances[$0, default: .max] < distances[$1, default: .max] })

        // CRITICAL FIX: Initialize distances using the composite `uuid` to match the graph keys.
        for station in database.stations {
            distances[station.uuid] = .max
        }
        distances[startUUID] = 0
        
        priorityQueue.enqueue(startUUID)

        while let currentCode = priorityQueue.dequeue() {
            if currentCode == endUUID { break }
            
            guard let outgoingRoutes = possibleRoutes[currentCode] else { continue }
            
            for route in outgoingRoutes {
                // Use a default weight of 60 if one isn't provided in the JSON
                let newDistance = distances[currentCode, default: .max] + (route.weight ?? 60)
                
                if newDistance < distances[route.to, default: .max] {
                    distances[route.to] = newDistance
                    previous[route.to] = route
                    priorityQueue.enqueue(route.to)
                }
            }
        }
        
        var path: [Route] = []
        var current = endUUID
        while let prevRoute = previous[current] {
            path.insert(prevRoute, at: 0)
            current = prevRoute.from
        }
        
        return path.first?.from == startUUID ? path : nil
    }
}

// A simple Priority Queue implementation needed for Dijkstra's algorithm.
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


