//
//  DisruptionManager.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 03/09/2025.
//

import SwiftUI
import SwiftData

@Observable
class DisruptionManager {
    
    var isLoading : Bool = false
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getStatus() async {
        isLoading = true
        
        let descriptor = FetchDescriptor<line>()
        guard let lines = try? modelContext.fetch(descriptor) else {
            isLoading = false
            return
        }

        await withTaskGroup(of: Void.self) { group in
            for line in lines {
                group.addTask {
                    guard var components = URLComponents(string: "https://aydanbp.pythonanywhere.com/disruption_api") else {
                        return
                    }
                    components.queryItems = [
                        URLQueryItem(name: "id", value: line.code),
                        URLQueryItem(name: "type", value: line.type)
                    ]

                    guard let url = components.url else {
                        print("Error creating URL for \(line.name)")
                        return
                    }
                    
                    do {
                        try Task.checkCancellation()
                        let (data, _) = try await URLSession.shared.data(from: url)
                        
                        let disruptions = try JSONDecoder().decode([DisruptionStatus].self, from: data)
                        
                        line.status = disruptions.first
                        
                    } catch is CancellationError{ //if view is dismissed before task finished
                        print("Task Cancelled before completion")
                    } catch { //general error catch
                        print("Error fetching or decoding status for \(line.name): \(error)")
                    }
                }
            }
        }
        
        isLoading = false
    }
}


