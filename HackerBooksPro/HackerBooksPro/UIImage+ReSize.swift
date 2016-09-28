//
//  UIImage+ReSize.swift
//
//  Created by Rupesh Kumar on 10/19/15.
//  Copyright © 2015 Rupesh Kumar. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
        
    /**
    Return a new image square from center
    */
    func getCenterMaxSquareImageByCroppingImage(_ image: UIImage) -> UIImage
    {
        var centerSquareSize: CGSize = image.size
        let oriImgWid: CGFloat = CGFloat(image.cgImage!.width)
        let oriImgHgt: CGFloat = CGFloat(image.cgImage!.height)
        if oriImgHgt <= oriImgWid {
            centerSquareSize.width = oriImgHgt
            centerSquareSize.height = oriImgHgt
        }
        else {
            centerSquareSize.width = oriImgWid
            centerSquareSize.height = oriImgWid
        }
        let x: CGFloat = (oriImgWid - centerSquareSize.width) / 2.0
        let y: CGFloat = (oriImgHgt - centerSquareSize.height) / 2.0
        let cropRect: CGRect = CGRect(x: x, y: y, width: centerSquareSize.height, height: centerSquareSize.width)
        let imageRef: CGImage = image.cgImage!.cropping(to: cropRect)!
        let cropped: UIImage = UIImage(cgImage: imageRef)
        return cropped
    }
    
    // Returns a copy of this image that is cropped to the given bounds.
    // The bounds will be adjusted using CGRectIntegral.
    // This method ignores the image's imageOrientation setting.
    func croppedImage(_ bounds: CGRect) -> UIImage
    {
        let imageRef: CGImage = self.cgImage!.cropping(to: bounds)!
        let croppedImage: UIImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
    
    
    // Returns a copy of this image that is squared to the thumbnail size.
    // If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
    func thumbnailImage(_ thumbnailSize: Int, transparentBorder borderSize: UInt, cornerRadius: CGFloat, interpolationQuality quality: CGInterpolationQuality) -> UIImage
    {
        let thumbSizeImage:CGFloat = CGFloat( thumbnailSize)
        let resizedImage: UIImage = self.resizedImageWithContentMode(UIViewContentMode.scaleAspectFill, bounds: CGSize(width: thumbSizeImage, height: thumbSizeImage), interpolationQuality: quality)
        
        // Crop out any part of the image that's larger than the thumbnail size
        // The cropped rect must be centered on the resized image
        // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
        let cropRect: CGRect = CGRect(x: round((resizedImage.size.width - thumbSizeImage) / 2), y: round((resizedImage.size.height - thumbSizeImage) / 2), width: thumbSizeImage, height: thumbSizeImage)
        
        let croppedImage: UIImage = resizedImage.croppedImage(cropRect)
        
        let transparentBorderImage: UIImage = borderSize > 0 ? croppedImage.transparentBorderImage(CGFloat(borderSize)) : croppedImage
        return transparentBorderImage.roundedCornerImage(cornerRadius, borderSize: borderSize)
    }
    
    // Returns a rescaled copy of the image, taking into account its orientation
    // The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
    func resizedImage(_ newSize: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage
    {
        var drawTransposed: Bool
        switch self.imageOrientation
        {
        case UIImageOrientation.left,UIImageOrientation.leftMirrored,UIImageOrientation.right,UIImageOrientation.rightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }
        return self.resizedImage(newSize, transform: self.transformForOrientation(newSize), drawTransposed: drawTransposed, interpolationQuality: quality)
    }
    
    // Resizes the image according to the given content mode, taking into account the image's orientation
    func resizedImageWithContentMode(_ contentMode: UIViewContentMode, bounds: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage
    {
        let horizontalRatio: CGFloat = bounds.width / self.size.width
        let verticalRatio: CGFloat = bounds.height / self.size.height
        var ratio: CGFloat = 0
        let error: NSError = NSError.init(domain: "Error", code: 0, userInfo: nil)

        switch contentMode
        {
        case UIViewContentMode.scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case UIViewContentMode.scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        default:
            NSException.raise(NSExceptionName.invalidArgumentException, format: "Unsupported content mode: \(contentMode)", arguments: getVaList([error]))
        }
        let newSize: CGSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
        return self.resizedImage(newSize, interpolationQuality: quality)
    }
        
    // Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
    // The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
    // If the new size is not integral, it will be rounded up
    fileprivate func resizedImage(_ newSize: CGSize, transform: CGAffineTransform, drawTransposed transpose: Bool, interpolationQuality quality: CGInterpolationQuality) -> UIImage
    {
        let newRect: CGRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        let transposedRect: CGRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width)
        let imageRef: CGImage = self.cgImage!

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        // Build a context that's the same dimensions as the new size
        let bitmap: CGContext = CGContext(data: nil, width: Int(newRect.size.width), height: Int(newRect.size.height), bitsPerComponent: imageRef.bitsPerComponent, bytesPerRow: 0, space: imageRef.colorSpace!,bitmapInfo: bitmapInfo.rawValue)!
        
        // Rotate and/or flip the image if required by its orientation
        bitmap.concatenate(transform)
        
        // Set the quality level to use when rescaling
        bitmap.interpolationQuality = quality
        
        // Draw into the context; this scales the image
        bitmap.draw(imageRef, in: transpose ? transposedRect : newRect)
        
        // Get the resized image from the context and a UIImage
        let newImageRef: CGImage = bitmap.makeImage()!
        let newImage: UIImage = UIImage(cgImage:newImageRef)
        
        return newImage
    }
    
    // Returns an affine transform that takes into account the image orientation when drawing a scaled image
   fileprivate func transformForOrientation(_ newSize: CGSize) -> CGAffineTransform
    {
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch self.imageOrientation
        {
        case UIImageOrientation.down,UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: newSize.width, y: newSize.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            break;
            
        case UIImageOrientation.left,UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            break;
            
        case UIImageOrientation.right,UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: newSize.height)
            transform = transform.rotated(by: -CGFloat(M_PI_2))
            break;
            
        default:
            break;
        }
        
        switch self.imageOrientation
        {
        case UIImageOrientation.upMirrored,UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break;
            
        case UIImageOrientation.leftMirrored,UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: newSize.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break;
            
        default:
            break;
        }
        
        return transform
    }
    

    

      

}
