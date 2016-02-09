//
//  LocationService.swift
//  Black Box
//
//  Created by Samuel B Heather on 06/02/2016.
//  Copyright © 2016 Samuel Brendon Heather. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = LocationService()
    
    var lastLocation:CLLocation! = nil
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        //        // For use in foreground
        //        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("location srvs enabled")
            locationManager.delegate = self
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.headingFilter = kCLHeadingFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = manager.location
    }
    
    func getLastLocationFormattedGeoJson() -> Dictionary<String, AnyObject> {
        let lat = lastLocation.coordinate.latitude
        let lon = lastLocation.coordinate.longitude
        return ["type":"Point", "coordinates": [lat, lon]];
    }
    
    func getLastLocation() -> CLLocation! {
        return lastLocation
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
}