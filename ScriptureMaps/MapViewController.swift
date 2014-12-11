//
//  MapViewController.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 11/22/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: - Properties
    var geoPlaces: [GeoPlace] = [GeoPlace]()
    var singleGeoPlaceId = 0
    var locationManager : CLLocationManager!
    
    // MARK: - Outlets
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Actions
    @IBAction func setMapRegion(sender: AnyObject) {
//        var region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(40.23, -111.62), MKCoordinateSpanMake(5, 5))
//        mapView.setRegion(region, animated: true)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    // MARK: - ViewCont lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var currGeoPlace:GeoPlace? = nil
        for (key, val) in enumerate(geoPlaces) {

            if val.id == singleGeoPlaceId {
                currGeoPlace = geoPlaces[key]
            }
            
            var annotation = MKPointAnnotation()
            var geoplace = geoPlaces[key]
            
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: geoplace.latitude,
                longitude: geoplace.longitude
            )
            
            annotation.title = geoplace.placename
            annotation.subtitle = "\(geoplace.latitude), \(geoplace.longitude)"
            
            mapView.addAnnotation(annotation)
        }
        
        if currGeoPlace != nil {
            if CLLocationManager.locationServicesEnabled() {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
                
                if locationManager.location != nil {
                    var currentLocationAnnotation = MKPointAnnotation()
                    currentLocationAnnotation.coordinate = CLLocationCoordinate2D (latitude: locationManager.location.coordinate.latitude, longitude: locationManager.location.coordinate.longitude)
                    
                    currentLocationAnnotation.title = "Current Location"
                    
                    mapView.addAnnotation(currentLocationAnnotation)
                    mapView.selectAnnotation(currentLocationAnnotation, animated: true)
                } else {
                    NSLog("Problems: Location= \(locationManager.location)")
                }
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var currentGeoPlace : GeoPlace? = nil
        
        for (key, val) in enumerate(geoPlaces) {
            if val.id == singleGeoPlaceId {
                currentGeoPlace = geoPlaces[key]
            }
        }
        
        if currentGeoPlace != nil {
            
            var camera = MKMapCamera(
                lookingAtCenterCoordinate: CLLocationCoordinate2D(latitude: currentGeoPlace!.latitude, longitude: currentGeoPlace!.longitude),
                fromEyeCoordinate: CLLocationCoordinate2D(latitude: currentGeoPlace!.viewLatitude!, longitude: currentGeoPlace!.viewLongitude!),
                eyeAltitude: currentGeoPlace!.viewAltitude!)
            
            mapView.setCamera(camera, animated: true)
        } 

    }
    
    // MARK: - Map view delegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let reuseIdentifier = "Pin"
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        
        if view == nil {
            //create one
            var pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pinView.canShowCallout = true
            pinView.animatesDrop = true
            pinView.pinColor = .Purple
            
            
            view = pinView
        } else {
            view.annotation = annotation
        }
        
        return view
    }
    
    // MARK: - Location manager delegate 
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)
    
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if error != nil {
            NSLog("\(error)")
        }
    }
}

