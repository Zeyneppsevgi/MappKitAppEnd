import UIKit
import SwiftUI
import MapKit
import CoreLocation
import UserNotifications
import Combine

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
   
    
    var matches : [MKMapItem] = []
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBarDestination : UISearchBar!
    
    @IBOutlet weak var geminiButton: UIBarButtonItem!
    @IBOutlet weak var calendarButton: UIBarButtonItem!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var viewModel: CoordinateViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    var sourceLocation : MKMapItem?
    var destinationLocation : MKMapItem?
    var annotation = MKPointAnnotation()
    
    
    lazy var geocoder = CLGeocoder()
    
    private var estimatedTime = 0.0
    
    var suggestedPlacesCallback: (([String]) -> Void)?
      
    
    lazy var locationManager: CLLocationManager = {
        var manager = CLLocationManager()
        manager.distanceFilter = kCLDistanceFilterNone
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    var resultSearchController : UISearchController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Kullanıcı konum izni iste
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Harita ayarları
        mapView.showsUserLocation = true
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
        searchBar.placeholder = "Enter A Place For Search"
        navigationItem.searchController = resultSearchController
        searchBarDestination.delegate = self
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchController.mapView = mapView
        self.mapView.delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        mapView.addGestureRecognizer(longPressRecognizer)
        
        geminiButton.target = self
        geminiButton.action = #selector(geminiButtonTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
        
        
        viewModel = CoordinateViewModel()
               
               // Combine kullanarak koordinatları gözlemle
               viewModel.coordinatePublisher
                   .sink { [weak self] coordinates in
                       self?.updateMap(with: coordinates)
                       print("çalıştı")
                   }
                   .store(in: &cancellables)
        
    }
    func updateMap(with coordinates: [(String, String)]) {
            mapView.removeAnnotations(mapView.annotations)
            
            for coordinate in coordinates {
                if let latitude = Double(coordinate.0), let longitude = Double(coordinate.1) {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    mapView.addAnnotation(annotation)
                }
            }
            
            if let firstCoordinate = coordinates.first,
               let latitude = Double(firstCoordinate.0),
               let longitude = Double(firstCoordinate.1) {
                let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                mapView.setRegion(region, animated: true)
            }
        }
    @objc func dismissKeyboard() {
           view.endEditing(true)
       }
    @IBAction func buttonTapped(_ sender: UIButton) {
        // UIButton tıklandığında yapılacak işlemleri burada belirt
        //  let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: " NotificationViewController") as! NotificationViewController
        // secondViewController.estimatedTime = self.estimatedTime
        // self.navigationController?.pushViewController(secondViewController, animated: true)
        
        // bu şekilde
        let sheetViewController = NotificationViewController()
        sheetViewController.estimatedTime = self.estimatedTime
        if let sheet = sheetViewController.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(sheetViewController, animated: true)
    }
    @IBAction func geminiButtonTapped(_ sender: Any) {
         // ContentView'ı UIHostingController içine yerleştir
         var contentView = ContentView(onSuggestedPlaces: addSuggestedPlacesToMap)
         contentView.onSuggestedPlaces = { [weak self] places in
             self?.addSuggestedPlacesToMap(places)
      
             // Önerilen yerler haritaya eklendikten sonra bir süre bekleyip geri dön
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self?.navigationController?.popViewController(animated: true)
                    }

         }
         let hostedController = UIHostingController(rootView: contentView)
         
         // ContentView'a geçiş yap
         navigationController?.pushViewController(hostedController, animated: true)
     }
     
     func addSuggestedPlacesToMap(_ places: [String]) {
         // Haritadaki mevcut anotasyonları temizle
         DispatchQueue.main.async {
             self.mapView.removeAnnotations(self.mapView.annotations)
         }

         
         let geocoder = CLGeocoder()
         
         for place in places {
             geocoder.geocodeAddressString(place) { [weak self] (placemarks, error) in
                 guard let placemarks = placemarks, let placemark = placemarks.first else {
                     print("Geocode failed with error: \(error?.localizedDescription ?? "unknown error")")
                     return
                 }
                 
                 let annotation = MKPointAnnotation()
                 annotation.title = place
                 annotation.coordinate = placemark.location!.coordinate
                 self?.mapView.addAnnotation(annotation)
             }
         }
     }
     
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        
        
        // Pil tasarrufu için konum güncellemeyi durdur
        locationManager.stopUpdatingLocation()
        
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
 
    func updateLocationonMap(to location: CLLocation, with: String?) {
        let point = MKPointAnnotation()
        point.title = title
        point.coordinate = location.coordinate
        //eklendi
      //  mapView.removeAnnotation(mapView.annotations as! MKAnnotation)
        for a in self.mapView.annotations {
            self.mapView.removeAnnotation(a)
        }
        self.mapView.addAnnotation(point)
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func onLocationButtonTapped() {
        updateLocationonMap(to: locationManager.location ?? CLLocation(), with: "Test Location")
        if let userLocation = locationManager.location {
            updateLocationonMap(to: userLocation, with: "My Location")
            sourceLocation = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
            displayPathBetweenTwoPoints()
        } else {
            // Hata durumu, konum alınamadı
            print("Konum bilgisi alınamıyor.")
        }
        getDirections()
        
    }
    
    
    @objc func addAnnotation(_ recognizer : UILongPressGestureRecognizer)
    {
        if recognizer.state == .began {
            let point = recognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            mapView.removeAnnotation(annotation)
            mapView.removeOverlays(mapView.overlays)
            //annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
            // mapView.addAnnotation(annotation)
            destinationLocation = annotationToMapItem(annotation: annotation)
            displayPathBetweenTwoPoints()
        }
    }
    
    
    
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
    func getDirections() {
        if let currentLocation = locationManager.location, let destination = destinationLocation {
            // Mevcut konumdan seçilen konuma yönlendirme almak için
            sourceLocation = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
            displayPathBetweenTwoPoints()
        } else {
            // Kullanıcının bir yer seçmesini bekleyin veya bir mesaj gösterin
            print("Lütfen bir yer seçin.")
        }
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
            self.estimatedTime = Double(durationInMinutes)
            
            completion(String(format: "%.2f km", distanceInKilometers), "\(durationInMinutes) dakika", nil)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // guard let mapView = mapView,
        //    let searchBarText = searchBar.text else {
        //   return
        //  }
        guard let searchBarText = searchBar.text else {
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
            // self.matches = response.mapItems
            if let firstMapItem = response.mapItems.first {
                let location = firstMapItem.placemark.coordinate
           //     self.mapView.removeAnnotation(self.mapView.annotations as! MKAnnotation)
                self.mapView.removeOverlays(self.mapView.overlays)
                self.updateLocationonMap(to: CLLocation(latitude: location.latitude, longitude: location.longitude), with: searchBarText)
                self.destinationLocation = firstMapItem
                self.displayPathBetweenTwoPoints()
                // İlk dönüş olarak gelen yerin koordinatlarını alıp haritada pinle
                // let location = firstMapItem.placemark.coordinate
                //self.updateLocationonMap(to: CLLocation(latitude: location.latitude, longitude: location.longitude), with: searchBarText)
            }
            //haritada dokunarak pinleme
            // let searchbarController = self.storyboard!.instantiateViewController(withIdentifier: "SearchBarController") as! SearchBarController
            // searchbarController.mapView = self.mapView
            // searchbarController.matches = self.matches
            
            //searchbarController.callback =  {(location, name, item) in
            //  self.updateLocationonMap(to: location, with: name)
            // self.destinationLocation = item
            //  self.navigationController?.popViewController(animated: true)
            // self.displayPathBetweenTwoPoints()
            //   self.getDirections()
            
            //   }
            //  self.navigationController?.pushViewController(searchbarController, animated: true)
            
            
        }
        
    }
    
    
}
extension ViewController: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // Alt sayfa kapatıldığında yapılacak işlemler
    }
}





