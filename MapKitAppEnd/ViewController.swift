import UIKit
import MapKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate{
    
    
    var matches : [MKMapItem] = []
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBarDestination : UISearchBar!
    
    @IBOutlet weak var calendarButton: UIBarButtonItem!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var carImageView: UIImageView!
    var carLocation: CLLocationCoordinate2D?
    var sourceLocation : MKMapItem?
    var destinationLocation : MKMapItem?
    var annotation = MKPointAnnotation()
    
    
    lazy var geocoder = CLGeocoder()
    
    
    
    lazy var locationManager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.distanceFilter = 10
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    var resultSearchController : UISearchController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        let locationSearchController = storyboard!.instantiateViewController(withIdentifier: "LocationSearchController") as! LocationSearchController
        locationSearchController.callback = {(location,name,item) in
            self.updateLocationonMap(to: location, with: name)
            self.sourceLocation = item
        }
        
        resultSearchController = UISearchController(searchResultsController: locationSearchController)
        resultSearchController?.searchResultsUpdater = locationSearchController as! any UISearchResultsUpdating
        
        let searchBar =  resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Enter a place for search"
        navigationItem.searchController = resultSearchController
        searchBarDestination.delegate = self
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchController.mapView = mapView
        self.mapView.delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        mapView.addGestureRecognizer(longPressRecognizer)
        
        
        
        carImageView = UIImageView(image: UIImage(named: "car-icon"))
        carImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        mapView.addSubview(carImageView)
        
       // checkForPermission()
        
    }
    @IBAction func buttonTapped(_ sender: UIButton) {
           // UIButton tıklandığında yapılacak işlemleri burada belirtin
        let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: " NotificationViewController") as! NotificationViewController
                self.navigationController?.pushViewController(secondViewController, animated: true)
       }
   
    
    func  locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse || status == .authorizedAlways)
        {
            locationManager.startUpdatingLocation()
        }
    }
    func updateLocationonMap(to location: CLLocation, with: String?) {
        let point = MKPointAnnotation()
        point.title = title
        point.coordinate = location.coordinate
        for a in self.mapView.annotations {
            self.mapView.removeAnnotation(a)
        }
        self.mapView.addAnnotation(point)
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func onLocationButtonTapped() {
        updateLocationonMap(to: locationManager.location ?? CLLocation(), with: "Test Location")
        
    }
    
    
    @objc func addAnnotation(_ recognizer : UILongPressGestureRecognizer)
    {
        if recognizer.state == .began {
            let point = recognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            mapView.removeAnnotation(annotation)
            // annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            var location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            geocoder.reverseGeocodeLocation(location) { [self] (placemarks, error) in
                
                if let error = error {
                    print("Unable to reverse code location")
                } else {
                    if let placemarks = placemarks, let placemark = placemarks.first {
                        self.searchBarDestination.text = placemark.name
                    } else {
                        self.searchBarDestination.text = "No Address Found"
                    }
                }
                
            }
            mapView.addAnnotation(annotation)
            destinationLocation = annotationToMapItem(annotation: annotation)
            displayPathBetweenTwoPoints()
        }
    }
    
    
  /*  func annotationToMapItem(annotation : MKAnnotation) -> MKMapItem {
         let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
          
        let item = MKMapItem(placemark: placemark)
        item.name = placemark.name ?? "Annotation"
        return item
    }*/
    func annotationToMapItem(annotation: MKAnnotation) -> MKMapItem {
           guard let coordinate = (annotation as? MKPointAnnotation)?.coordinate else {
               return MKMapItem()
           }

           let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
           let item = MKMapItem(placemark: placemark)
           item.name = placemark.name ?? "Annotation"
           return item
       }
    
    
    
    func displayPathBetweenTwoPoints() {
        let request = MKDirections.Request()
        request.source = sourceLocation
        request.destination = destinationLocation
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        directions.calculate {(response, error) in
            guard let response = response else {
                return
            }
            if error == nil {
                let directionsResponse = response
                let route = directionsResponse.routes.first
                let routes = directionsResponse.routes as! [MKRoute]
                for route in routes {
                    self.mapView.addOverlay(route.polyline, level : MKOverlayLevel.aboveRoads)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
                    self.calculateDistanceAndDuration(start: self.sourceLocation!.placemark.coordinate, end: self.destinationLocation!.placemark.coordinate) { (distance, duration, error) in
                        if let error = error {
                            print("Mesafe ve süre hesaplanamıyor: \(error.localizedDescription)")
                            return
                        }
                        self.distanceLabel.text = "\(distance ?? "")"
                        self.durationLabel.text = "\(duration ?? "")"
                        print("Mesafe : \(distance ?? "")")
                        print("Süre : \(duration ?? "")")
                       
                        
                    }
                }
                
            } else {
                print(error)
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyLine = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyLine)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 7
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin"){
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView.canShowCallout = true
            return annotationView
        }
    }
    func calculateDistanceAndDuration(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, completion: @escaping (String?, String?, Error?) -> Void) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile // Ulaşım tipini araç olarak ayarlayabilirsiniz
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let route = response?.routes.first else {
                completion(nil, nil, error)
                return
            }
            let distance = route.distance // Metre cinsinden mesafe
            let duration = route.expectedTravelTime // Saniye cinsinden süre
            
            // Metreyi kilometreye çevirme
            let distanceInKilometers = Measurement(value: distance, unit: UnitLength.meters).converted(to: .kilometers).value
            
            // Saniyeyi dakikaya çevirme
            let durationInMinutes = Int(duration / 60)
            
            completion(String(format: "%.2f km", distanceInKilometers), "\(durationInMinutes) dakika", nil)
        }
    }
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let mapView = mapView,
              let searchBarText = searchBar.text else {
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matches = response.mapItems
            // self.tableView.reloadData()
            let searchbarController = self.storyboard!.instantiateViewController(withIdentifier: "SearchBarController") as! SearchBarController
            searchbarController.mapView = self.mapView
            searchbarController.matches = self.matches
            
            searchbarController.callback =  {(location, name, item) in
                self.updateLocationonMap(to: location, with: name)
                // self.destinationLocation = item
                self.navigationController?.popViewController(animated: true)
                self.displayPathBetweenTwoPoints()
                
            }
            self.navigationController?.pushViewController(searchbarController, animated: true)
            
            
        }
        
    }
    
  /*  func checkForPermission(){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification()
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.dispatchNotification()
                    }
                }
            default:
                return
                
                
            }
            
        }
    }
    func dispatchNotification() {
        let identifier = "my-morning-notificaiton"
        let title = "Time to work out!"
        let body = "Don't be a lazy little butt!"
        let hour = 12
        let minute = 43
        let isDaily = true
        
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }*/
    
}


