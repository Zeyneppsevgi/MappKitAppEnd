//
//  LocationSearchController.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 6.12.2023.
//

import Foundation
import UIKit
import MapKit

class LocationSearchController : UITableViewController, UISearchResultsUpdating {
  
    var matches : [MKMapItem] = []
    var mapView : MKMapView? = nil
    
    var callback : ((CLLocation,String,MKMapItem)->())?
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
              let searchBarText = searchController.searchBar.text else {
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
            self.tableView.reloadData()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") else {
            fatalError()
        }
        let selectedCell = matches[indexPath.row].placemark
        cell.textLabel?.text = selectedCell.name
        let address = "\(selectedCell.thoroughfare ?? ""), \(selectedCell.locality ?? ""), \(selectedCell.subLocality ?? ""),\(selectedCell.administrativeArea ?? ""), \(selectedCell.postalCode ?? ""), \(selectedCell.country ?? "")"
        cell.detailTextLabel?.text = address
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = matches[indexPath.row].placemark
        callback?(selectedCell.location!, selectedCell.name!, matches[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
}
