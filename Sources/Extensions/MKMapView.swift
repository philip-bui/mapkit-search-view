//
//  MKMapView.swift
//  MapKitSearchView
//
//  Created by Philip on 10/11/18.
//  Copyright © 2018 Next Generation. All rights reserved.
//

import MapKit

public typealias MKMapBounds = (northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D)
public extension MKMapView {
    public var mapBounds: MKMapBounds {
        let northEastPoint = CGPoint(x: bounds.origin.x + bounds.size.width, y: bounds.origin.y)
        let southWestPoint = CGPoint(x: bounds.origin.x, y: bounds.origin.y + bounds.size.height)
        return (convert(northEastPoint, toCoordinateFrom: self), convert(southWestPoint, toCoordinateFrom: self))
    }
    
    public var mapBoundsDistance: CLLocationDistance {
        let mapBounds = self.mapBounds
        let northEastLocation = CLLocation(latitude: mapBounds.northEast.latitude, longitude: mapBounds.northEast.longitude)
        let southWestLocation = CLLocation(latitude: mapBounds.southWest.latitude, longitude: mapBounds.southWest.longitude)
        return northEastLocation.distance(from: southWestLocation)
    }
}
