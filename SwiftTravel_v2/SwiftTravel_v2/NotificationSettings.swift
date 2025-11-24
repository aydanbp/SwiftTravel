//
//  NotificationSettings.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 05/09/2025.
//

import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Query var lines: [line]
    
    private var tflLines: [line] {
        lines.filter { $0.type == "T" }.sorted { $0.name < $1.name }
    }
    
    private var nrLines: [line] {
        lines.filter { $0.type == "N" }.sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("TfL Line Notifications"),
                        footer: Text("Select the lines for which you want to receive disruption alerts.")) {
                    ForEach(tflLines) { line in
                        SubscriptionToggle(lineName: line.name)
                    }
                }
                
                Section(header: Text("National Rail Notifications")) {
                    ForEach(nrLines) { line in
                        SubscriptionToggle(lineName: line.name)
                    }
                }
            }
            .navigationTitle("Notification Settings")
        }
    }
}

struct SubscriptionToggle: View {
    let lineName: String
    @State private var isSubscribed: Bool
    
    private var topicName: String {
        return lineName.sanitizedForTopic()
    }

    init(lineName: String) {
        self.lineName = lineName
        
        let topic = lineName.sanitizedForTopic()
        _isSubscribed = State(initialValue: UserDefaults.standard.bool(forKey: "subscription_\(topic)"))
    }
    
    var body: some View {
        Toggle(lineName, isOn: $isSubscribed)
            .onChange(of: isSubscribed) { newValue in
                updateSubscription(to: newValue)
            }
    }
    
    private func updateSubscription(to shouldSubscribe: Bool) {
        UserDefaults.standard.set(shouldSubscribe, forKey: "subscription_\(topicName)")
        
        if shouldSubscribe {
            print("UI: Subscribing to \(topicName)")
            AppDelegate.subscribe(to: topicName)
        } else {
            print("UI: Unsubscribing from \(topicName)")
            AppDelegate.unsubscribe(from: topicName)
        }
    }
}
struct SubscriptionStar: View {
    let lineName: String
    @State private var isSubscribed: Bool // State to manage if the star is filled or outlined
    
    private var topicName: String {
        return lineName.sanitizedForTopic()
    }

    init(lineName: String) {
        self.lineName = lineName
        let topic = lineName.sanitizedForTopic()
        _isSubscribed = State(initialValue: UserDefaults.standard.bool(forKey: "subscription_\(topic)"))
    }
    
    var body: some View {
        Button {
            isSubscribed.toggle()
            updateSubscription(to: isSubscribed)
        } label: {
            Image(systemName: isSubscribed ? "star.fill" : "star")
                .font(.title2)
                .foregroundColor(isSubscribed ? .yellow : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func updateSubscription(to shouldSubscribe: Bool) {
        
        UserDefaults.standard.set(shouldSubscribe, forKey: "subscription_\(topicName)")
        
        if shouldSubscribe {
            print("UI: Subscribing to \(topicName)")
            AppDelegate.subscribe(to: topicName)
        } else {
            print("UI: Unsubscribing from \(topicName)")
            AppDelegate.unsubscribe(from: topicName) 
        }
    }
}
