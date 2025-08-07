import SwiftUI
import MapKit
import SwiftData


struct MapView2 : View {
    
    @StateObject var viewModel = StationDataViewModel()
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1276),
                                           span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
    @State var cameraRegion : MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1276),
                                           span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)))
    @State var ShowingDetail = false
    @State private var searchText = ""
    @State private var secondText = ""
    @State var fromLocation: CLLocationCoordinate2D?
    @State var toLocation: CLLocationCoordinate2D?
    
    @State var expandSearch = false
    @State var expandedSize : Int = 0
    @Environment(\.colorScheme) private var colorScheme
    @State var bodyColour : Color  = Color.black
    @State var bgColour : Color  = Color.white

    private var visibleStations: [TrainStation] {
        // Only filter if the map is zoomed in enough, to avoid lag when zoomed out
        guard region.span.longitudeDelta < 0.5 else { return viewModel.stations }
        
        return viewModel.stations.filter { station in
            let stationLat = station.coordinates.latitude
            let stationLon = station.coordinates.longitude
            
            let minLat = region.center.latitude - (region.span.latitudeDelta / 2)
            let maxLat = region.center.latitude + (region.span.latitudeDelta / 2)
            let minLon = region.center.longitude - (region.span.longitudeDelta / 2)
            let maxLon = region.center.longitude + (region.span.longitudeDelta / 2)
            
            return (stationLat >= minLat && stationLat <= maxLat) && (stationLon >= minLon && stationLon <= maxLon)
        }
    }
    var body: some View {
        
        ZStack(alignment: .top) {

            Map(position: $cameraRegion, interactionModes: [.pan, .zoom]){
                
                ForEach (viewModel.stations) {station in
                    Annotation(station.stationName, coordinate: station.coordinates){
                        VStack{
                            Image(systemName: "circle")
                                .foregroundColor(bodyColour)
                                .background(bgColour)
                                .clipShape(Circle())
                                .imageScale(.small)
                        }
                        .onTapGesture {
                            viewModel.selectedStation = station
                            ShowingDetail=true
                        }
                    }
                }
                ForEach (viewModel.MapRoutes) {route in
                    if let fromStat = viewModel.stationLookup[route.from],
                       let toStat = viewModel.stationLookup[route.to] {
                        MapPolyline(coordinates: [fromStat.coordinates, toStat.coordinates])
                            .stroke(colorFor(line: route.line), lineWidth: 5)
                    }
                }
                
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .task {
                await viewModel.loadData()
            }
            
            .sheet(isPresented: $ShowingDetail) {
                if let selectedStation = viewModel.selectedStation {
                    
                    VStack {
                        Text(selectedStation.stationName)
                            .font(.title)
                            .padding()
                        
                        
                        //ArrivalsView(station: selectedStation)
                    }
                }
            }
            
            SearchBar(expandSearch: $expandSearch,viewModel: viewModel, region: $region, cameraRegion: $cameraRegion)
                .background(.ultraThinMaterial)
                .frame(width:.infinity , height: expandSearch ? 300 : 45)
                .cornerRadius(20)
                .padding()
            
                
        }
        .onChange(of: colorScheme){
            if $0 == .dark {
                bodyColour = Color.black
                bgColour = Color.white
            } else {
                bodyColour = Color.white
                bgColour = Color.black
            }
        }
        
    }
    
}





#Preview {
    MapView2()
}
