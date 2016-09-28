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
    var timer: Timer?
    
    // MARK: - Other properties
    var coreDataStack : CoreDataStack?
    var book: Book?

    var currentPage: Int?
    var image: UIImage?
    
    var observer: AnyObject!
    
    // dateFormatter
    var creationDate = Date()
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var annotationToEdit: Annotation? {
        didSet {
            if let annotation = annotationToEdit {
                // Put the value of annotation to the variables so the labels and photo appears!
                descriptionText = annotation.text
                creationDate = annotation.creationDate as Date
                currentPage = annotation.linkedPage?.intValue
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
            
        } else {
            // Creo una instancia de Annotation
            let annotationEntity = Annotation.entity(coreDataStack!.context)
            annotation = Annotation(entity: annotationEntity!, insertInto: coreDataStack!.context)
            
            let locationEntity = Location.entity(coreDataStack!.context)
            locationObject = Location(entity: locationEntity!, insertInto: coreDataStack!.context)

            let photoEntity = Photo.entity(coreDataStack!.context)
            photoObject = Photo(entity: photoEntity!, insertInto: coreDataStack!.context)
            
            // If it is a new note, the coordinates are new and we need to save it
            locationObject.latitude = location?.coordinate.latitude as NSNumber?
            locationObject.longitude = location?.coordinate.longitude as NSNumber?
            
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
        annotation.linkedPage = currentPage as NSNumber?
        annotation.text = descriptionTextView.text
        annotation.title = "\(formatDate(creationDate))"
        
        //GRABO LOS VALORES AL MODELO

        book?.pdf.addAnnotationsObject(annotation)
        book?.annotationsChanged = true
        
        //coreDataStack?.saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
       dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getLocation() {
        // Check the status of authorization
        let authStatus = CLLocationManager.authorizationStatus()
        
        // if the stauts is not determined, ask permission
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // Show a Alert if the authorization status is Denied or restricted
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        startLocationManager()
        updateLabels()
    }
    
    
    @IBAction func shareAnnotation(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Sharing note...", message: nil, preferredStyle: .alert)
        let twitterAction = UIAlertAction(title: "Share in Twitter", style: .default) { _ in
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("\(self.descriptionTextView.text)")
            if let photoToShare = self.imageView.image {
                vc?.add(photoToShare)
            }
            
            self.present(vc!, animated: true, completion: nil)
        }
        alert.addAction(twitterAction)
        
        let facebookAction = UIAlertAction(title: "Share in Facebok", style: .default) { _ in
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            vc?.setInitialText("\(self.descriptionTextView.text)")
            if let photoToShare = self.imageView.image {
                vc?.add(photoToShare)
            }
            self.present(vc!, animated: true, completion: nil)
        }
        alert.addAction(facebookAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let annotation = annotationToEdit {
            title = "Edit Annotation"
            locationButton.isEnabled = false
            if let data = annotation.photo?.photoData, let image = UIImage(data: data as Data) {
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
        //print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - Utils
extension AnnotationViewController {
    
    func updateLabels() {
        
        pageNumberLabel.text = "\(currentPage!)"
        creationDateLabel.text = formatDate(creationDate)
        modificationDateLabel.text = formatDate(Date())
        
        if let _ = annotationToEdit {
            descriptionTextView.text = descriptionText
        }
        
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
        } else if let coordinate = coordinate {
            latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            
        }
    }
    
    func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func showImage(_ image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.isHidden = true
    }
    
    func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && (indexPath! as NSIndexPath).section == 00 && (indexPath! as NSIndexPath).row == 0 {
            return
        }
        
        descriptionTextView.resignFirstResponder()
    }
    
    func listenForBackgroundNotification() {
        
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { [weak self] _ in
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismiss(animated: false, completion: nil)
                }
                strongSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
    
}

// MARK: - UITableViewDelegate

extension AnnotationViewController {
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if ((indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0) || (indexPath as NSIndexPath).section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0,0):
            return 88
        case (1,_):
            return imageView.isHidden ? 44 : 280
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
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(AnnotationViewController.didTimeOut), userInfo: nil, repeats: false)
            
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
        let alert = UIAlertController(title: "Location Services Disabled ", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func didTimeOut() {
        //print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("didFailWithError \(error)")
        
        let code = (error as NSError).code
        if code == CLError.Code.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error as NSError?
        
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        //print("didUpdateLocations \(newLocation)")
        
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
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                //print("*** We're done!")
                stopLocationManager()
            }
        } else if distance < 1.0 {
            
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            
            if timeInterval > 10 {
                //print("*** Force Done!")
                stopLocationManager()
                updateLabels()
            }
            
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & Camera methods

extension AnnotationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera() })
        let chooseFromLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary() })
        
        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibrary)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame
        
        present(alertController, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let rawImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        DispatchQueue.global(qos: .default).async {
            self.image = rawImage?.resizedImageWithContentMode(.scaleAspectFit, bounds: CGSize(width: 260, height: 260), interpolationQuality: .medium)
            
            DispatchQueue.main.async {
                if let image = self.image {
                    //print("Tengo imagen")
                    self.showImage(image)
                }
                
                self.tableView.reloadData()
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}


