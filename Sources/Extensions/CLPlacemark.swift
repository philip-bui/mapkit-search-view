//
//  CLPlacemark.swift
//  MapKitSearchView
//
//  Created by Philip on 10/11/18.
//  Copyright © 2018 Next Generation. All rights reserved.
//

import MapKit

public extension CLPlacemark {
    public var address: String {
        var address = ""
        if let subThoroughfare = self.subThoroughfare {
            address += subThoroughfare + " "
        }
        if let thoroughfare = self.thoroughfare {
            address += thoroughfare + ", "
        }
        if let locality = self.locality {
            address += locality + " "
        }
        if let administrativeArea = self.administrativeArea {
            address += administrativeArea
        }
        return address
    }
    
    public var mkPlacemark: MKPlacemark? {
        guard let coordinate = location?.coordinate, let addressDictionary = addressDictionary as? [String: Any] else {
            return nil
        }
        return MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
    }
}
