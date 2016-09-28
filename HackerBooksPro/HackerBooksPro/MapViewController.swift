//
//  MapViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 17/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    var locations: [MapLocation]? {
        //var foundLocations = [Location]()
        
        do {
            var foundMapLocations = [MapLocation]()
            let foundLocations = try coreDataStack?.context.fetch(fetchRequest)
            // To avoid the Locations without coordinates, i created a model "MapLocation" and only put Locations with coordinates
            for each in foundLocations! {
                if let latitude = each.latitude, let longitude = each.longitude {
                    let coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue)
                    let mapLocation = MapLocation(title: each.annotation.title, coordinate: coordinate, subtitle: "\(each.annotation.linkedPage!.intValue)")
                    foundMapLocations.append(mapLocation)
                }
            }
            return foundMapLocations
        } catch let error as NSError {
            print("\(error.localizedDescription)")
            return nil
        }

    }
    
    var coreDataStack: CoreDataStack?
    var book: Book?
    
    var fetchRequest: NSFetchRequest<Location> {
        
        let request = NSFetchRequest<Location>(entityName: Location.entityName())
        
        let predicate = NSPredicate(format: "annotation.bookPdf.book == %@", book!)
        request.predicate = predicate
        
        return request
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations() {
        
        let region = regionForAnnotations(locations!)
        mapView.setRegion(region, animated: true)
        
    }
    
    // MARK: - Utils
    func updateLocations() {
        
        //mapView.removeAnnotations(locations!)
        mapView.addAnnotations(locations!)
        
    }
    
    func regionForAnnotations(_ annotations: [MKAnnotation]) -> MKCoordinateRegion {
        
        var region: MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 80, longitude: -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.3
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mapView.regionThatFits(region)
        
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        
        if !locations!.isEmpty {
            showLocations()
        }
    }
    
}


