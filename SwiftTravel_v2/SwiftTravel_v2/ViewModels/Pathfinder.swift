import Foundation


fileprivate struct Path: Comparable {
    var stationId: String
    var weight: Int

    static func < (lhs: Path, rhs: Path) -> Bool {
        return lhs.weight < rhs.weight
    }
}


fileprivate struct PathfindingRoute {
    let originalId: UUID
    var from: String
    var to: String
    var line: String
    var weight: Int
    var type: String
}


class Pathfinder {
    private let allTempRoutes: [PathfindingRoute]
    private let routeLookup: [UUID: Route]

    init(routes: [Route]) {
        var tempRoutes: [PathfindingRoute] = []
        var lookup: [UUID: Route] = [:]
        
        for route in routes {
            let id = UUID() // A temporary, unique ID for this search session
            tempRoutes.append(
                PathfindingRoute(
                    originalId: id,
                    from: route.from,
                    to: route.to,
                    line: route.line,
                    weight: route.weight,
                    type: route.type
                )
            )
            lookup[id] = route
        }
        
        self.allTempRoutes = tempRoutes
        self.routeLookup = lookup
    }

    func findKShortestPaths(from startStationID: String, to endStationID: String, searchLimit: Int) -> [[Route]] {
       
        let foundTempPaths = findKShortestTempPaths(from: startStationID, to: endStationID, searchLimit: searchLimit)
        
        let finalPaths = foundTempPaths.map { path in
            path.compactMap { tempRoute in
                routeLookup[tempRoute.originalId] // Use the lookup to find the original
            }
        }
        
        return finalPaths
    }

   
    private func findKShortestTempPaths(from startStationID: String, to endStationID: String, searchLimit: Int) -> [[PathfindingRoute]] {
        var paths: [[PathfindingRoute]] = []
        var temporaryRoutes = self.allTempRoutes

        while paths.count < searchLimit {
            let pathfinder = DijkstraPathfinder(routes: temporaryRoutes)
            
            guard let newPath = pathfinder.findShortestPath(from: startStationID, to: endStationID), !newPath.isEmpty else {
                break
            }
            
            paths.append(newPath)
            
            // This modification is now safe as it only affects the local struct copies.
            for routeInPath in newPath {
                if let index = temporaryRoutes.firstIndex(where: { $0.originalId == routeInPath.originalId }) {
                    temporaryRoutes[index].weight += 5 // Apply penalty
                }
            }
        }
        
        return paths.sorted { $0.totalWeight < $1.totalWeight }
    }
}


// The private helper class is updated to work with the safe PathfindingRoute struct.
private class DijkstraPathfinder {
    private let adjacencyList: [String: [PathfindingRoute]]

    init(routes: [PathfindingRoute]) {
        var adjList = [String: [PathfindingRoute]]()
        for route in routes {
            adjList[route.from, default: []].append(route)
        }
        self.adjacencyList = adjList
    }

    func findShortestPath(from startStationID: String, to endStationID: String) -> [PathfindingRoute]? {
        var distances: [String: Int] = [startStationID: 0]
        var previous: [String: PathfindingRoute] = [:]
        var priorityQueue = PriorityQueue<Path>(sort: <)
        priorityQueue.enqueue(Path(stationId: startStationID, weight: 0))
        
        let transferPenalty = 10
        
        while let currentPath = priorityQueue.dequeue() {
            let currentStationId = currentPath.stationId
            
            if currentStationId == endStationID { break }
            
            guard let currentWeight = distances[currentStationId], currentWeight == currentPath.weight else { continue }
            
            guard let neighbors = adjacencyList[currentStationId] else { continue }

            for route in neighbors {
                var penalty = 0
                if let previousRoute = previous[currentStationId] {
                    if previousRoute.line != route.line && route.type != "Transfer" {
                        penalty = transferPenalty
                    }
                }

                let newWeight = currentWeight + route.weight + penalty
                
                if newWeight < (distances[route.to] ?? Int.max) {
                    distances[route.to] = newWeight
                    previous[route.to] = route
                    priorityQueue.enqueue(Path(stationId: route.to, weight: newWeight))
                }
            }
        }
        
        guard previous[endStationID] != nil else { return nil }
        
        var path: [PathfindingRoute] = []
        var currentId = endStationID
        while let route = previous[currentId] {
            path.insert(route, at: 0)
            currentId = route.from
        }
        
        return path
    }
}

// The helper extension is updated to calculate weight for the safe struct.
extension Array where Element == PathfindingRoute {
    var totalWeight: Int {
        self.reduce(0) { $0 + $1.weight }
    }
}
