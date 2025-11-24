import SwiftData
import SwiftUI

import SwiftData
import SwiftUI

struct StatusView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.self) var environment
    
    @State private var statusManager: DisruptionManager?
    @State private var selectedLine: line?
    @State private var showDetail: Bool = false
    
    
    private var TfL_Line : [line]{
        return lines.filter { $0.type == "T" }.sorted { $0.name < $1.name }
    }
    private var NR_Line : [line]{
        return lines.filter { $0.type == "N" }.sorted { $0.name < $1.name }
    }
    
    @Query var lines: [line]
    
    var body: some View {
        let limit : Float = 100/255
        
        VStack {
            HStack {
                Text("Line Status")
                    .font(.headline)
                Spacer()
                Button("", systemImage: "arrow.clockwise") {
                    Task {
                        await statusManager?.getStatus()
                    }
                }
                .disabled(statusManager?.isLoading ?? false)
            }
            .padding(.horizontal)
            
            List {
                Section(header: Text("TfL Lines")) {
                    ForEach(TfL_Line) { line in
                        
                        let comp = line.colour.resolve(in: environment)
                        HStack {
                            StatusViewItem(line: line)
                            Spacer()
                            
                            Button(action: {
                                selectedLine = line
                                showDetail = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.title2)
                            }
                        }
                        .foregroundStyle(comp.red < limit && comp.blue < limit && comp.green < limit ? Color.white : Color.black)
                        .listRowBackground(line.colour)
                    }
                }
                
                Section(header: Text("National Rail")) {
                    ForEach(NR_Line) { line in
                        let comp = line.colour.resolve(in: environment)
                        HStack {
                            StatusViewItem(line: line)
                            
                            Spacer()
                            Button(action: {
                                selectedLine = line
                                showDetail = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.title2)
                            }
                        }
                        .foregroundStyle(comp.red < limit && comp.blue < limit && comp.green < limit ? Color.white : Color.black)
                        .listRowBackground(line.colour)
                        
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Line Status")
            .sheet(item: $selectedLine) { selected in
                StatusViewSheet2(item: selected)
            }
            .task {
                statusManager = DisruptionManager(modelContext: modelContext)
                await statusManager?.getStatus()
            }
        }
    }
}

private struct StatusViewItem: View {
    var line: line
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(line.name) Line").bold()
                if let status = line.status {
                    Text(status.statusType ?? "Good Service")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    if line.type == "T" {
                        Text("Good Service")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else{
                        Text("Loading...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                }
            }

        }
        .padding(.vertical, 4)

    }

    
}

private struct StatusViewSheet2: View {
    var item : line
    let limit : Float = 100/255
    @Environment(\.self) var environment
    
    var body: some View {
        let comp = item.colour.resolve(in: environment)
        Form{
            Section(){ //Top half
                Text(item.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                HStack{
                    if let status = item.status {
                        Text(status.statusType ?? "")
                            .font(.headline)
                    } else {
                        Text("Good Service")
                            .font(.headline)
                    }
                    Spacer()
                    SubscriptionStar(lineName: item.name)
                        .background(colorFor(line: item.name))
                }
            }
        }
        
        .padding(.horizontal)
        .cornerRadius(10)
        Section{
            if let description = item.status?.descrp, !description.isEmpty{
                Text(description)
            }
        }
        
    }
}



