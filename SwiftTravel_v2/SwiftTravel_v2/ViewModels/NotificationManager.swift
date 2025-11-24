//
//  NotificationManager.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 03/09/2025.
//

// In NotificationManager.swift

import Firebase
import FirebaseMessaging
import UserNotifications
import UIKit


class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    @Published var tokenSuccess: Bool?
    
    
    // Note: adding new lines to your database, you must also add them here.
    // Try so somehow import these from Database?
    let allLines = [
        "Bakerloo", "Central", "Circle", "District", "DLR", "Elizabeth",
        "Hammersmith & City", "Jubilee", "Metropolitan", "Northern",
        "Piccadilly", "Victoria", "Waterloo & City", "Tram", "Liberty",
        "Lioness", "Mildmay", "Suffragette", "Weaver", "Windrush",
        "SWR", "GWR", "xCountry", "Avanti", "c2c", "Chilt", "eastM",
        "gAng", "heathrowX", "LNER", "SE", "Southern", "Thameslink"
    ]
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for APNs. Device Token: \(deviceToken)")
        
        // Sets the APNs token for Firebase Messaging to use.
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permission granted.")
                
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("Notification permission denied.")
            }
        }
        
        return true
    }
    
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM registration token received: \(token)")
        tokenSuccess = true
        resubscribeToTopics()
        
    }
    
    // New Method Here. Remove if problem
    private func resubscribeToTopics() {
        print("Checking for existing subscriptions to re-apply...")
        for line in allLines {
            let topicName = line.sanitizedForTopic()
            if UserDefaults.standard.bool(forKey: "subscription_\(topicName)") {
                AppDelegate.subscribe(to: topicName)
            }
        }
    }
    

    
    static func subscribe(to topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("Error subscribing to topic '\(topic)': \(error.localizedDescription)")
            } else {
                print("Successfully subscribed to topic: '\(topic)'")
            }
            
        }
    }
    
    static func unsubscribe(from topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("Error unsubscribing from topic '\(topic)': \(error.localizedDescription)")
            } else {
                print("Successfully unsubscribed from topic: '\(topic)'")
            }
        }
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
