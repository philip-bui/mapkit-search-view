//
//  MapKitSearchViewController.swift
//  MapKitSearchView
//
//  Created by Philip on 10/11/18.
//  Copyright © 2018 Next Generation. All rights reserved.
//

import MapKit
import UIKit

public class MapKitSearchViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet public var mapView: MKMapView!
    // MARK: - Tab Views
    @IBOutlet public var close: UIButton!
    @IBAction public func closeDidTap() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    @IBOutlet private var nearMeParent: UIView!
    public var nearMe: MKUserTrackingButton?
    @IBOutlet private var compassParent: UIView!
    public var compass: MKCompassButton?
    @IBOutlet public var tabView: UIView!
    
    // MARK: - Bottom Sheet Views & Variables
    @IBOutlet public var searchBar: UISearchBar!
    @IBOutlet public var tableView: UITableView!
    // Stack view current layout height.
    @IBOutlet private var stackViewHeight: NSLayoutConstraint!
    // Stack view height if expanded.
    private var stackViewExpandedHeight: CGFloat?
    // Maximum height stack view can be dragged.
    private var stackViewMaxDraggableHeight: CGFloat {
        return view.frame.height - 120
    }
    // Maximum height for expanded stack view.
    private var stackViewMaxExpandedHeight: CGFloat {
        return view.frame.height - 180
    }
    // Maximum height for stack view when navigating map.
    private var stackViewMaxMapInteractedHeight: CGFloat {
        return max((view.frame.height - 180) / 3, searchBarHeight)
    }
    // Initial table view y offset when beginning pan.
    private var tableViewPanInitialOffset: CGFloat?
    private var tableViewHeight: CGFloat {
        return tableView.frame.height
    }
    private var tableViewContentHeight: CGFloat {
        return tableView.backgroundView?.bounds.size.height ?? tableView.contentSize.height
    }
    private var searchBarHeight: CGFloat {
        return searchBar.frame.height
    }
    private var searchBarText: String {
        return searchBar.text ?? ""
    }
    private var safeAreaInsetsBottom: CGFloat {
        return view.safeAreaInsets.bottom
    }
    private var keyboardHeight: CGFloat = 0
    private var isExpanded = false
    private var isDragged = false {
        didSet {
            if isDragged {
                searchBar.resignFirstResponder() // On drag, dismiss Keyboard
            }
        }
    }
    private var isUserMapInteracted = false {
        didSet {
            if isUserMapInteracted {
                userDidMapInteract()
            }
        }
    }
    private var isUserInteracted: Bool {
        // User interacted if dragging gesture or map interaction.
        return isDragged || isUserMapInteracted
    }
    
    // MARK: - Search Variables
    private var searchCompletionRequest: MKLocalSearchCompleter? = MKLocalSearchCompleter()
    private var searchCompletions = [MKLocalSearchCompletion]()
    
    private var searchRequestFuture: Timer?
    private var searchRequest: MKLocalSearch?
    private var searchMapItems = [MKMapItem]()
    
    private var tableViewType: TableType = .searchCompletion {
        didSet {
            switch tableViewType {
            case .searchCompletion:
                tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            case .mapItem:
                tableView.separatorInset = UIEdgeInsets(top: 0, left: 67, bottom: 0, right: 0)
            }
            tableView.reloadData()
        }
    }
    private enum TableType {
        case searchCompletion
        case mapItem
    }
    
    private var geocodeRequestFuture: Timer?
    private var geocodeRequest: CLGeocoder? = CLGeocoder()
    
    private var mapAnnotations = Set<MKPlacemark>()
    
    private let locationManager = CLLocationManager()
    
    open var delegate: MapKitSearchDelegate!
    open var tintColor: UIColor? {
        didSet {
            guard tintColor != oldValue else {
                return
            }
            close.tintColor = tintColor
            nearMe?.tintColor = tintColor
            searchBarTextField?.tintColor = tintColor
        }
    }
    open var markerTintColor: UIColor? {
        didSet {
            guard markerTintColor != oldValue else {
                return
            }
            if tableViewType == .mapItem {
                tableView.reloadData()
            }
        }
    }
    open var searchBarTextField: UITextField? {
        return searchBar.value(forKey: "searchField") as? UITextField
    }
    open var completionEnabled = true {
        didSet {
            if !completionEnabled {
                searchCompletionRequest = nil
            } else if searchCompletionRequest == nil {
                searchCompletionRequest = MKLocalSearchCompleter()
            }
        }
    }
    open var geocodeEnabled = true {
        didSet {
            if !geocodeEnabled {
                geocodeRequest = nil
            } else if geocodeRequest == nil {
                geocodeRequest = CLGeocoder()
            }
        }
    }
    open var userLocationRequest: CLAuthorizationStatus?
    open var alertSubtitle: String?
    
    convenience public init(delegate: MapKitSearchDelegate) {
        self.init(nibName: "MapKitSearchViewController", bundle: Bundle(for: MapKitSearchViewController.self))
        self.delegate = delegate
    }
    
    // MARK: - Setup
    override public func viewDidLoad() {
        super.viewDidLoad()
        nearMe = MKUserTrackingButton(mapView: mapView)
        nearMe!.frame.size = CGSize(width: 24, height: 24)
        nearMeParent.addSubview(nearMe!)
        compass = MKCompassButton(mapView: mapView)
        compassParent.addSubview(compass!)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(mapView(isPan:)))
        pan.delegate = self
        mapView.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(mapView(isPinch:)))
        pinch.delegate = self
        mapView.addGestureRecognizer(pinch)
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapView(isTap:))))
        searchBar.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(searchBar(isPan:))))
        tableView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(tableView(isPan:))))
        tableView.register(UINib(nibName: "SearchCompletionTableViewCell", bundle: Bundle(for: SearchCompletionTableViewCell.self)), forCellReuseIdentifier: "SearchCompletion")
        tableView.register(UINib(nibName: "MapItemTableViewCell", bundle: Bundle(for: MapItemTableViewCell.self)), forCellReuseIdentifier: "MapItem")
        mapView.delegate = self
        searchBar.delegate = self
        searchCompletionRequest?.region = mapView.region
        searchCompletionRequest?.delegate = self
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        locationManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Invoke didSet of respective properties.
        self.tintColor = { tintColor }()
        self.markerTintColor = { markerTintColor }()
        if let userLocationRequest = userLocationRequest {
            locationManagerRequestLocation(withPermission: userLocationRequest)
        }
        if let searchBarTextField = searchBarTextField {
            searchBarTextField.font = UIFont.systemFont(ofSize: 15)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // Recognize added Gesture Recognizer with existing MapView Gesture Recognizers.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Map Gestures
    @objc private func mapView(isPan gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            searchBar.resignFirstResponder()
            isUserMapInteracted = true
            break
        case .ended:
            // Add more results on mapView
            searchRequestInFuture(isMapPan: true)
            isUserMapInteracted = false
            break
        default:
            break
        }
    }
    
    @objc private func mapView(isPinch gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            searchBar.resignFirstResponder()
            isUserMapInteracted = true
            break
        case .ended:
            // Add more results on mapView
            searchRequestInFuture(isMapPan: true)
            isUserMapInteracted = false
            break
        default:
            break
        }
    }
    
    @objc func mapView(isTap gesture: UITapGestureRecognizer) {
        // If tap is coinciding with pan or pinch gesture, don't geocode.
        guard !isUserMapInteracted else {
            geocodeRequestCancel()
            return
        }
        // If typing or tableView scrolled, only resize bottom sheet.
        guard !searchBar.isFirstResponder && tableView.contentOffset.y == 0 else {
            geocodeRequestCancel()
            isUserMapInteracted = true
            isUserMapInteracted = false
            return
        }
        let coordinate = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocodeRequestInFuture(withLocation: location)
    }
    
    private func userDidMapInteract() {
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        searchBar.resignFirstResponder()
        if isExpanded, stackViewHeight.constant > stackViewMaxMapInteractedHeight {
            tableViewShow()
        }
    }
    
    // MARK: - Geocode
    private func geocodeRequestInFuture(withLocation location: CLLocation, timeInterval: Double = 1.5, repeats: Bool = false) {
        guard geocodeEnabled else {
            return
        }
        guard mapView.mapBoundsDistance <= 20000 else {
            // Less than 20KM (Street Level) otherwise don't geocode.
            return
        }
        geocodeRequestCancel()
        geocodeRequestFuture = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { [weak self] _ in
            guard let self = self, !self.isUserMapInteracted else {
                return
            }
            self.geocodeRequest?.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                self?.geocodeRequestDidComplete(withPlacemarks: placemarks, error: error)
            }
        }
    }
    
    public func geocodeRequestDidComplete(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        guard let originalPlacemark = placemarks?.first, let placemark = originalPlacemark.mkPlacemark else {
            return
        }
        mapKitSearch(didChoose: originalPlacemark.areasOfInterest?.first ?? originalPlacemark.name ?? originalPlacemark.address, mapItem: MKMapItem(placemark: placemark))
    }
    
    private func mapKitSearch(didChoose title: String, mapItem: MKMapItem, cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: alertSubtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.delegate.mapKitSearch(self, mapItem: mapItem)
        })
        present(alert, animated: true)
    }
    
    private func geocodeRequestCancel() {
        geocodeRequestFuture?.invalidate()
        geocodeRequest?.cancelGeocode()
    }
    
    // MARK: - Bottom Sheet Gestures
    @objc private func searchBar(isPan gesture: UIPanGestureRecognizer) {
        guard tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        let translationY = gesture.translation(in: view).y
        switch gesture.state {
        case .began:
            isDragged = true
        case .ended:
            bottomSheetDidDrag(completedTranslationY: translationY)
            break
        default:
            if translationY > 0 , let stackViewExpandedHeight = stackViewExpandedHeight {
                // Drag down. Can't drag below searchBarHeight
                stackViewHeight.constant = max(stackViewExpandedHeight - translationY, searchBarHeight)
            } else if translationY < 0 {
                // Drag up. Can't drag above stackViewMaxDraggableHeight
                if let stackViewExpandedHeight = stackViewExpandedHeight, isExpanded {
                    // stackViewExpandedHeight always contains keyboardHeight
                    stackViewHeight.constant = min(stackViewMaxDraggableHeight, stackViewExpandedHeight - translationY)
                } else {
                    stackViewHeight.constant = min(stackViewMaxDraggableHeight, searchBarHeight + keyboardHeight - translationY)
                }
            }
            break
        }
    }
    
    @objc func tableView(isPan gesture: UIPanGestureRecognizer) {
        guard tableView.numberOfRows(inSection: 0) > 0 else {
            return
        }
        let translationY = gesture.translation(in: view).y
        switch gesture.state {
        case .began:
            isDragged = true
            tableViewPanInitialOffset = tableView.contentOffset.y
            break
        case .ended:
            bottomSheetDidDrag(completedTranslationY: translationY)
            // If bounced bottom, rebounce upwards
            if tableView.contentOffset.y > tableViewContentHeight - tableView.frame.size.height {
                tableView.setContentOffset(CGPoint(x: 0, y: max(0, tableViewContentHeight - tableView.frame.size.height)), animated: true)
            }
            tableViewPanInitialOffset = nil
            break
        default:
            guard let tableViewPanInitialOffset = tableViewPanInitialOffset else {
                return
            }
            let stackViewTranslation = tableViewPanInitialOffset - translationY
            tableView.contentOffset.y = max(0, stackViewTranslation)
            if stackViewTranslation < 0, let stackViewExpandedHeight = stackViewExpandedHeight {
                stackViewHeight.constant = max(searchBarHeight, stackViewExpandedHeight + stackViewTranslation)
            }
        }
    }
    
    private func bottomSheetDidDrag(completedTranslationY translationY: CGFloat) {
        isDragged = false
        if let stackViewExpandedHeight = stackViewExpandedHeight { // Has expanded.
            if isExpanded { // If already expanded
                if stackViewExpandedHeight < 100 && translationY > 5 {
                    tableViewHide() // If bottom sheet height <100 and dragged down 5 pixels
                } else if stackViewHeight.constant > (stackViewExpandedHeight * 0.85) {
                    tableViewShow() // If dragged down < 15%
                } else {
                    tableViewHide() // If dragged down >= 15%
                }
            } else {
                if stackViewExpandedHeight < 100 && translationY < -5 {
                    tableViewShow() // If bottom sheet height <100 and dragged up 5 pixels
                } else if stackViewHeight.constant > (stackViewExpandedHeight * 0.15) {
                    tableViewShow() // If dragged up > 15%
                } else {
                    tableViewHide() // If dragged up <= 15%
                }
            }
        } else {
            tableViewHide()
        }
    }
    
    // MARK: - Search Completions
    // Search Completions Request are invoked on textDidChange in searchBar,
    // and region is updated upon regionDidChange in mapView.
    private func searchCompletionRequest(didComplete searchCompletions: [MKLocalSearchCompletion]) {
        searchRequestCancel()
        self.searchCompletions = searchCompletions
        tableViewType = .searchCompletion
        tableViewShow()
    }
    
    private func searchCompletionRequestCancel() {
        searchCompletionRequest?.delegate = nil
        searchCompletionRequest?.region = mapView.region
        searchCompletionRequest?.delegate = self
    }
    
    // MARK: - Search Map Item
    // TODO: Function too coupled with map gestures, create two functions or rename.
    private func searchRequestInFuture(withTimeInterval timeInterval: Double = 2.5, repeats: Bool = false, dismissKeyboard: Bool = false, isMapPan: Bool = false) {
        searchRequestCancel()
        // We use count of 1, as we predict search results won't change.
        if isExpanded, searchMapItems.count > 1, !searchBarText.isEmpty {
            searchRequestFuture = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { [weak self] _ in
                self?.searchRequestStart(dismissKeyboard: dismissKeyboard, isMapPan: isMapPan)
            }
        }
    }
    
    private func searchRequestCancel() {
        searchCompletionRequest?.cancel()
        searchRequestFuture?.invalidate()
        searchRequest?.cancel()
    }
    
    private func searchRequestStart(dismissKeyboard: Bool = false, isMapPan: Bool = false) {
        searchRequestCancel()
        guard !searchBarText.isEmpty else {
            searchBar.resignFirstResponder()
            searchMapItems.removeAll()
            tableView.reloadData()
            tableViewHide()
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            self?.searchRequestDidComplete(withResponse: response, error, dismissKeyboard: dismissKeyboard, isMapPan: isMapPan)
        }
        self.searchRequest = search
    }
    
    private func searchRequestDidComplete(withResponse response: MKLocalSearch.Response?, _ error: Error?, dismissKeyboard: Bool = false, isMapPan: Bool = false) {
        guard let response = response else {
            return
        }
        self.searchMapItems = response.mapItems
        self.tableViewType = .mapItem
        if isMapPan { // Add new annotations from dragging and searching new areas.
            var newAnnotations = [PlaceAnnotation]()
            for mapItem in response.mapItems {
                if !mapAnnotations.contains(mapItem.placemark) {
                    mapAnnotations.insert(mapItem.placemark)
                    newAnnotations.append(PlaceAnnotation(mapItem))
                }
            }
            mapView.addAnnotations(newAnnotations)
        } else { // Remove annotations, and resize mapView to new annotations.
            tableViewShow()
            mapAnnotations.removeAll()
            mapView.removeAnnotations(mapView.annotations)
            var annotations = [PlaceAnnotation]()
            for mapItem in response.mapItems {
                mapAnnotations.insert(mapItem.placemark)
                annotations.append(PlaceAnnotation(mapItem))
            }
            // 1 Search Result. Refer to delegate.
            if response.mapItems.count == 1, let mapItem = response.mapItems.first {
                delegate.mapKitSearch(self, mapItem: mapItem)
            }
            mapView.showAnnotations(annotations, animated: true)
            if dismissKeyboard {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    // MARK: - Bottom Sheet Animations
    func tableViewHide(duration: TimeInterval = 0.5,
                       options: UIView.AnimationOptions = [.curveEaseOut]) {
        if keyboardHeight > 0 { // If there was a previous keyboard height from dragging
            if stackViewExpandedHeight != nil, stackViewExpandedHeight! > 0 {
                stackViewExpandedHeight! -= keyboardHeight
            }
            keyboardHeight = 0
        }
        isExpanded = false
        if mapView.frame.size.height > CGFloat(searchBarHeight) {
            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                self.stackViewHeight.constant = CGFloat(self.searchBarHeight)
                if self.searchMapItems.isEmpty {
                    self.stackViewExpandedHeight = nil
                }
                self.tableView.superview?.layoutIfNeeded()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func tableViewShow(duration: TimeInterval = 0.5,
                       options: UIView.AnimationOptions = [.curveEaseInOut]) {
        isExpanded = true
        // If user is interacting with map, or showing mapItems without searching or scrolling tableView, expand bottomSheet to maxMapInteractedHeight.
        let stackViewMaxExpandedHeight = isUserMapInteracted || (tableViewType == .mapItem && !searchBar.isFirstResponder && tableView.contentOffset.y == 0) ? stackViewMaxMapInteractedHeight : self.stackViewMaxExpandedHeight
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            let safeAreaInsetsBottom = self.keyboardHeight > 0 ? self.safeAreaInsetsBottom : 0
            // Remove safeAreaInsets bottom if keyboard opened due to overlap.
            self.stackViewHeight.constant = min(stackViewMaxExpandedHeight, self.searchBarHeight + self.keyboardHeight + self.tableViewContentHeight - safeAreaInsetsBottom)
            self.stackViewExpandedHeight = self.stackViewHeight.constant
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Keyboard Animations
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        keyboardHeight = keyboardFrame.cgRectValue.size.height
        tableViewShow(duration: duration, options: UIView.AnimationOptions(rawValue: curve))
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        guard !isDragged,
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        keyboardHeight = 0
        if isExpanded { // Maintain expanded state, but lower sheet if needed.
            tableViewShow(duration: duration, options: UIView.AnimationOptions(rawValue: curve))
        } else {
            tableViewHide(duration: duration, options: UIView.AnimationOptions(rawValue: curve))
        }
    }
}
// MARK: - Map Delegate
extension MapKitSearchViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        geocodeRequestCancel()
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if view == nil {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            marker.markerTintColor = markerTintColor
            marker.clusteringIdentifier = "MapItem"
            view = marker
        }
        return view
    }
    
    public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        switch mode {
        case .follow:
            locationManagerRequestLocation()
            break
        default:
            break
        }
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        geocodeRequestCancel()
        guard let annotation = view.annotation as? PlaceAnnotation, let title = annotation.title else {
            return
        }
        mapKitSearch(didChoose: title, mapItem: annotation.mapItem) { _ in
            self.mapView.deselectAnnotation(annotation, animated: true)
        }
    }
}

// MARK: - Search Delegate
extension MapKitSearchViewController: UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchCompletionRequest(didComplete: completer.results)
    }
    
    public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchRequestFuture?.invalidate()
        if !searchText.isEmpty {
            searchCompletionRequest?.queryFragment = searchText
        }
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchCompletionRequest?.cancel()
        searchRequestFuture?.invalidate()
        // User interactions can dismiss keyboard, we prevent another search.
        if !isUserInteracted {
            searchRequestStart(dismissKeyboard: true)
        }
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchRequestStart(dismissKeyboard: true)
    }
}

