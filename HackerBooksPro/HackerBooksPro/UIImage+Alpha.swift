//
//  UIImage+Alpha.swift
//
//  Created by Rupesh Kumar on 10/23/15.
//  Copyright © 2015 Rupesh Kumar. All rights reserved.
//

import Foundation
import UIKit

extension UIImage
{
    // Returns true if the image has an alpha layer
    func hasAlpha() -> Bool
    {
        let alpha: CGImageAlphaInfo = self.cgImage!.alphaInfo
        return (alpha == CGImageAlphaInfo.first || alpha == CGImageAlphaInfo.last || alpha == CGImageAlphaInfo.premultipliedFirst || alpha == CGImageAlphaInfo.premultipliedLast)
    }
    
    
    // Returns a copy of the given image, adding an alpha channel if it doesn't already have one
    func imageWithAlpha() -> UIImage
    {
        if self.hasAlpha()
        {
            return self
        }
        
        let imageRef: CGImage = self.cgImage!
        let width: Int = imageRef.width
        let height: Int = imageRef.height
        
        // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
        let offscreenContext: CGContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: imageRef.colorSpace!, bitmapInfo: CGBitmapInfo().rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)!
        
        // Draw the image into the context and retrieve the new image, which will now have an alpha layer
        
        offscreenContext.draw(imageRef, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        let imageRefWithAlpha: CGImage = offscreenContext.makeImage()!
        let imageWithAlpha: UIImage = UIImage(cgImage:imageRefWithAlpha)
        return imageWithAlpha
        
    }
    
    
    // Returns a copy of the image with a transparent border of the given size added around its edges.
    // If the image has no alpha layer, one will be added to it.
    func transparentBorderImage(_ borderSize: CGFloat) -> UIImage
    {
        // If the image does not have an alpha layer, add one
        let image: UIImage = self.imageWithAlpha()
        
        let newRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width + borderSize * 2, height: image.size.height + borderSize * 2)
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

        
        // Build a context that's the same dimensions as the new size
        let bitmap: CGContext = CGContext(data: nil, width: Int(newRect.size.width), height: Int(newRect.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: bitmapInfo.rawValue)!
        
        // Draw the image in the center of the context, leaving a gap around the edges
        let imageLocation: CGRect = CGRect(x: borderSize, y: borderSize, width: image.size.width, height: image.size.height)
        bitmap.draw(self.cgImage!, in: imageLocation)
        let borderImageRef: CGImage = bitmap.makeImage()!
        
        // Create a mask to make the border transparent, and combine it with the image
        let maskImageRef: CGImage = self.newBorderMask(CGFloat(borderSize), size: newRect.size)
        let transparentBorderImageRef: CGImage = borderImageRef.masking(maskImageRef)!
        let transparentBorderImage: UIImage = UIImage(cgImage:transparentBorderImageRef)
        return transparentBorderImage
        
    }
    
    // Creates a mask that makes the outer edges transparent and everything else opaque
    // The size must include the entire mask (opaque part + transparent border)
    // The caller is responsible for releasing the returned reference by calling CGImageRelease
    
    fileprivate func newBorderMask(_ borderSize: CGFloat, size: CGSize) -> CGImage
    {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        
        // Build a context that's the same dimensions as the new size
        let maskContext: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGBitmapInfo().rawValue | CGImageAlphaInfo.none.rawValue)!
        
        // Start with a mask that's entirely transparent
        maskContext.setFillColor(UIColor.black.cgColor)
        maskContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Make the inner part (within the border) opaque
        maskContext.setFillColor(UIColor.white.cgColor)
        maskContext.fill(CGRect(x: borderSize, y: borderSize, width: size.width - borderSize * 2, height: size.height - borderSize * 2))
        
        // Get an image of the context
        let maskImageRef: CGImage = maskContext.makeImage()!
        
        return maskImageRef
    }

}
