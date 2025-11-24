//
//  LocationManager.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 04/09/2025.
//

import CoreLocation
import CoreLocationUI
import MapKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var manager : CLLocationManager?

    @Published var location: CLLocationCoordinate2D?
    @Published var region : MKCoordinateRegion?
    @Published var isEnabled : Bool = false
    
    func checkLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            manager = CLLocationManager()
            manager!.delegate = self
            isEnabled = true
        } else {
            print("Error accessing location services")
        }
    }
    
    private func checkAuthorizationStatus()  {
        guard let locationManager = manager else{
            return
        }
        switch locationManager.authorizationStatus {
            case .notDetermined:
            isEnabled = false
            locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
            isEnabled = false
            print("Location access denied. Please check settings")
            case .authorizedWhenInUse:
            location = manager!.location!.coordinate
            break
        default:
            break
        }
    }
    


    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }

}