// MARK: - Table Data Source
extension MapKitSearchViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewType {
        case .searchCompletion:
            return searchCompletions.count
        case .mapItem:
            return searchMapItems.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewType {
        case .searchCompletion:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCompletion", for: indexPath) as! SearchCompletionTableViewCell
            cell.viewSetup(withSearchCompletion: searchCompletions[indexPath.row])
            return cell
        case .mapItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapItem", for: indexPath) as! MapItemTableViewCell
            cell.viewSetup(withMapItem: searchMapItems[indexPath.row], tintColor: markerTintColor ?? UIColor.red)
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}

// MARK: - Table View Delegate
extension MapKitSearchViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableViewType {
        case .searchCompletion:
            guard searchCompletions.count > indexPath.row else {
                return
            }
            searchBar.text = searchCompletions[indexPath.row].title
            searchBarSearchButtonClicked(searchBar)
            break
        case .mapItem:
            guard searchMapItems.count > indexPath.row else {
                return
            }
            delegate.mapKitSearch(self, mapItem: searchMapItems[indexPath.row])
            break
        }
    }
}
extension MapKitSearchViewController: CLLocationManagerDelegate {
    public func locationManagerRequestLocation(withPermission permission: CLAuthorizationStatus? = nil) {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            break
        case .notDetermined:
            guard let permission = permission else {
                return
            }
            switch permission {
            case .authorizedAlways:
                locationManager.requestAlwaysAuthorization()
                break
            case .authorizedWhenInUse:
                locationManager.requestWhenInUseAuthorization()
                break
            default:
                break
            }
            break
        case .denied:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) { [weak self] _ in
                // TODO: Check if conflicts with locationManager(manager: didChangeAuthorization:)
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    self?.locationManager.requestLocation()
                    break
                default:
                    break
                }
            }
            break
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
            break
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        mapView.setCenter(location.coordinate, animated: true)
        manager.stopUpdatingLocation()
    }
}

// MARK: - Protocol
public protocol MapKitSearchDelegate {
    func mapKitSearch(_ mapKitSearchViewController: MapKitSearchViewController, mapItem: MKMapItem)
}

// MARK: - MKAnnotation
class PlaceAnnotation: NSObject, MKAnnotation {
    let mapItem: MKMapItem
    let coordinate: CLLocationCoordinate2D
    let title, subtitle: String?
    
    init(_ mapItem: MKMapItem) {
        self.mapItem = mapItem
        coordinate = mapItem.placemark.coordinate
        title = mapItem.name
        subtitle = nil
    }
}
