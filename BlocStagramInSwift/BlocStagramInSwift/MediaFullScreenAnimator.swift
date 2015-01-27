//
//  MediaFullScreenAnimator.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/25/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class MediaFullScreenAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = false
    var cellImageView = UIImageView()
    
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.2
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    
        if self.presenting {
            let fullScreenVC = toViewController as MediaFullScreenViewController
    
            fromViewController.view.userInteractionEnabled = false
    
            transitionContext.containerView().addSubview(toViewController.view)
    
            let startFrame = transitionContext.containerView().convertRect(cellImageView.bounds, fromView:cellImageView)
            let endFrame = fromViewController.view.frame
    
            toViewController.view.frame = startFrame
            fullScreenVC.imageView.frame = toViewController.view.bounds
    
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
                fromViewController.view.tintAdjustmentMode = .Dimmed
    
                fullScreenVC.view.frame = endFrame
                fullScreenVC.centerScrollView()
                }, completion:  { (BOOL finished) in
                    transitionContext.completeTransition(true)
            })
        }
        else {
            let fullScreenVC = fromViewController as MediaFullScreenViewController
    
            let endFrame = transitionContext.containerView().convertRect(cellImageView.bounds, fromView: cellImageView)
            let imageStartFrame = fullScreenVC.view.convertRect(fullScreenVC.imageView.frame, fromView: fullScreenVC.scrollView)
            var imageEndFrame = transitionContext.containerView().convertRect(endFrame, toView: fullScreenVC.view)
    
            imageEndFrame.origin.y = 0
    
            fullScreenVC.view.addSubview(fullScreenVC.imageView)
            fullScreenVC.imageView.frame = imageStartFrame
            fullScreenVC.imageView.autoresizingMask = .FlexibleBottomMargin
    
            toViewController.view.userInteractionEnabled = true
    
            UIView.animateWithDuration(transitionDuration(transitionContext), animations:{
                fullScreenVC.view.frame = endFrame
                fullScreenVC.imageView.frame = imageEndFrame
    
                toViewController.view.tintAdjustmentMode = .Automatic
                }, completion: {(BOOL finished) in
                    transitionContext.completeTransition(true)
                })
        }
    }
}
