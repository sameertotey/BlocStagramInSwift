//
//  MediaFullScreenViewController.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/25/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class MediaFullScreenViewController: UIViewController {
    
    var mediaItem: Media? {
        didSet {
            if let image = mediaItem?.image {
                if imageView != nil && scrollView != nil {
                    imageView.image = image
                    scrollView.contentSize = image.size
                }
            }
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet var doubleTapGestureRecognizer: UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let image = mediaItem?.image {
            imageView.image = image
            scrollView.contentSize = image.size
        }

        tapGestureRecognizer.addTarget(self, action: "tapFired:")
        doubleTapGestureRecognizer.addTarget(self, action: "doubleTapFired:")
        
        tapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        centerScrollView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerScrollView() {
        imageView.sizeToFit()
        
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame


        
        if (contentsFrame.size.width < boundsSize.width) {
            contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2;
        } else {
            contentsFrame.origin.x = 0;
        }
        
        if (contentsFrame.size.height < boundsSize.height) {
            contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2;
        } else {
            contentsFrame.origin.y = 0;
        }
        
        imageView.frame = contentsFrame
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        let scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollView.frame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight, scaleWidth)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView ) {
        centerScrollView()
    }
    

    //MARK: - Gesture Recognizers
    
    func tapFired(sender: UIGestureRecognizer) {
        dismissViewControllerAnimated(true, completion:nil)
    }

    func doubleTapFired (sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            let locationPoint = sender.locationInView(imageView)
            let scrollViewSize = scrollView.bounds.size;
            let  width = scrollViewSize.width / self.scrollView.maximumZoomScale
            let height = scrollViewSize.height / self.scrollView.maximumZoomScale
            let x = locationPoint.x - (width / 2)
            let y = locationPoint.y - (height / 2)
            scrollView.zoomToRect(CGRectMake(x, y, width, height), animated:true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated:true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
