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
    @StateObject var viewModel = StationDataViewModel()
    @Binding var region : MKCoordinateRegion
    @Binding var cameraRegion : MapCameraPosition
    var body: some View {
        VStack{
            HStack{
                
                Spacer()
                TextField("Search", text: $searchText)
                    .frame(height: 50)
                if !searchText.isEmpty {
                    Button("", systemImage: "xmark.circle.fill", action: {
                        self.searchText = ""
                    })
                    .foregroundStyle(Color.gray)
                    .opacity(0.5) //1 = visible | 0 = invisible
                }
                
                Toggle("", systemImage: "arrow.trianglehead.turn.up.right.circle.fill", isOn: $expandSearch)
                    .toggleStyle(.button)
                    .imageScale(.large)
            }
            .background(.thinMaterial)

            if expandSearch{
                
                HStack{
                    Spacer()
                    TextField("Destination", text: $secondText)
                        .frame(height: 50)
                    if !secondText.isEmpty {
                        Button("", systemImage: "xmark.circle.fill", action: {
                            self.secondText = ""
                        })
                        .foregroundStyle(Color.gray)
                        .opacity(0.5) //1 = visible | 0 = invisible
                    }
                    Button("", systemImage: "arrow.right.circle.fill", action: {
                        
                    })
                    .imageScale(.large)
                }
                .background(.thinMaterial)
            }
            
            
            var searchResults : [Station] {
                if searchText.isEmpty {
                    return []
                }
                else{
                    return viewModel.stations.filter {
                        $0.stationName.lowercased().contains(searchText.lowercased()) ||// Search by name
                        $0.crsCode.lowercased().contains(searchText.lowercased()) //Search by code
                    }
                }
            }
            
            
            List(searchResults){ result in
                HStack{
                    Button(result.stationName){
                        cameraRegion = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude),
                                                                                   span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)))

                        searchText = result.stationName
                    }
                }
                
                
            }
        }
        .onChange(of: searchText) { newValue in
            if secondText.isEmpty{
                expandSearch = !newValue.isEmpty
            }
            
        }
        
        
    }
    func getCoordinates(){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("London") { placemarks, error in
            if let location = placemarks?.first?.location?.coordinate {
                DispatchQueue.main.async {
                    //self.coordinates = location
                }
            }
        }
        
    }

}
