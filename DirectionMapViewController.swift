import UIKit
import MapKit

class DirectionMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeInfoLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var property : Property?
    var userLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(" DirectionMapViewController loaded")
        print(" User location: \(userLocation?.coordinate.latitude ?? 0), \(userLocation?.coordinate.longitude ?? 0)")
        print(" Property: \(property?.title ?? "No property"), lat: \(property?.latitude ?? 0), lon: \(property?.longitude ?? 0)")
        
        setupUI()
        setupMapview()
        
        // Check if we have the required data
        if let userLocation = userLocation, let property = property {
            print(" Both user location and property available, showing directions")
            // Add a small delay to ensure map is loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showDirection(from: userLocation, to: property)
            }
        } else {
            print(" Missing data - User location: \(userLocation != nil), Property: \(property != nil)")
            routeInfoLabel.text = " Location data not available"
            routeInfoLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        }
    }
    
    
    func setupUI() {
        
        //close button setup
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .systemBlue
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        
        //route info label setup
        routeInfoLabel.text = "Loading route..."
        routeInfoLabel.textAlignment = .center
        routeInfoLabel.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        routeInfoLabel.layer.cornerRadius = 8
    }
    
    func setupMapview() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.mapType = .standard
        
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func showDirection(from userLocation : CLLocation,to property: Property) {
        print(" Starting direction calculation...")
        print(" User location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        print(" Property location: \(property.latitude), \(property.longitude)")
        
        // Clear existing annotations and overlays
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        mapView.removeOverlays(mapView.overlays)
        
        // Create coordinates
        let sourceCoordinate = userLocation.coordinate
        let destinationCoordinate = CLLocationCoordinate2D(latitude: property.latitude, longitude: property.longitude)
        
        // Add source annotation (User Location)
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.coordinate = sourceCoordinate
        sourceAnnotation.title = "Your Location"
        sourceAnnotation.subtitle = "Starting point"
        mapView.addAnnotation(sourceAnnotation)
        
        // Add destination annotation (Property)
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationCoordinate
        destinationAnnotation.title = property.title
        destinationAnnotation.subtitle = "Property Location"
        mapView.addAnnotation(destinationAnnotation)
        
        print(" Added \(mapView.annotations.count) annotations")
        
        // Initially show both points
        let allCoordinates = [sourceCoordinate, destinationCoordinate]
        let region = regionForCoordinates(allCoordinates)
        mapView.setRegion(region, animated: true)
        
        // Create MKDirections request
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        
        // Get directions
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print(" Direction calculation error: \(error.localizedDescription)")
                    self.routeInfoLabel.text = " Route calculation failed"
                    self.routeInfoLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                    return
                }
                
                guard let response = response, let route = response.routes.first else {
                    print(" No route found in response")
                    self.routeInfoLabel.text = " No route found"
                    self.routeInfoLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                    return
                }
                
                print(" Route found! Adding polyline...")
                
                // Add route overlay to map
                self.mapView.addOverlay(route.polyline)
                
                // Update route info
                let distance = route.distance / 1000.0 // Convert to kilometers
                let time = route.expectedTravelTime / 60.0 // Convert to minutes
                
                let timeText = time < 60 ? String(format: "%.0f min", time) : String(format: "%.1f hrs", time/60)
                self.routeInfoLabel.text = String(format: " %.1f km  %@", distance, timeText)
                self.routeInfoLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                
                // Adjust map region to show entire route
                let routeRect = route.polyline.boundingMapRect
                let region = MKCoordinateRegion(routeRect)
                
                // Add padding to the region
                let paddedRegion = MKCoordinateRegion(
                    center: region.center,
                    latitudinalMeters: max(region.span.latitudeDelta * 111000 * 1.3, 2000),
                    longitudinalMeters: max(region.span.longitudeDelta * 111000 * 1.3, 2000)
                )
                
                self.mapView.setRegion(paddedRegion, animated: true)
                
                print(" Route overlay added successfully")
            }
        }
    }
    
    // Helper function to calculate region for multiple coordinates
    func regionForCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 23.0225, longitude: 72.5714),
                                      latitudinalMeters: 5000, longitudinalMeters: 5000)
        }
        
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        
        let spanLat = (maxLat - minLat) * 1.5 // Add 50% padding
        let spanLon = (maxLon - minLon) * 1.5
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(spanLat, 0.01), longitudeDelta: max(spanLon, 0.01))
        )
    }
}

// MARK: - MKMapViewDelegate
extension DirectionMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print(" Rendering overlay: \(overlay)")
        
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 6.0
            renderer.lineCap = .round
            renderer.lineJoin = .round
            renderer.alpha = 0.8
            
            print(" Polyline renderer created with color: \(renderer.strokeColor)")
            return renderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize user location annotation
        if annotation is MKUserLocation {
            return nil
        }
        
        print(" Creating annotation view for: \(annotation.title ?? "Unknown")")
        
        let identifier = "CustomPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        // Set different colors for source and destination
        if let pinView = annotationView as? MKPinAnnotationView {
            if annotation.title == "Your Location" {
                pinView.pinTintColor = .systemGreen
                print(" Green pin for user location")
            } else {
                pinView.pinTintColor = .systemRed
                print(" Red pin for property")
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print(" Added annotation views: \(views.count)")
    }
    
    func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        print(" Added overlay renderers: \(renderers.count)")
    }
}
