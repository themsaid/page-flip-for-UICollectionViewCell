//
//  PhotoCollection.swift
//  CollectionViewAnimation
//
//  Created by Mohamed Said on 4/8/15.
//  Copyright (c) 2015 Mohamed Said. All rights reserved.
//

import Foundation
import UIKit


struct Photo{
    var imageName: String
    var backgroundColor: UIColor
    var text: String
    
    static func detailViewForCell(cell: UICollectionViewCell, atViewController viewController: UICollectionViewController) -> UIView{
        let view = NSBundle.mainBundle().loadNibNamed("DetailView", owner: viewController, options: nil)[0] as? UIView
        
        let indexPath = viewController.collectionView?.indexPathForCell(cell)
        
        view?.backgroundColor = PhotoCollection.collection()[(indexPath!.row + 1) % 5].backgroundColor
        
        let detailViewLabel = view?.viewWithTag(1000) as UILabel
        detailViewLabel.text = PhotoCollection.collection()[(indexPath!.row + 1) % 5].text
        
        view?.frame = cell.frame
        view?.frame.size.width = cell.frame.width * 2
        
        return view!
    }
}

class PhotoCollection{
    
    class func collection() -> [Photo]{
        return [
            Photo(
                imageName: "1",
                backgroundColor: UIColor(red:0.13, green:0.62, blue:0.52, alpha:1),
                text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."
            ),
            Photo(
                imageName: "2",
                backgroundColor: UIColor(red:0.16, green:0.5, blue:0.73, alpha:1),
                text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."
            ),
            Photo(
                imageName: "3",
                backgroundColor: UIColor(red:0.56, green:0.27, blue:0.68, alpha:1),
                text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."
            ),
            Photo(
                imageName: "4",
                backgroundColor: UIColor(red:0.89, green:0.49, blue:0.19, alpha:1),
                text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."
            ),
            Photo(
                imageName: "5",
                backgroundColor: UIColor(red:0.17, green:0.24, blue:0.31, alpha:1),
                text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."
            )
        ]
    }
    
}