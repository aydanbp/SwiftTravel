import SwiftUI
import MapKit
import SwiftData
import _CoreLocationUI_SwiftUI

struct JourneyPolyline: Identifiable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
    let color: Color
}

struct MainMap: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var databaseManager: DatabaseManager
    @StateObject var locationManager = LocationManager()
    
    @Query var stations: [TrainStation]
    @Query var mapRoutes: [savedMapRoutes]
    
    @EnvironmentObject var stationSettings: stationSettings
    
    // State for the journey
    @State private var selectedStation: TrainStation?
    @State var activeDestination: TrainStation?
    
    // State for the map
    @State private var cameraRegion: MapCameraPosition = .automatic
    @State private var currentregion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1276),
        span: MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35)
    )
    
    private var visibleStations: [TrainStation] {
        let baseStations: [TrainStation]
        switch stationSettings.showNodes {
        case .tfl:
            baseStations = stations.filter { $0.type == "T" || $0.type == "C" }
        case .nationalRail:
            baseStations = stations.filter { $0.type == "N" || $0.type == "C" }
        case .all:
            baseStations = Array(stations)
        default:
            baseStations = []
        }
        
        let mapSpan = currentregion.span.latitudeDelta
        guard mapSpan < 0.5 else { return baseStations }
        return baseStations.filter { station in
            currentregion.contains(coordinate: station.coordinates)
        }
    }
    private var visibleRoutes: [savedMapRoutes] {
        let baseRoutes : [savedMapRoutes]
        switch stationSettings.showNodes {
        case .tfl:
            baseRoutes = mapRoutes.filter {$0.type == "T" || $0.type == "W"}
        case .nationalRail:
            baseRoutes = mapRoutes.filter { $0.type == "N" || $0.type == "W"}
        case .all:
            baseRoutes = Array(mapRoutes)
        default:
            baseRoutes = []
        }
        return baseRoutes
    }
    
    
    @MapContentBuilder
    private var stationAnnotations: some MapContent {
        ForEach(visibleStations) { station in
            Annotation(station.stationName, coordinate: station.coordinates) {
                Circle().frame(width: 10, height: 10).foregroundColor(.white)
                    .onTapGesture {
                        selectedStation = station
                        databaseManager.showStationDetails = true
                    }
            }
        }
    }
    @MapContentBuilder
    private var selectedRouteLine: some MapContent {
        if !databaseManager.selectedRoute.isEmpty  {
            ForEach(databaseManager.selectedRoute){ route in
                if let toStation = databaseManager.stationLookup[route.to]?.coordinates,
                   let fromStation = databaseManager.stationLookup[route.from]?.coordinates{
                     MapPolyline(coordinates: [toStation, fromStation])
                         .stroke(colorFor(line: route.line), lineWidth: 10)
                 
                }

                
            }
        }
    }
    
    @MapContentBuilder
    private var visibleRoutesLines: some MapContent {
        var opacity: Double {
            databaseManager.selectedRoute.isEmpty ? 1 : 0.3
        }
            
        ForEach(visibleRoutes) { route in
            MapPolyline(coordinates: route.locationsAsCoordinates)
                .stroke(route.colour.opacity(opacity), lineWidth: 3)
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraRegion, interactionModes: [.pan, .zoom]) {
                stationAnnotations
                
                visibleRoutesLines
                    
                
                selectedRouteLine
                
                UserAnnotation()

            }
            .onMapCameraChange { self.currentregion = $0.region }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            if let _ = activeDestination{
                JourneyDurationView(activeDestination: $activeDestination)
            } else{
                MapControls(locationManager: locationManager, cameraRegion: $cameraRegion, currentRegion: $currentregion)

                SearchComp(selectedStation: $selectedStation, activeJourney: .constant([]))
            }

            
            if databaseManager.isLoading {
                ProgressView("Loading Data...", value: databaseManager.progress, total: 100)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
            }
        }
        .onChange(of: locationManager.location){
            checkForArrival()
        }
        .task {
            if stations.isEmpty {
                await databaseManager.loadAllData()
            }
            
            if databaseManager.stationLookup.isEmpty && !stations.isEmpty {
                print(" Populating station lookup from existing data...")
                databaseManager.stationLookup = Dictionary(uniqueKeysWithValues: stations.map { ($0.id, $0) })
            }
        }
        .onAppear {
            locationManager.checkLocationServicesIsEnabled()
        }

        .onChange(of: selectedStation) {
            guard let station = selectedStation else { return }
            withAnimation {
                cameraRegion = .region(MKCoordinateRegion(
                    center: station.coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                )
            }
        }
        .sheet(item: $selectedStation){ station in
            if databaseManager.showStationDetails {
                TrainArrivalView(Station: station)
            }
            
            
        }
    }
    private func checkForArrival() {
        guard let destination = activeDestination,
              let userCoordinate = locationManager.location else {
            return
        }
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)

        let distance = userLocation.distance(from: destinationLocation)
        
        let arrivalRadius = 100.0
        if distance < arrivalRadius {
            print(" User has arrived at \(destination.stationName)!")
            activeDestination = nil
        }
    }
    
    
}

struct MapControls: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var cameraRegion: MapCameraPosition
    @Binding var currentRegion: MKCoordinateRegion
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button("", systemImage: "location.circle") {
                    if let userLoc = locationManager.location {
                        withAnimation {
                            cameraRegion = .region(.init(center: userLoc, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
                        }
                    }
                }
                .frame(width: 44, height: 44).background(.thinMaterial).font(.title2).clipShape(RoundedRectangle(cornerRadius: 10))
                
                Spacer()
                
                VStack(spacing: 0) {
                    Button(action: { zoomMap(by: 0.5) }) { Image(systemName: "plus") }
                        .frame(width: 44, height: 44).background(.thinMaterial)
                    Divider().frame(width: 44)
                    Button(action: { zoomMap(by: 2.0) }) { Image(systemName: "minus") }
                        .frame(width: 44, height: 44).background(.thinMaterial)
                }
                .font(.title2).clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
    }
    
    private func zoomMap(by factor: Double) {
        var region = self.currentRegion
        region.span.latitudeDelta *= factor
        region.span.longitudeDelta *= factor
        withAnimation {
            self.cameraRegion = .region(region)
        }
    }

    
}

extension MKCoordinateRegion {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let latDelta = self.span.latitudeDelta / 2.0
        let lonDelta = self.span.longitudeDelta / 2.0
        
        let minLat = self.center.latitude - latDelta
        let maxLat = self.center.latitude + latDelta
        let minLon = self.center.longitude - lonDelta
        let maxLon = self.center.longitude + lonDelta
        
        return (coordinate.latitude >= minLat && coordinate.latitude <= maxLat) &&
               (coordinate.longitude >= minLon && coordinate.longitude <= maxLon)
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
