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
            manager.requestWhenInUseAuthorization()
        } else {
            completion(status == .authorizedWhenInUse || status == .authorizedAlways)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status != .notDetermined {
            onPermissionResult?(status == .authorizedWhenInUse || status == .authorizedAlways)
            onPermissionResult = nil
        }
    }
}
