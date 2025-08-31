// ArrivalsView.swift

import SwiftUI

struct trainArrivalsView: View {
    @StateObject private var viewModel = TrainScheduelViewModel()
    private var TfLArrivals : [UnifiedArrivalModel]{
        viewModel.scheduel.filter { $0.source.contains("TFL") }
    }
    private var NRArrivals : [UnifiedArrivalModel]{
        viewModel.scheduel.filter { $0.source.contains("NR") && !$0.lineName.contains("Elizabeth") }
    }
    
    enum ViewState {
        case loading
        case content
        case noData
    }
    
    @State private var viewState: ViewState = .loading
    
    let station : TrainStation

    var body: some View {
        VStack {
            Text(station.stationName)
                .font(.headline)
                .padding()
            switch viewState {
            case .loading:
                ProgressView()
                    .padding()
                Text("Loading arrivals for \(station.stationName)...")
                
            case .noData:
                Spacer()
                Text("No Live Arrivals Available")
                    .font(.headline)
                Text("Please alert developer if this persists.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Station:\t\(station.stationName) Type : \(station.type)")
                Spacer()
            
            case .content:
                switch station.type {
                case "T":
                    Text("Powered by TfL Open API")
                        .font(.caption)
                        .fontWeight(.light)
                case "N":
                    Text("Powered by National Rail Enquiries")
                        .font(.caption)
                        .fontWeight(.light)
                case "C":
                    Text("Powered by National Rail Enquiries & TfL API")
                        .font(.caption)
                        .fontWeight(.light)
                default:
                    Text("")
                }

                List(){
//                    Section(){
//                        Text("From TfL")
//                            .font(.headline)
//                        ForEach(TfLArrivals){arrival in
//                        TfLListItem(item: arrival)
//                        }
//                    }
//                    Section(){
//                        Text("From National Rail")
//                        ForEach(NRArrivals){arrival in
//                        NRListItem(item: arrival)}
//                    }
                    
                }

            }
            if station.type == "N" {
                Image("NRE_Powered_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 250)
            }
        }
        .task {
            
            await viewModel.loadSpecificData(id: station.uuid, type: station.type)
            
            
            if viewModel.scheduel.isEmpty {
                viewState = .noData
            } else {
                viewState = .content
            }
        }
    }
}

struct UnifiedListView : View {
    let item : UnifiedArrivalModel
    var body: some View {
        VStack{
            Text("\(item.lineName) to \(item.destinationName)")
            Text("Platform: \(item.platformName)")
            if let time = item.estimatedTime {
                Text("Departs at: \(time)")
            } else {
                Text("Arrives at: \((item.timeToEventSeconds ?? 0)/60) minutes")
            }
        }
    }
}

struct NRListItem : View {
    let item : UnifiedArrivalModel
    var body: some View {
        Text("\(item.lineName) to \(item.destinationName)")
            .font(.headline)
        Text("Platform: \(item.platformName)")
            .font(.subheadline)
            .foregroundColor(.secondary)
        
        HStack {
            Image(systemName: "train.side.rear.car")
            if let coachCount = item.coachCount {
                switch coachCount {
                case 4...6:
                    Image(systemName: "train.side.middle.car")
                    Image(systemName: "train.side.middle.car")
                case 7...8:
                    Image(systemName: "train.side.middle.car")
                    Image(systemName: "train.side.middle.car")
                    Image(systemName: "train.side.middle.car")
                case 9...20:
                    Image(systemName: "train.side.middle.car")
                    Image(systemName: "train.side.middle.car")
                    Image(systemName: "train.side.middle.car")
                    Image(systemName: "train.side.middle.car")
                default:
                    Image(systemName: "train.side.middle.car")
                }
            }
            Image(systemName: "train.side.front.car")

        }
        Text("Departs at \(item.estimatedTime)")
            .font(.body)
            .fontWeight(.bold)
        
    }
        
}
struct TfLListItem : View {
    let item : UnifiedArrivalModel
    var body: some View {
        Text("\(item.lineName) to \(item.destinationName)")
            .font(.headline)
        Text("Platform: \(item.platformName)")
            .font(.subheadline)
            .foregroundColor(.secondary)
        if let timeInSeconds = item.timeToEventSeconds {
            Text("Arriving in \(timeInSeconds / 60) mins")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.red)
        }
    }
}
