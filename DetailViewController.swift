import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var directionButton: UIButton!
    
    var property: Property?
    let geocoder = CLGeocoder()
    var userLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // property unwrap
        if let property = property{
            titleLabel.text = property.title
            detailLabel.text = property.detail
            priceLabel.text = property.price
            
            loadImage(from: property.image, into: myImageView)
            showLocationOnMap(property: property)
        }
        // CLLocationManager set up
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func directionLabel(_ sender: UIButton) {
        print(" Direction button tapped")
        
        // Check if we have both property and user location
        guard let property = property else {
            print(" No property available")
            showAlert(message: "Property information not available")
            return
        }
        
        guard let userLocation = userLocation else {
            print(" No user location available")
            showAlert(message: "User location not available. Please enable location services.")
            // Try to get location again
            locationManager.requestLocation()
            return
        }
        
        print(" Both property and user location available, navigating to direction map")
        print(" User location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        print(" Property location: \(property.latitude), \(property.longitude)")
        
        // Navigate to DirectionMapViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let directionVC = storyboard.instantiateViewController(withIdentifier: "DirectionMapVC") as? DirectionMapViewController {
            directionVC.property = property
            directionVC.userLocation = userLocation
            directionVC.modalPresentationStyle = .fullScreen
            present(directionVC, animated: true)
        } else {
            print(" Could not instantiate DirectionMapViewController")
            showAlert(message: "Could not open direction map")
        }
    }
    // Helper function to show alerts
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // શેડો સેટ કરવા માટેનો યોગ્ય સમય viewDidLayoutSubviews છે
        setupShadow()
    }
    
    // MARK: MAKE A SHADOW IN IMAGE
    func setupShadow() {
        
        // roundend courner in image
        myImageView.layer.cornerRadius = 15.0
        myImageView.clipsToBounds = true  // for rounded courner
        
    }
    
    // Image loading helper method
    func loadImage(from urlString: String, into imageView: UIImageView) {
        imageView.image = UIImage(systemName: "photo")
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Image load error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
                imageView.contentMode = .scaleAspectFill
                
                
            }
        }.resume()
    }
    
    // MapKit location
    func showLocationOnMap(property: Property) {
        let latitude = property.latitude
        let longitude = property.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        // Create a pin where property's location is
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = property.title
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - CLLocationManagerDelegate methods
    
    // This function is automatically called when we get the user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newUserLocation = locations.last, let property = property else { return }
        
        print(" Got user location: \(newUserLocation.coordinate.latitude), \(newUserLocation.coordinate.longitude)")
        
        // Store the user location
        self.userLocation = newUserLocation
        
        // Stop updating to save battery
        manager.stopUpdatingLocation()
        
        // Calculate distance and show
        showDistance(from: newUserLocation, to: property)
        
        // Show user and property location on map
        showLocationsOnMap(userLocation: newUserLocation, property: property)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(" Location manager failed with error: \(error.localizedDescription)")
        distanceLabel.text = "Distance: Unable to get location"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(" Location authorization status changed to: \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location permission granted")
            // Permission granted, now start updating location
            if CLLocationManager.locationServicesEnabled() {
                manager.startUpdatingLocation()
            }
        case .denied, .restricted:
            print(" Location services denied or restricted")
            distanceLabel.text = "Distance: Location access denied"
            showAlert(message: "Please enable location services in Settings to see distance and get directions.")
        case .notDetermined:
            print(" Location authorization not yet determined")
            break
        @unknown default:
            break
        }
    }
    
    func showDistance(from userLocation: CLLocation, to property: Property) {
        // તરત straight line distance બતાવો
        let straightDistance = DistanceCalculator.calculateStraightLineDistance(from: userLocation, to: property)
        distanceLabel.text = String(format: "Distance: %.2f km", straightDistance)
        
        print("Straight line distance: \(straightDistance) km")
        
        // હવે route distance calculate કરો
        DistanceCalculator.calculateRouteDistance(from: userLocation, to: property) { [weak self] routeDistance, travelTime in
            guard let self = self else { return }
            
            if let distance = routeDistance {
                // Route distance મળ્યું
                let timeText = travelTime != nil ? " (\(DistanceCalculator.formatTravelTime(travelTime!)))" : ""
                self.distanceLabel.text = String(format: "Distance: %.2f km%@", distance, timeText)
                print("🚗 Route distance: \(distance) km")
            } else {
                // Route calculate નહીં થયું, તો straight line distance જ રાખો
                print("⚠️ Could not calculate route distance, keeping straight line distance")
            }
        }
    }
    
    func showLocationsOnMap(userLocation: CLLocation, property: Property) {
        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Create pin for property location
        let propertyCoordinate = CLLocationCoordinate2D(latitude: property.latitude, longitude: property.longitude)
        let propertyAnnotation = MKPointAnnotation()
        propertyAnnotation.coordinate = propertyCoordinate
        propertyAnnotation.title = property.title
        mapView.addAnnotation(propertyAnnotation)
        
        // Create pin for user location
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = userLocation.coordinate
        userAnnotation.title = "Your Location"
        mapView.addAnnotation(userAnnotation)
        
        // Calculate region to show both locations
        let propertyLocation = CLLocation(latitude: property.latitude, longitude: property.longitude)
        let distance = userLocation.distance(from: propertyLocation)
        let center = CLLocationCoordinate2D(
            latitude: (userLocation.coordinate.latitude + property.latitude) / 2,
            longitude: (userLocation.coordinate.longitude + property.longitude) / 2
        )
        let region = MKCoordinateRegion(center: center, latitudinalMeters: distance * 1.8, longitudinalMeters: distance * 1.8)
        mapView.setRegion(region, animated: true)
    }
}
