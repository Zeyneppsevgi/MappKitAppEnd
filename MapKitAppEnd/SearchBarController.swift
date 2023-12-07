//
//  SearchBarController.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 7.12.2023.
//

import Foundation
import UIKit
import MapKit

class SearchBarController : UITableViewController, UISearchBarDelegate {
  
    var matches : [MKMapItem] = []
    var mapView : MKMapView? = nil
    
    var callback : ((CLLocation, String, MKMapItem)->())?
    
 
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
