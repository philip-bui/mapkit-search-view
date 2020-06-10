//
//  File.swift
//  
//
//  Created by Kevin Kieffer on 6/9/20.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D: Equatable {

    static public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
    }
    
}
