//
//  LocationService.swift
//  CheckedIn
//
//  Created by sushant tiwari on 14/04/26.
//

import CoreLocation
import Observation

@Observable
class LocationService: NSObject, CLLocationManagerDelegate {
    var currentLocation: CLLocation? = nil
    var currentLocationName: String = "Unknown Location"
    var permissionDenied: Bool = false

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermissionAndStart() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            permissionDenied = true
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        reverseGeocode(location)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            permissionDenied = false
            manager.startUpdatingLocation()
        case .denied, .restricted:
            permissionDenied = true
        default:
            break
        }
    }

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first, error == nil else { return }
            var parts: [String] = []
            if let name = placemark.name { parts.append(name) }
            if let area = placemark.subLocality ?? placemark.locality { parts.append(area) }
            self?.currentLocationName = parts.joined(separator: " — ")
        }
    }
}
