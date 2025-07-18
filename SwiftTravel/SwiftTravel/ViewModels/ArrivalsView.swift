//// ArrivalsView.swift
//
//import SwiftUI
//
//struct ArrivalsView: View {
//    @StateObject private var viewModel = TFLAPIViewModel()
//    
//    // This enum helps manage the different UI states
//    enum ViewState {
//        case loading
//        case content
//        case noData
//    }
//    @State private var viewState: ViewState = .loading
//    
//    let station: Station
//
//    var body: some View {
//        VStack {
//            switch viewState {
//            case .loading:
//                ProgressView()
//                    .padding()
//                Text("Loading arrivals for \(station.stationName)...")
//            
//            case .content:
//                List(viewModel.scheduel) { arrival in
//                    VStack(alignment: .leading) {
//                        Text("\(arrival.lineName) to \(arrival.destinationName)")
//                            .font(.headline)
//                        Text("On: \(arrival.platformName)")
//                            .font(.subheadline)
//                        Text("Due in \(arrival.timeToStation / 60) mins")
//                            .font(.body)
//                            .foregroundColor(.red)
//                    }
//                }
//
//            case .noData:
//                Spacer()
//                Text("No Live Arrivals Available")
//                    .font(.headline)
//                Text("TfL does not provide live data for this station.")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                Spacer()
//            }
//        }
//        .task {
//            // Call the view model's function to load data
//            await viewModel.loadSpecificData(naptanCode: station.natpanCode)
//            
//            // After the call completes, update the view's state
//            if viewModel.scheduel.isEmpty {
//                viewState = .noData
//            } else {
//                viewState = .content
//            }
//        }
//    }
//}
