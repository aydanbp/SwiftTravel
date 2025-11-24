import SwiftUI
import SwiftData
import MapKit


struct SearchComp: View {
    @Query var stations: [TrainStation]
    @Query var routes: [Route]
    
    @State private var startQuery: String = ""
    @State private var destinationQuery: String = ""
    @FocusState private var isFocused: FocusField?
    
    @State private var startStation: TrainStation?
    @State private var destinationStation: TrainStation?

    @Binding var selectedStation: TrainStation?
    @Binding var activeJourney: [Route]
    
    @State private var allJourneyOptions: [[Route]] = []
    @State private var selectedJourneyIndex: Int = 0
    @EnvironmentObject var databaseManager: DatabaseManager
    
    private var searchResults: [TrainStation] {
        let activeQuery = isFocused == .start ? startQuery : destinationQuery
        if activeQuery.isEmpty { return [] }
        return stations.filter { $0.stationName.starts(with: activeQuery) }
    }
    
    
    

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                searchField(text: $startQuery, placeholder: "Start Station")
                    .focused($isFocused, equals: .start)
                    .onSubmit {
                        Task{
                            if let nearest = await findNearestStation(startQuery, stations: stations) {
                                // --- FIX 1: Correctly set the startStation and update UI ---
                                startStation = nearest
                                startQuery = nearest.stationName
                                selectedStation = nearest
                                isFocused = .end // Move focus to the destination field
                            }
                        }
                        
                    }
                Divider().padding(.horizontal)
                searchField(text: $destinationQuery, placeholder: "Destination")
                    .focused($isFocused, equals: .end)
                    .onSubmit {
                        Task{
                            if let nearest = await findNearestStation(destinationQuery, stations: stations) {
                                destinationStation = nearest
                                destinationQuery = nearest.stationName
                                selectedStation = nearest
                                isFocused = nil
                            }
                        }
                        
                    }
            }
            .background(.thinMaterial)
            .cornerRadius(10).shadow(radius: 5).padding(.horizontal)
            
            if startStation != nil && destinationStation != nil {
                HStack{
                    Button(action: findAndDisplayRoutes) {
                        Label("Find Route", systemImage: "magnifyingglass")
                    }
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.scale)
                    if !allJourneyOptions.isEmpty {
                        Button("", systemImage: "eraser.line.dashed.fill"){
                            allJourneyOptions = []
                            
                        }
                        .padding()
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.scale)
                    }
                }
                
                
            }

            Spacer()
            
            if !allJourneyOptions.isEmpty {
                JourneySelectorView(optionalJourneys: allJourneyOptions,
                                    selectedJourneyIndex: $selectedJourneyIndex)
                    .frame(height: 350)
                
            }
            
            if !searchResults.isEmpty && isFocused != nil {
                SearchResultsList(results: searchResults, onSelect: handleStationSelection, selectedStation: $selectedStation)
            }
        }
        .animation(.spring(), value: allJourneyOptions.isEmpty)
        .animation(.spring(), value: searchResults.isEmpty)
        .onChange(of: selectedJourneyIndex) {
            if !allJourneyOptions.isEmpty && allJourneyOptions.indices.contains(selectedJourneyIndex) {
                activeJourney = allJourneyOptions[selectedJourneyIndex]
            }
        }
    }
    
    private func handleStationSelection(_ station: TrainStation) {
        selectedStation = station
        switch isFocused {
        case .start:
            startStation = station
            startQuery = station.stationName
        case .end:
            destinationStation = station
            destinationQuery = station.stationName
        case nil: break
        }
        isFocused = nil
    }
    
    private func findAndDisplayRoutes() {
        // **FIX:** Added comprehensive debugging print statements.
        print("--- Initiating Route Search ---")
        
        guard let start = startStation, let end = destinationStation else {
            print("Error: Start or destination station nil")
            return
        }
        
        guard !routes.isEmpty else {
            print("Error: The 'routes' database is empty. Reload Data")
            return
        }
        
        print("From: \(start.stationName) (ID: \(start.id))")
        print("To: \(end.stationName) (ID: \(end.id))")
        print(" Routes available to Pathfinder: \(routes.count)")

        let pathfinder = Pathfinder(routes: routes)
        let foundPaths = pathfinder.findKShortestPaths(from: start.id, to: end.id, searchLimit: 20)
        
        print("Pathfinder finished. Found \(foundPaths.count) possible paths.")
        
        if foundPaths.isEmpty {
            print("No paths were found. Check if station IDs in the 'Routes' data match the 'Station' data.")
        }
        
        self.allJourneyOptions = foundPaths
        self.selectedJourneyIndex = 0
        
        self.activeJourney = foundPaths.first ?? []
        
        hideKeyboard()
        print("--- Route Search Complete ---")
    }
}

struct SearchResultsList: View {
    let results: [TrainStation]
    let onSelect: (TrainStation) -> Void
    @Binding var selectedStation: TrainStation?
    @EnvironmentObject var databaseManager: DatabaseManager
    var body: some View {
        
        VStack(spacing: 0) {
            Text("\(results.count) matching stations").font(.caption).foregroundColor(.secondary).padding(.vertical, 8)
            Divider()
            List(results) { result in
                HStack{
                    Button(action: { onSelect(result)}) {
                        SearchResultRow(station: result)
                    }
                    Button("", systemImage: "info.circle"){
                        selectedStation = result
                        databaseManager.showStationDetails = true
                    }
                }
                
            }
            .listStyle(.plain)
        }
        .frame(maxHeight: 300)
        .background(.ultraThinMaterial)
        .cornerRadius(15).shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        .padding()
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}
struct SearchResultRow: View {
    let station: TrainStation

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconForStationType(station.type))
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(station.stationName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(station.crsCode)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func iconForStationType(_ type: String) -> String {
        switch type {
        case "T":
            return "tram.circle.fill"
        case "N":
            return "train.side.front.car"
        case "C":
            return "arrow.triangle.2.circlepath.circle"
        default:
            return "mappin.circle.fill"
        }
    }
}
extension Array where Element == Route {
    var numberOfChanges: Int {
        guard !self.isEmpty else { return 0 }
        var changes = 0
        var currentLine = self.first!.line
        for route in self {
            if route.line != currentLine {
                changes += 1
                currentLine = route.line
            }
        }
        return changes
    }
    
    var uniqueLines: [String] {
        var seenLines = [String]()
        for route in self {
            if !seenLines.contains(route.line) {
                seenLines.append(route.line)
            }
        }
        return seenLines
    }
}

enum FocusField {
    case start, end
}

