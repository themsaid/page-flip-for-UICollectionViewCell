//
//  ImageSplitter.swift
//  CollectionViewAnimation
//
//  Created by Mohamed Said on 4/8/15.
//  Copyright (c) 2015 Mohamed Said. All rights reserved.
//

import Foundation
import UIKit

class ImageFactory{
    
    class func split(image: UIImage) -> (left: UIImage, right: UIImage){
        // Dimesions of the output parts
        var partWidth = image.size.width/2 * image.scale
        var partHeight = image.size.height * image.scale
        
        // Creating a Core Graphics image for the left part
        var leftFrame: CGRect = CGRectMake(0, 0, partWidth, partHeight)
        var CGLeftImage = CGImageCreateWithImageInRect(image.CGImage, leftFrame);
        
        // Creating a Core Graphics image for the right part
        var rightFrame: CGRect = CGRectMake(partWidth, 0, partWidth, partHeight)
        var CGRightImage = CGImageCreateWithImageInRect(image.CGImage, rightFrame);
        
        let leftImage = UIImage(CGImage: CGLeftImage, scale: image.scale, orientation: image.imageOrientation)
        
        let rightImage = UIImage(CGImage: CGRightImage, scale: image.scale, orientation: image.imageOrientation)
        
        return (left: leftImage!, right: rightImage!)
    }
    
    class func captureView(view: UIView) -> UIImage {
        view.layoutIfNeeded()
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, view.opaque, 0.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image;
    }
}