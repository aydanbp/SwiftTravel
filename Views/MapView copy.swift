import SwiftUI

import MapKit
import SwiftData


struct MapView2 : View {
    @EnvironmentObject var routeSettings : routeSettings
    @EnvironmentObject var stationSettings : stationSettings
    @EnvironmentObject var searchData : stationPassData
    
    @StateObject var StationviewModel = StationDataViewModel()
    @StateObject var viewModel = DatabaseViewModel()
    

    @State var cameraRegion : MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1276),
                                           span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)))
    @State var currentregion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1276),
                                                  span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
    @State var ShowingDetail = false
    @State private var searchText = ""
    @State private var secondText = ""
    @State var fromLocation: CLLocationCoordinate2D?
    @State var toLocation: CLLocationCoordinate2D?
    @State var updateText : String = ""
    @State var ULoc : CLLocationCoordinate2D?
    @State var expandSearch = false
    
    @Environment(\.colorScheme) private var colorScheme
    @State var bodyColour : Color  = Color.black
    @State var bgColour : Color  = Color.white
    @State var mapSpan : Double  = 0.4
    @State var showPaths : Bool  = false
    @State var searchSize : Int = 50
    private var visibleStations: [TrainStation] {
        // 1. First, select the correct base collection of stations using your switch statement.
        // This ensures your filter is always applied first.
        let baseStations: [TrainStation]
        switch stationSettings.showNodes {
        case .tfl:
            baseStations = viewModel.TfLStations
        case .nationalRail:
            baseStations = viewModel.NRStations
        case .all:
            baseStations = viewModel.stations
        case .none:
            baseStations = [] // If set to none, baseStations is now an empty array.
        default:
            baseStations = []
        }
        
        // 2. Now, check the zoom level.
        guard cameraRegion.region?.span.latitudeDelta ?? 1.0 < 0.5 else {
            // If zoomed out, return the entire collection you just selected.
            // If .none was chosen, this correctly returns the empty array.
            return baseStations
        }
        
        // 3. If zoomed in, filter that selected collection to show only what's visible on screen.
        return baseStations.filter { station in
            let stationLat = station.coordinates.latitude
            let stationLon = station.coordinates.longitude
            
            let minLat = currentregion.center.latitude - (currentregion.span.latitudeDelta / 2)
            let maxLat = currentregion.center.latitude + (currentregion.span.latitudeDelta / 2)
            let minLon = currentregion.center.longitude - (currentregion.span.longitudeDelta / 2)
            let maxLon = currentregion.center.longitude + (currentregion.span.longitudeDelta / 2)
            
            return (stationLat >= minLat && stationLat <= maxLat) && (stationLon >= minLon && stationLon <= maxLon)
        }
    }
    
    

    
    var body: some View {
        let nodeSpawnLimit = 0.5

        
        ZStack() {
            Map(position: $cameraRegion, interactionModes: [.pan, .zoom]){
                
                if mapSpan < nodeSpawnLimit {
                   
                        ForEach (visibleStations) {station in
                            Annotation(station.stationName, coordinate: station.coordinates){
                                VStack{
                                    midImage(bodyColour, bgColour)
                                    
                                }
                                .onTapGesture {
                                    viewModel.selectedStation = station
                                    ShowingDetail=true
                                }
                            }
                        }
                    
                    
                }
                
                ForEach (viewModel.displayRoutes) {route in
                    let isPathHighlighted = viewModel.shortestPath != nil
                    displayRoute(route, isPathHighlighted)
                        
                    
                }

                
                if let path = viewModel.shortestPath {
                    
                    ForEach(path) { route in
                        if let fromStat = viewModel.stationLookup[route.from],
                           let toStat = viewModel.stationLookup[route.to] {
                            MapPolyline(coordinates: [fromStat.coordinates, toStat.coordinates])
                                .stroke(colorFor(line: route.line), lineWidth: 10) // Make it stand out
                        }
                    }
                    
                }
                

                
            }
            
            .onMapCameraChange {mapUpdate in
                mapSpan = mapUpdate.region.span.latitudeDelta
                self.currentregion = mapUpdate.region
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .task {
                if viewModel.stations.isEmpty{
                    await viewModel.loadAllData()
                }
                
                
            }
            
            .sheet(isPresented: $ShowingDetail) {
                if let selectedStation = viewModel.selectedStation {
                    
                    VStack {
                        trainArrivalsView(station: selectedStation)
                        
                    }
                }
            }
            VStack(){
                VStack {
                    Spacer() // Pushes the buttons to the bottom
                    HStack {
                        Button(action: {
                            
                        }){Image(systemName: "location.circle")}
                            .frame(width: 44, height: 44)
                            .background(.thinMaterial)
                            .padding(.leading)
                            .cornerRadius(10)
                        Spacer() // Pushes the buttons to the right
                        //Location Button


                        // --- Zoom Buttons ---
                        VStack(spacing: 0) {
                            // Zoom In Button
                            Button(action: {
                                zoomMap(by: 0.5) // Halve the span to zoom in
                            }) {
                                Image(systemName: "plus")
                            }
                            .frame(width: 44, height: 44)
                            .background(.thinMaterial)
                            
                            Divider().frame(width: 44)
                            
                            // Zoom Out Button
                            Button(action: {
                                zoomMap(by: 2.0) // Double the span to zoom out
                            }) {
                                Image(systemName: "minus")
                            }
                            .frame(width: 44, height: 44)
                            .background(.thinMaterial)
                        }
                        .font(.title2)
                        .cornerRadius(10)
                        .padding()
                        
                    }
                }
            }
            VStack{
                SearchBar(expandSearch: $expandSearch, viewModel: StationviewModel, region: $currentregion, cameraRegion: $cameraRegion, fromLocation: $fromLocation, toLocation: $toLocation, updateText: $updateText, showPaths: $showPaths)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding()
                Spacer()
                if searchData.searchResults.count != 0 {
                    SearchResultView(viewModel: StationviewModel, cameraRegion: $cameraRegion, updateText: $updateText, showPaths: $showPaths)
                        .frame(width: .infinity, height: 200)
                        .cornerRadius(20)
                }
            }


            

            


            
                
        }


        
        
        .onChange(of: colorScheme){
            if colorScheme == .dark {
                bodyColour = Color.black
                bgColour = Color.white
            } else {
                bodyColour = Color.white
                bgColour = Color.black
            }
        }
        
    }
    private func zoomMap(by factor: Double) {
        let currentRegion = currentregion
        let newSpan = MKCoordinateSpan(
            latitudeDelta: currentRegion.span.latitudeDelta * factor,
            longitudeDelta: currentRegion.span.longitudeDelta * factor
        )
        let newRegion = MKCoordinateRegion(
            center: currentRegion.center,
            span: newSpan
        )
        cameraRegion = .region(newRegion)
    }
    
}





#Preview {
    MapView2()
        .environmentObject(routeSettings())
        .environmentObject(stationSettings())
        .environmentObject(stationPassData())
}
