//
//  UIImage+RoundCorner.swift
//
//  Created by Rupesh Kumar on 10/23/15.
//  Copyright © 2015 Rupesh Kumar. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
        
    // Creates a copy of this image with rounded corners
    // If borderSize is non-zero, a transparent border of the given size will also be added
    // Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners
    func roundedCornerImage(_ cornerSize: CGFloat, borderSize: UInt) -> UIImage
    {
        // If the image does not have an alpha layer, add one
        let image: UIImage = self.imageWithAlpha()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

        // Build a context that's the same dimensions as the new size
        let context: CGContext! = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: image.cgImage!.bytesPerRow, space: image.cgImage!.colorSpace!,bitmapInfo: bitmapInfo.rawValue)
        
        // Create a clipping path with rounded corners
        context.beginPath()
        let rect :CGRect = CGRect(x: CGFloat(borderSize), y: CGFloat(borderSize), width: image.size.width - CGFloat(borderSize * 2), height: image.size.height - CGFloat(borderSize * 2))
        self.addRoundedRectToPath(rect, context:context!, ovalWidth: cornerSize, ovalHeight: cornerSize)
        context.closePath()
        (context).clip()
        
        // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        // Create a CGImage from the context
        let clippedImage: CGImage = context.makeImage()!
        
        // Create a UIImage from the CGImage
        let roundedImage: UIImage = UIImage(cgImage: clippedImage)
        return roundedImage
    }
    
    // Adds a rectangular path to the given context and rounds its corners by the given extents
    // Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners
    fileprivate func addRoundedRectToPath(_ rect: CGRect, context: CGContext, ovalWidth: CGFloat, ovalHeight: CGFloat)
    {
        if ovalWidth == 0 || ovalHeight == 0
        {
            context.addRect(rect)
            return
        }
        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: ovalWidth, y: ovalHeight)
        let fw: CGFloat = rect.width / ovalWidth
        let fh: CGFloat = rect.height / ovalHeight
        context.move(to: CGPoint(x: fw, y: fh / 2))
//        CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1)
//        CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1)
//        CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1)
//        CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1)
        context.closePath()
        context.restoreGState()
    }
    
    

    
}
