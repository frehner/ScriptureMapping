//
//  MapViewController.swift
//  ScriptureMaps
//
//  Created by Anthony Frehner on 11/22/14.
//  Copyright (c) 2014 Anthony Frehner. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Actions
    @IBAction func setMapRegion(sender: AnyObject) {
        var region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(40.23, -111.62), MKCoordinateSpanMake(5, 5))
        mapView.setRegion(region, animated: true)
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
        
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(40.2506, -111.65247)
        annotation.title = "Tanner Building"
        annotation.subtitle = "BYU Campus"
        
        mapView.addAnnotation(annotation)

        
        var camera = MKMapCamera(
            lookingAtCenterCoordinate: CLLocationCoordinate2DMake(40.2506, -111.65247),
            fromEyeCoordinate: CLLocationCoordinate2DMake(40.2406, -111.65247),
            eyeAltitude: 300)
        mapView.setCamera(camera, animated: animated)
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

}

