//
//  CollectionViewController.swift
//  CollectionViewAnimation
//
//  Created by Mohamed Said on 4/6/15.
//  Copyright (c) 2015 Mohamed Said. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    
    var indexPathOfCellBeingOpened: NSIndexPath?
    var cellBeingOpened: UICollectionViewCell?
    var positionOfcellBeingOpened: String?
    var panStartXPoint: CGFloat?
    var panEndXPoint: CGFloat?
    var imageOfCellBeingOpened: UIImageView?
    var detailViewOfCellBeingOpened: UIView?
    var firstImageOfDetailView: UIImageView?
    var lastImageOfDetailView: UIImageView?
    
    var photos: [Photo] = PhotoCollection.collection()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.delegate = self
    }
    
    @IBAction func handleDetailPan(sender: AnyObject) {
        // Here we handle closing the detail view the same way we handled opening it.
        // We detect the directopn of the gesture and the cell we are trying to hide the belonging view,
        // and then we apply the animation.
        
        // If you can
    }
    
    @IBAction func handleGesture(sender: AnyObject) {
        var location = sender.locationInView(sender as? UIView)
        location = CGPointMake(location.x, location.y + collectionView!.contentOffset.y)
        
        let velocity = panRecognizer.velocityInView(sender as? UIView)
        let centerXPoint = view.frame.width / 2
        var direction: String
        var distanceDistanceOfCompleteTransition: CGFloat
        var percentageToCompletelyOpen: CGFloat!
        
        
        if panRecognizer.state == UIGestureRecognizerState.Began {
            indexPathOfCellBeingOpened = collectionView?.indexPathForItemAtPoint(location)
            cellBeingOpened = collectionView?.cellForItemAtIndexPath(indexPathOfCellBeingOpened!)
            positionOfcellBeingOpened = (indexPathOfCellBeingOpened!.row % 2 == 0) ? "left" : "right"
            panStartXPoint = location.x
            panEndXPoint = centerXPoint + (centerXPoint - location.x) // So that the transition completes at a symmetrical distance around the center
            
            // Now we capture an image of the cell we are opening, 
            // hide the cell view itself and use the image to make the transition
            imageOfCellBeingOpened = UIImageView(image: ImageFactory.captureView(cellBeingOpened!.contentView))
            imageOfCellBeingOpened?.frame = cellBeingOpened!.frame
            imageOfCellBeingOpened?.frame.origin.y -= collectionView!.contentOffset.y
            
            // Based on the position of the cell we move the anchor point, the rotation will be around the Y axis line
            // located at the anchor point we specify.
            //
            // For cells at the left side the anchor point should be at the right side of the image,
            // and for cells at the right side the anchor point should be at the left side
            imageOfCellBeingOpened?.layer.anchorPoint = (positionOfcellBeingOpened == "left") ? CGPointMake(1.0, 0.5) : CGPointMake(0.0, 0.5)
            
            // Now we hide the cell view and user its captured image instead
            cellBeingOpened?.alpha = 0
            view.addSubview(imageOfCellBeingOpened!)
            
            detailViewOfCellBeingOpened = Photo.detailViewForCell(cellBeingOpened!, atViewController: self)
            
            // We take a snapshot of the detail view and split it into two parts
            let imagesOfDetailViewParts = ImageFactory.split(
                ImageFactory.captureView(detailViewOfCellBeingOpened!)
            )
            
            let leftPartView = UIImageView(image: imagesOfDetailViewParts.left)
            let rightPartView = UIImageView(image: imagesOfDetailViewParts.right)
            
            // Positioning the parts based on the position of the cell in the scroll view
            leftPartView.frame = cellBeingOpened!.frame
            leftPartView.frame.origin.y -= collectionView!.contentOffset.y
            
            rightPartView.frame = cellBeingOpened!.frame
            rightPartView.frame.origin.y -= collectionView!.contentOffset.y
            
            rightPartView.frame.origin.x = cellBeingOpened!.frame.width
            
            if positionOfcellBeingOpened == "left"{
                // The firstImageOfDetailView is the first image that will appear once the animation
                // starts, it's a static image that appears below the imageOfCellBeingOpened once it moves up
                firstImageOfDetailView = leftPartView
                view.addSubview(firstImageOfDetailView!)
                
                // The lastImageOfDetailView is the image that moves once the animation reaches 50%.
                // At this point imageOfCellBeingOpened will be perpendicular to the screen (hidden), only then
                // lastImageOfDetailView will appear and complete the movement to give the effect of a book flip.
                lastImageOfDetailView = rightPartView
                lastImageOfDetailView?.layer.anchorPoint = CGPointMake(0.0, 0.5) // Anchor point to the left side of the image
                view.addSubview(lastImageOfDetailView!)
                
            }else{
                firstImageOfDetailView = rightPartView
                view.addSubview(firstImageOfDetailView!)
                
                lastImageOfDetailView = leftPartView
                lastImageOfDetailView?.layer.anchorPoint = CGPointMake(1.0, 0.5) // Anchor point to the right side of the image
                view.addSubview(lastImageOfDetailView!)
            }
        }
        
        // Calculating the distance the the finger needs to move to complete the transition
        distanceDistanceOfCompleteTransition = abs(panEndXPoint! - panStartXPoint!)
        distanceDistanceOfCompleteTransition = distanceDistanceOfCompleteTransition < 100 ? 100 : distanceDistanceOfCompleteTransition
        percentageToCompletelyOpen = ((location.x - panStartXPoint!) / distanceDistanceOfCompleteTransition) * 100
        
        // Direction of movement to determine if the user is opening or closing
        direction = (velocity.x > 0) ? "right" : "left"
        
        // In case the cell is at the right, (location.x - panStartXPoint) will be a negative value causing the percentage
        // to be negative and we don't want that.
        if positionOfcellBeingOpened == "right"{
            percentageToCompletelyOpen = CGFloat(percentageToCompletelyOpen * -1)
        }
        
        if percentageToCompletelyOpen > 0 && percentageToCompletelyOpen <= 50 {
            // If the percentage is below 50% we need to hide the image of the second half of the
            // detail view until we need it, and also show the image of cell
            lastImageOfDetailView?.alpha = 0
            imageOfCellBeingOpened?.alpha = 1
            
            imageOfCellBeingOpened?.layer.transform = cellTransformToPercent(
                percentageToCompletelyOpen / 100,
                cellPosition: positionOfcellBeingOpened!,
                panDirection: direction,
                secondHalf: false
            )
            
        }else if percentageToCompletelyOpen > 50 && percentageToCompletelyOpen <= 100 {
            // Here we hide the image of the cell and show the second half of the detail view image
            lastImageOfDetailView?.alpha = 1
            imageOfCellBeingOpened?.alpha = 0
            
            lastImageOfDetailView?.layer.transform = cellTransformToPercent(
                percentageToCompletelyOpen / 100,
                cellPosition: positionOfcellBeingOpened!,
                panDirection: direction,
                secondHalf: true
            )
        }
        
        
        if(panRecognizer.state == UIGestureRecognizerState.Ended){
            if percentageToCompletelyOpen <= 50 {
                
                UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn | UIViewAnimationOptions.CurveEaseOut, animations: {
                    
                    self.imageOfCellBeingOpened?.layer.transform = self.cellTransformToPercent(
                        0 / 100,
                        cellPosition: self.positionOfcellBeingOpened!,
                        panDirection: direction,
                        secondHalf: false
                    )
                    return
                    
                    }, completion: {_ in
                        self.imageOfCellBeingOpened?.removeFromSuperview()
                        self.firstImageOfDetailView?.removeFromSuperview()
                        self.lastImageOfDetailView?.removeFromSuperview()
                        self.detailViewOfCellBeingOpened = nil
                        self.cellBeingOpened?.alpha = 1
                    }
                )
   
                
            }else{
                
                UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn | UIViewAnimationOptions.CurveEaseOut, animations: {
                    
                    self.lastImageOfDetailView?.layer.transform = self.cellTransformToPercent(
                        100 / 100,
                        cellPosition: self.positionOfcellBeingOpened!,
                        panDirection: direction,
                        secondHalf: true
                    )
                    return
                    
                    }, completion: {_ in
                        self.imageOfCellBeingOpened?.hidden = true
                        self.firstImageOfDetailView?.hidden = true
                        self.lastImageOfDetailView?.hidden = true
                        
                        self.detailViewOfCellBeingOpened!.frame.origin.x = 0
                        self.collectionView?.addSubview(self.detailViewOfCellBeingOpened!)
                        
                        // Now we create the gesture recognizer that'll handle closing the detail view
                        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleDetailPan:")
                        self.detailViewOfCellBeingOpened!.addGestureRecognizer(gestureRecognizer)
                    }
                )
                
            }
        }
        
    }
    
    func cellTransformToPercent(percent: CGFloat, cellPosition: String, panDirection: String, secondHalf: Bool) -> CATransform3D {
        var identity = CATransform3DIdentity
        var angle: CGFloat
        var percentForAngle: CGFloat
        
        identity.m34 = -1.0/2000
        
        // For the second half of the animation, the value of the angle should be decreasing.
        // At the first half the page is said to be opening, at the seonc half the page is said
        // to be closing, so the percentage should start at zero and end at zero.
        percentForAngle = secondHalf ? (1 - percent) : percent
        
        // We multiply by 2 to make the rotation of the cell to complete at 50% of the distance.
        // The other 50% we will be animating the colored background.
        angle = percentForAngle * 2 * CGFloat(M_PI_2)
        
        // Remember we have moved the anchor point to the end of the view causing the layer to move?
        // Now we have to translate the layer half the width of its original size so that it's placed right
        var translation = cellBeingOpened!.frame.width * 0.5
        
        // For the right side, the page flips by rotating anti-clockwise thus the angle need to be negative.
        //
        // Also when the anchor changes to be on the left side of the view, the translation need to happen
        // in the opposite direction.
        if cellPosition == "right"{
            angle *= -1
            translation *= -1
        }
        
        // For the second half the anchor point of the view changes thus the angle sign should be changed
        //
        // Also at the second half of the animation of a cell to the left, the view has its anchor point
        // to the left, so the translation need to happen in the opposite direction.
        if secondHalf{
            angle *= -1
            translation *= (cellPosition == "left") ? -1 : 1
        }
        
        let rotationTransform = CATransform3DRotate(identity, angle, 0.0, 1.0, 0.0)
        let translationTransform = CATransform3DMakeTranslation(translation, 0, 0)
        
        return CATransform3DConcat(rotationTransform, translationTransform)
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity = panRecognizer.velocityInView(self.view)
        
        return fabs(velocity.x) > fabs(velocity.y);
    }
    
}

extension CollectionViewController{
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        let photo = photos[((indexPath.row + 1) % 5)] as Photo
        
        let imageView = cell.viewWithTag(1000) as UIImageView
        imageView.image = UIImage(named: photo.imageName)
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let halfTheWidthOfTheWindow = collectionView.frame.width / 2
        
        return CGSizeMake(halfTheWidthOfTheWindow, halfTheWidthOfTheWindow)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
}
