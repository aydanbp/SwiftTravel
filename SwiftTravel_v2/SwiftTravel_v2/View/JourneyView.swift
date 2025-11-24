

import SwiftUI
import MapKit


struct JourneySelectorView: View {
    let optionalJourneys: [[Route]]
    @Binding var selectedJourneyIndex: Int
    @EnvironmentObject var databaseManager: DatabaseManager

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Journey Options")
                .font(.headline)
                .padding(.horizontal)

            List {
                ForEach(optionalJourneys.indices, id: \.self) { index in
                    JourneyDetailRow(journey: optionalJourneys[index], isSelected: index == selectedJourneyIndex)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedJourneyIndex = index
                            databaseManager.selectedRoute = optionalJourneys[index]
                        }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
        }
        .background(Color(.systemGroupedBackground))
    }
}


struct JourneyDetailRow: View {
    let journey: [Route]
    let isSelected: Bool
    @EnvironmentObject var databaseManager: DatabaseManager

    private struct JourneySegment {
        let line: String
        let fromStationName: String
        let toStationName: String
    }
    
    private var segments: [JourneySegment] {
        guard !journey.isEmpty else { return [] }

        var journeySegments: [JourneySegment] = []
        var currentLine = journey.first!.line
        var segmentStartStationID = journey.first!.from

        for i in 0..<journey.count {
            let currentRoute = journey[i]
            
            if currentRoute.line != currentLine || i == journey.count - 1 {
                let fromStationName = databaseManager.stationLookup[segmentStartStationID]?.stationName ?? "Unknown"
                let toStationName = databaseManager.stationLookup[journey[i-1].to]?.stationName ?? "Unknown"

                journeySegments.append(JourneySegment(line: currentLine, fromStationName: fromStationName, toStationName: toStationName))

                // Start the new segment
                currentLine = currentRoute.line
                segmentStartStationID = currentRoute.from
            }
            
            // Add the final segment if the loop finished on the last route
            if i == journey.count - 1 {
                let fromStationName = databaseManager.stationLookup[segmentStartStationID]?.stationName ?? "Unknown"
                let toStationName = databaseManager.stationLookup[currentRoute.to]?.stationName ?? "Unknown"

                journeySegments.append(JourneySegment(line: currentRoute.line, fromStationName: fromStationName, toStationName: toStationName))
            }
        }
        return journeySegments
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock")
                Text("\(journey.totalWeight) min") // Using the new extension
                Spacer()
                Image(systemName: "arrow.triangle.branch")
                Text("\(journey.numberOfChanges) Changes")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                ForEach(segments.indices, id: \.self) { index in
                    let segment = segments[index]
                    
                    HStack {
                        Circle()
                            .fill(colorFor(line: segment.line))
                            .frame(width: 20, height: 20)
                        
                        Text(segment.line)
                            .fontWeight(.medium)
                    }
                    
                    if index < segments.count - 1 {
                        Text("Change at \(segment.toStationName)")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .padding(.leading, 30)
                    }
                }
            }
        }
        .padding()
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .animation(.easeInOut, value: isSelected)
    }
}

struct JourneyDurationView: View {
    @Binding var activeDestination: TrainStation?
    
    
    var body: some View {
        

            VStack {
                
                VStack {
                    Spacer()
                    Text("Towards \(activeDestination) Station")
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 80)
                .padding(.vertical)
                .background(.ultraThinMaterial)
                
                
                Spacer()
                    .frame(height: 600)
                    .allowsHitTesting(false) // Allows touches to go through it
                
                VStack{
                    Spacer()
                    HStack {
                        
                        Button("Re-Route Journey", systemImage: "arrow.turn.down.left", action: {
                            
                        })
                        .foregroundStyle(.white)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                        Spacer()
                        Divider()
                        Spacer()
                        Button("Cancel Journey", systemImage: "xmark", action: {
                            
                        })
                        .foregroundStyle(.white)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .frame(width: .infinity, height: 100)
                    .padding()
                    .background(.ultraThinMaterial)
                }

            }
            
            .ignoresSafeArea(.all)
            .toolbar(.hidden, for: .tabBar)
        }
    }
