//
//  PDFOverviewViewController.swift
//  HackerBooksPro
//
//  Created by Charles Moncada on 31/08/16.
//  Copyright © 2016 Charles Moncada Pizarro. All rights reserved.
//  Code from https://github.com/Dean151/PDF-reader-iOS with minor fixes
//

import UIKit

class PDFOverviewViewController: UICollectionViewController {
    var currentPage: Int?
    
    var widthForPage: CGFloat {
        return UIScreen.main.bounds.width/4
    }
    
    weak var parentVC: PDFReaderViewController?
    
    var pdf: PDFDocument? {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    var document: CGPDFDocument? {
        return self.pdf?.document
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PDFOverviewViewController.closeView))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Go to", style: .plain, target: self, action: #selector(PDFOverviewViewController.choosePage))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let page = self.currentPage {
            guard let pdf = self.pdf , pdf.isPageInDocument(page) else { return }
            let indexPath = IndexPath(row: page-1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: false)
        }
    }
    
    // MARK: - Utils
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func choosePage() {
        guard let pdf = self.pdf else { return }
        let alertController = UIAlertController(title: "Go to page", message: "Choose a page number between 1 and \(pdf.numberOfPages)", preferredStyle: .alert)
        
        let sendAction = UIAlertAction(title: "Go", style: .default, handler: { (action) in
            guard let pageTextFied = alertController.textFields?[0] else { return }
            guard let pageAsked = Int(pageTextFied.text!) else { return }
            guard pdf.isPageInDocument(pageAsked) else { return }
            
            self.goToPageInParentView(pageAsked)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Page number"
            textField.keyboardType = UIKeyboardType.numberPad
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(sendAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func goToPageInParentView(_ page: Int) {
        guard let pdf = self.pdf , pdf.isPageInDocument(page) else { return }
        guard let parentVC = self.parentVC else {
            print("no encontre al parentVC")
            return
        }
        
        parentVC.shouldShowPage = page
        
        self.closeView()
    }
    
    // MARK: - CollectionView
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let pdf = self.pdf else { return 0 }
        return pdf.numberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        guard let pageSize = pdf?.rectFromPDFWithPage((indexPath as NSIndexPath).row+1)?.size else { return CGSize.zero }
        
        let scale = widthForPage/pageSize.width
        let height = pageSize.height*scale
        return CGSize(width: widthForPage, height: height);
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        cell.indexPath = indexPath
        
        let pageNumber = (indexPath as NSIndexPath).row + 1
        cell.backgroundColor = UIColor.white
        cell.pageLabel.text = "\(pageNumber)"
        cell.imageView.image = nil
        
        // Current page
        
        if pageNumber == currentPage {
            cell.layer.borderColor = CGColor.selectedBlue()
            cell.layer.borderWidth = 4
        } else {
            cell.layer.borderColor = nil
            cell.layer.borderWidth = 0
        }
        
        // Keeping expensive process to be in main queue for a smooth scrolling experience
        DispatchQueue.global(qos: .default).async {
        guard let image = self.pdf?.imageFromPDFWithPage(pageNumber) else { return } // If nil, useless to go further
            DispatchQueue.main.async {
                // Changing the image only if the cell is on screen
                if cell.indexPath == indexPath {
                    
                    // Calculate the Size of the PDF page and resize it to the cell size, because the cell size is dynamic, we need to perform this calculations
                    let pageSize = self.pdf?.rectFromPDFWithPage(pageNumber)?.size
                    let scale = self.widthForPage/pageSize!.width
                    let height = pageSize!.height*scale
                    
                    cell.imageView.image = image.resizedImageWithContentMode(.scaleAspectFit, bounds: CGSize(width: self.widthForPage, height: height), interpolationQuality: .high)
                    
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.goToPageInParentView((indexPath as NSIndexPath).row+1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}

// MARK: - Extensions of Colors
extension UIColor {
    static func selectedBlue() -> UIColor {
        return UIColor(red: (76.0/255.0), green: (161.0/255.0), blue: (255.0/255.0), alpha: 1.0)
    }
}

extension CGColor {
    static func selectedBlue() -> CGColor {
        return UIColor.selectedBlue().cgColor
    }
}
