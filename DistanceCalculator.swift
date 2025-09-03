//
//  DistanceCalculator.swift
//  PropertyList APP
//
//  Created by Droisys on 28/08/25.
//

import Foundation
import MapKit
import CoreLocation

class DistanceCalculator {
    
    //Straight line distance calculate 
    static func calculateStraightLineDistance(from userLocation: CLLocation, to property: Property) -> Double {
        let propertyLocation = CLLocation(latitude: property.latitude, longitude: property.longitude)
        let distanceInMeters = userLocation.distance(from: propertyLocation)
        return distanceInMeters / 1000.0 // કિલોમીટરમાં return કરે છે
    }
    
    /// calculate the route distance 
    static func calculateRouteDistance(from userLocation: CLLocation,
                                       to property: Property,
                                       transportType: MKDirectionsTransportType = .automobile,
                                       completion: @escaping (Double?, TimeInterval?) -> Void) {
        
        let sourceCoordinate = userLocation.coordinate
        let destinationCoordinate = CLLocationCoordinate2D(latitude: property.latitude, longitude: property.longitude)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = transportType
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Route calculation error: \(error.localizedDescription)")
                    completion(nil, nil)
                    return
                }
                
                guard let route = response?.routes.first else {
                    print("❌ No route found")
                    completion(nil, nil)
                    return
                }
                
                let routeDistanceKm = route.distance / 1000.0
                let travelTimeSeconds = route.expectedTravelTime
                
                print("✅ Route found: \(String(format: "%.2f", routeDistanceKm)) km, \(String(format: "%.0f", travelTimeSeconds/60)) minutes")
                
                completion(routeDistanceKm, travelTimeSeconds)
            }
        }
    }
    
    //Format time for helper method
    static func formatTravelTime(_ seconds: TimeInterval) -> String {
        let minutes = seconds / 60.0
        if minutes < 60 {
            return String(format: "%.0f min", minutes)
        } else {
            let hours = minutes / 60.0
            return String(format: "%.1f hrs", hours)
        }
    }
}
