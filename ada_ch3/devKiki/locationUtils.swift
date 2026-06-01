//
//  locationUtils.swift
//  ada_ch3
//
//  Created by kiki on 29/05/26.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var onPermissionResult: ((Bool) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocationAccess(completion: @escaping (Bool) -> Void) {
        self.onPermissionResult = completion
        
        let status = manager.authorizationStatus
        if status == .notDetermined {
            // Force the system prompt to appear
            manager.requestWhenInUseAuthorization()
        } else {
            // If already determined (Allowed or Denied previously), return the result immediately
            completion(status == .authorizedWhenInUse || status == .authorizedAlways)
        }
    }
    
    // This delegate method handles what happens RIGHT after the user acts on the popup
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status != .notDetermined {
            onPermissionResult?(status == .authorizedWhenInUse || status == .authorizedAlways)
            // Clear the completion block so it doesn't accidentally trigger multiple times
            onPermissionResult = nil
        }
    }
}
