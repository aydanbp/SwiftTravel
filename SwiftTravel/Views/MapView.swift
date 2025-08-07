import SwiftUI
import MapKit
import SwiftData


struct MapView : View {
    
    @StateObject var viewModel = StationDataViewModel()
    
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1276),
                                           span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
    
    @State var ShowingDetail = false
    @State private var searchText = ""
    @State var TfLColour = Color(red: 0, green: 0.25, blue: 1.68)
    
    @State var secondSearch = false
//    @State var startLoc : CLLocationCoordinate2D
//    @State var endLoc : CLLocationCoordinate2D
    
    
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
            
//            Map{
//                ForEach (visibleStations) {station in
//                    Annotation(station.stationName, coordinate: station.coordinates){
//                        Text(station.stationName)
//                    }
//                }
//            }
//            .task {
//                await viewModel.loadData()
//            }
            
            

            
            Map(coordinateRegion: $region, annotationItems: visibleStations){ station in
                MapAnnotation(coordinate: station.coordinates) {
                    Button {
                        viewModel.selectedStation = station
                        ShowingDetail = true
                    } label: {
                        VStack {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(station.type == "T" || station.type == "C" ? TfLColour : Color.red)
                                .imageScale(region.span.longitudeDelta < 0.1 ? .large : .small)
                            
                            
                            if region.span.longitudeDelta < 0.1 {
                                Text(station.stationName)
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.primary)
                                    .padding(3)
                                    .background(.thinMaterial)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $ShowingDetail) {
                if let selectedStation = viewModel.selectedStation {
                    // Your existing sheet content is good
                    VStack {
                        Text(selectedStation.stationName)
                            .font(.title)
                            .padding()
                        
                        
                        //ArrivalsView(station: selectedStation)
                    }
                }
            }
            
            
            
            
            
            
            
            
            
//            SearchBar(expandSearch: $secondSearch, viewModel: viewModel, region: $region)
//                .frame(width: .infinity, height: secondSearch ? 300 : 100)
//                .padding(.horizontal)
//                            .background()
//                            .cornerRadius(10)
            
            
            
            
            degubInfo(region: $region, visibleNo: visibleStations.count, totalNo: viewModel.stations.count)
            
            
            
            
        }
        
    }
}


struct degubInfo: View {
    @Binding var region : MKCoordinateRegion
    @State var ZoomLevel = 0.75
    var visibleNo : Int
    var totalNo : Int
    @StateObject var viewModel = StationDataViewModel()
    
    var body: some View {
        VStack(){
            
            HStack(){ //Zoom label
                Button("+", action: {
                    region.span.latitudeDelta = region.span.latitudeDelta * ZoomLevel
                    region.span.longitudeDelta = region.span.longitudeDelta * ZoomLevel
                })
                .frame(width: 50, height: 50)
                .font(.title)
                Text("|")
                    .foregroundStyle(.gray)
                    .font(.largeTitle)
                Button("-", action: {
                    region.span.latitudeDelta = region.span.latitudeDelta / ZoomLevel
                    region.span.longitudeDelta = region.span.longitudeDelta / ZoomLevel
                })
                .frame(width: 50, height: 50)
                .font(.title)
                
            }
            .padding(10)
            .background(.thinMaterial)
            .cornerRadius(8)
            .padding(.bottom, 30) // Position it above the tab bar
            Text("Visible Stations: \(visibleNo) of \(totalNo)")
                .padding(10)
                .background(.thinMaterial)
                .cornerRadius(8)
                .padding(.bottom, 30) // Position it above the tab bar
            Text ("Region:  \(region.span)")
                .padding(10)
                .background(.thinMaterial)
                .cornerRadius(8)
                .padding(.bottom, 30) // Position it above the tab bar
        }
    }
}

#Preview {
    MapView()
}
