//
//  SearchView.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 25/06/2025.
//

import SwiftUI
import MapKit

struct SearchBar: View {
    @State private var searchText = ""
    @State private var secondText = ""
    @Binding var expandSearch : Bool
    @State var secondSearch : Bool = false
    @ObservedObject var viewModel : StationDataViewModel
    @Binding var region : MKCoordinateRegion
    @Binding var cameraRegion : MapCameraPosition
    @Binding var fromLocation : CLLocationCoordinate2D?
    @Binding var toLocation : CLLocationCoordinate2D?
    @Binding var updateText : String
    @FocusState var isFocused: focusField?
    @EnvironmentObject var searchData : stationPassData
    @Binding var showPaths : Bool
    
    var body: some View {
        
        VStack{
            HStack{
                //startingLocation Bar
                Spacer()
                searchField(text: $searchText)
                    .focused($isFocused, equals : .start)
                
                Toggle("", systemImage: secondSearch ? "chevron.down" : "chevron.up", isOn: $secondSearch)
                    .toggleStyle(.button)
                    .imageScale(.large)
                    .background(Color.clear)
            }
            .background(.thinMaterial)
            
            //destinationLocation
            if secondSearch{
                
                HStack{
                    Spacer()
                    searchField(text: $secondText)
                        .focused($isFocused, equals: .end)
                    Button("", systemImage: "arrow.right.circle.fill", action: {
                        Task{
                            do{
                                fromLocation = try await getCoordinates(query: searchText)
                                if secondSearch{
                                    toLocation = try await getCoordinates(query: secondText)
                                }
                                //                        cameraRegion = MapCameraPosition.region(MKCoordinateRegion(center: newRegion, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)))
                            }
                        }
                        findAndShowRoute()
                        showPaths = true
                    })
                    .imageScale(.large)
                }
                .background(.thinMaterial)
            }

            
        }
        .onChange(of: searchText) {
            searchData.activeString = searchText
            searchData.searchResults = returnFilteredStation()
        }
        .onChange(of: secondText) {
            searchData.activeString = secondText
            searchData.searchResults = returnFilteredStation()
        }
        .onChange(of: updateText) { 
            switch isFocused {
            case .start:
                searchText = updateText
            case .end:
                secondText = updateText
            case nil:
                break
            }

        }
        
            
            

        
        
        
    }
    func returnFilteredStation () -> [Station] {
        return viewModel.database.stations.filter {
            $0.stationName.lowercased().contains(searchData.activeString.lowercased()) ||// Search by name
            $0.crsCode.lowercased().contains(searchData.activeString.lowercased()) //Search by code
        }
    
}
    func getCoordinates(query : String) async throws -> CLLocationCoordinate2D {
        var coordinates : CLLocationCoordinate2D?
        let geocoder = CLGeocoder()
        if let placemarks = try? await geocoder.geocodeAddressString(query),
           let location = placemarks.first?.location?.coordinate {
            
            DispatchQueue.main.async {
                coordinates = location
                //                self.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
                cameraRegion = MapCameraPosition.region(MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)))
            }
            
        } else {
            // Handle error here if geocoding fails
            print("Error: Unable to find the coordinates for the club.")
            
        }
        return coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    private func findAndShowRoute() {
        // Find the station objects corresponding to the search text
        let startStation = viewModel.database.stations.first { $0.stationName.lowercased() == searchText.lowercased() || $0.crsCode.lowercased() == searchText.lowercased() }
        let endStation = viewModel.database.stations.first { $0.stationName.lowercased() == secondText.lowercased() || $0.crsCode.lowercased() == secondText.lowercased() }

        // If both stations are found, call the view model to calculate the path
        if let start = startStation, let end = endStation {
            viewModel.calculateAndShowShortestRoute(from: start.uuid, to: end.uuid)
            viewModel.calculateAlternativeRoutes(from: start.uuid, to: end.uuid)
        } else {
            print("Could not find start or end station from search text.")
            viewModel.shortestPath = nil // Clear previous path
        }
        hideKeyboard()
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    enum focusField {
        case start, end
    }
    
}
