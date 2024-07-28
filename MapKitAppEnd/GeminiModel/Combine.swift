//
//  Combine.swift
//  MapKitAppEnd
//
//  Created by Zeynep Sevgi on 28.07.2024.
//

import Foundation
import SwiftUI
import Combine

class CoordinateViewModel: ObservableObject {
    @Published var coordinates: [(String, String)] = []
    
    var coordinatePublisher = PassthroughSubject<[(String, String)], Never>()
}
