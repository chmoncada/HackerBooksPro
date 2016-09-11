//
//  AnnotationViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 10/09/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class AnnotationViewController: UITableViewController, CLLocationManagerDelegate {

    // MARK: Properties
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var modificationDateLabel: UILabel!
    
    // Location Properties
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    var timer: NSTimer?
    
    // Other properties
    var coreDataStack : CoreDataStack?
    var book: Book?
    var currentPage: Int?
    
    @IBAction func done() {
        
        // Creo una instancia de Annotation
        let annotationEntity = Annotation.entity(coreDataStack!.context)
        let annotation = Annotation(entity: annotationEntity!, insertIntoManagedObjectContext: coreDataStack!.context)
        
        let locationEntity = Location.entity(coreDataStack!.context)
        let locationObject = Location(entity: locationEntity!, insertIntoManagedObjectContext: coreDataStack!.context)
        
        locationObject.latitude = location?.coordinate.latitude
        locationObject.longitude = location?.coordinate.longitude
        annotation.location = locationObject
        
        annotation.creationDate = NSDate()
        annotation.modificationDate = NSDate()
        annotation.linkedPage = currentPage
        
        //POR AHORA
        annotation.text = "PRUEBA"
        annotation.title = "HOLA"
        
        
        //GRABO LOS VALORES AL MODELO

        book?.pdf.addAnnotationsObject(annotation)
        
        coreDataStack?.saveContext()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func getLocation() {
        // Check the status of authorization
        let authStatus = CLLocationManager.authorizationStatus()
        
        // if the stauts is not determined, ask permission
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // Show a Alert if the authorization status is Denied or restricted
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        startLocationManager()
        updateLabels()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateLabels()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    


}

// MARK: - Utils
extension AnnotationViewController {
    
    // Show a alert if the Location Services is disabled in the phone
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled ", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        
        pageNumberLabel.text = "\(currentPage!)"
        
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            
            let statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Services Disabled" } else {
                    statusMessage = "Error Getting Location" }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Ready to search"
            }
            
            print(statusMessage)
            
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(AnnotationViewController.didTimeOut), userInfo: nil, repeats: false)
            
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            if let timer = timer {
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func didTimeOut() {
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            
        }
    }
    
}

// MARK: - CLLocationManagerDelegate

extension AnnotationViewController {
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        // Check if the time was too long
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        // Check if accuracy is less than zero (invalid) so we ignored it
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
            }
        } else if distance < 1.0 {
            
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                print("*** Force Done!")
                stopLocationManager()
                updateLabels()
            }
            
        }
    }
    
    
}
