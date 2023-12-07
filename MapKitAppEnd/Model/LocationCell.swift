//
//  LocationCell.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 6.12.2023.
//

import Foundation
import UIKit

class LocationCell : UITableViewCell {
    @IBOutlet weak var locationName : UILabel!
    
    func configure (location: String)
    {
        locationName.text = location
    }
}
