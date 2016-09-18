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
import Social

class AnnotationViewController: UITableViewController, CLLocationManagerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var modificationDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var locationButton: UIBarButtonItem!
    
    
    
    // MARK: - Location Properties
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var coordinate: CLLocationCoordinate2D?
    var updatingLocation = false
    var lastLocationError: NSError?
    var timer: NSTimer?
    
    // MARK: - Other properties
    var coreDataStack : CoreDataStack?
    var book: Book?

    var currentPage: Int?
    var image: UIImage?
    
    var observer: AnyObject!
    
    // dateFormatter
    
    var creationDate = NSDate()
    
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    var annotationToEdit: Annotation? {
        didSet {
            if let annotation = annotationToEdit {
                // Put the value of annotation to the variables so the labels and photo appears!
                descriptionText = annotation.text
                creationDate = annotation.creationDate
                currentPage = annotation.linkedPage?.integerValue
                if let latitude = annotation.location?.latitude, let longitude = annotation.location?.longitude {
                    coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue)
                }
            }
        }
    }
    
    var descriptionText = "(Text Goes Here)..."
    
    // MARK: - IBAction
    @IBAction func done() {
        
        let annotation: Annotation
        let locationObject: Location
        let photoObject: Photo

        // Paso los mismo valores de los objetos si se edita, sino se crean nuevos
        if let temp = annotationToEdit {
            annotation = temp
            photoObject = annotation.photo!
            
            //If it is in editing mode, the coordinates are the same as initial
            //locationObject.latitude = coordinate!.latitude
            //locationObject.longitude = coordinate!.longitude
            
        } else {
            // Creo una instancia de Annotation
            let annotationEntity = Annotation.entity(coreDataStack!.context)
            annotation = Annotation(entity: annotationEntity!, insertIntoManagedObjectContext: coreDataStack!.context)
            
            let locationEntity = Location.entity(coreDataStack!.context)
            locationObject = Location(entity: locationEntity!, insertIntoManagedObjectContext: coreDataStack!.context)

            let photoEntity = Photo.entity(coreDataStack!.context)
            photoObject = Photo(entity: photoEntity!, insertIntoManagedObjectContext: coreDataStack!.context)
            
            // If it is a new note, the coordinates are new and we need to save it
            locationObject.latitude = location?.coordinate.latitude
            locationObject.longitude = location?.coordinate.longitude
            
            // we need to add these values that only changes in editing mode
            annotation.creationDate = creationDate
            annotation.location = locationObject
        }
        
        
        if let photoImage = image {
            photoObject.photoData = UIImageJPEGRepresentation(photoImage, 0.5)
        }
        
        // it links location and photo with annotation
        
        annotation.photo = photoObject
        
        
        annotation.modificationDate = creationDate
        annotation.linkedPage = currentPage
        annotation.text = descriptionTextView.text
        annotation.title = "\(book!.title) -  Pag: \(currentPage!) - \(formatDate(creationDate))"
        
        //GRABO LOS VALORES AL MODELO

        book?.pdf.addAnnotationsObject(annotation)
        
        coreDataStack?.saveContext()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel() {
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
    
    
    @IBAction func shareAnnotation(sender: UIBarButtonItem) {
        

        let alert = UIAlertController(title: "Sharing note...", message: nil, preferredStyle: .Alert)
        let twitterAction = UIAlertAction(title: "Share in Twitter", style: .Default) { _ in
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc.setInitialText("\(self.descriptionTextView.text)")
            if let photoToShare = self.imageView.image {
                vc.addImage(photoToShare)
            }
            
            self.presentViewController(vc, animated: true, completion: nil)
        }
        alert.addAction(twitterAction)
        
        let facebookAction = UIAlertAction(title: "Share in Facebok", style: .Default) { _ in
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            vc.setInitialText("\(self.descriptionTextView.text)")
            if let photoToShare = self.imageView.image {
                vc.addImage(photoToShare)
            }
            self.presentViewController(vc, animated: true, completion: nil)
        }
        alert.addAction(facebookAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let annotation = annotationToEdit {
            title = "Edit Annotation"
            locationButton.enabled = false
            if let data = annotation.photo?.photoData, let image = UIImage(data: data) {
                showImage(image)
            }
        
        }
        
        updateLabels()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AnnotationViewController.hideKeyboard(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        listenForBackgroundNotification()        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        print("*** deinit \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
    


}

// MARK: - Utils
extension AnnotationViewController {
    
    func updateLabels() {
        
        pageNumberLabel.text = "\(currentPage!)"
        creationDateLabel.text = formatDate(creationDate)
        modificationDateLabel.text = formatDate(NSDate())
        descriptionTextView.text = descriptionText
        
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
        } else if let coordinate = coordinate {
            latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            
            // TEST
            //            let statusMessage: String
            //            if let error = lastLocationError {
            //                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
            //                    statusMessage = "Location Services Disabled" } else {
            //                    statusMessage = "Error Getting Location" }
            //            } else if !CLLocationManager.locationServicesEnabled() {
            //                statusMessage = "Location Services Disabled"
            //            } else if updatingLocation {
            //                statusMessage = "Searching..."
            //            } else {
            //                statusMessage = "Ready to search"
            //            }
            //            
            //            print(statusMessage)
            
        }
    }
    
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    func showImage(image: UIImage) {
        imageView.image = image
        imageView.hidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.hidden = true
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 00 && indexPath!.row == 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()
    }
    
    func listenForBackgroundNotification() {
        
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] _ in
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension AnnotationViewController {
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (indexPath.section == 0 && indexPath.row == 0) || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            pickPhoto()
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            return 88
        case (1,_):
            return imageView.hidden ? 44 : 280
        default:
            return 44
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension AnnotationViewController {
    
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
    
    // Show a alert if the Location Services is disabled in the phone
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled ", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func didTimeOut() {
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            
        }
    }
    
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

// MARK: - UIImagePickerControllerDelegate & Camera methods

extension AnnotationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: { _ in self.takePhotoWithCamera() })
        let chooseFromLibrary = UIAlertAction(title: "Choose From Library", style: .Default, handler: { _ in self.choosePhotoFromLibrary() })
        
        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibrary)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let rawImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)) {
            self.image = rawImage?.resizedImageWithContentMode(.ScaleAspectFit, bounds: CGSize(width: 260, height: 260), interpolationQuality: .Medium)
            
            dispatch_async(dispatch_get_main_queue()) {
                if let image = self.image {
                    print("Tengo imagen")
                    self.showImage(image)
                }
                
                self.tableView.reloadData()
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}


