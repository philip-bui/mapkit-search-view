//
//  ViewController.swift
//  Example
//
//  Created by Philip on 10/11/18.
//  Copyright © 2018 Next Generation. All rights reserved.
//

import MapKit
import MapKitSearchView
import UIKit

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let mapKit = MapKitSearchViewController(delegate: self)
        present(mapKit, animated: true, completion: nil)
    }
}

extension ViewController: MapKitSearchDelegate {
    func mapKitSearch(_ mapKitSearchViewController: MapKitSearchViewController, mapItem: MKMapItem) {
    }
}
