//
//  MapItemTableViewCell.swift
//  MapKitSearchView
//
//  Created by Philip on 10/11/18.
//  Copyright © 2018 Next Generation. All rights reserved.
//

import MapKit
import UIKit

public class MapItemTableViewCell: UITableViewCell {
    func viewSetup(withMapItem mapItem: MKMapItem, tintColor: UIColor? = nil) {
        textLabel?.text = mapItem.name
        detailTextLabel?.text = mapItem.placemark.title
        imageView?.tintColor = tintColor
    }
}
