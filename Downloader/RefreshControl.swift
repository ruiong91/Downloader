//
//  RefreshControl.swift
//  ImageLoadTest
//
//  Created by Rui Ong on 17/04/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import Foundation
import UIKit

open class RefreshControl {
    
    public init(){}
    
    var refreshControl : UIRefreshControl?
    var customRefreshLoadingView: UIView?
    var labelsArray: Array<UILabel> = []
    
    var isAnimating = false
    var currentColorIndex = 0
    var currentLabelIndex = 0
    
    //Usage: Set up at ViewDidLoad
    open func setUpRefreshControl(view : AnyObject){
        
        refreshControl = UIRefreshControl()
        view.addSubview(refreshControl!)
        
        loadCustomRefreshContents()
        
    }
    
    //Load custom loading state view to the refresh control
    func loadCustomRefreshContents() {
        
        customRefreshLoadingView = UIView()
        
        let frameworkBundle = "com.example.Downloader"
        let resourceBundle = Bundle(identifier: frameworkBundle)
        
        let refreshContents = resourceBundle?.loadNibNamed("RefreshContents", owner: nil, options: nil)
        customRefreshLoadingView = refreshContents?[0] as! UIView
        customRefreshLoadingView?.frame = (refreshControl?.bounds)!
        
        guard let subviewCount = customRefreshLoadingView?.subviews.count else {return}
        
        for i in 0..<subviewCount {
            labelsArray.append(customRefreshLoadingView?.viewWithTag(i + 1) as! UILabel)
        }
        
        refreshControl?.addSubview(customRefreshLoadingView!)
        
    }
    
    func animateRefreshStep1() {
        isAnimating = true
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            
            self.labelsArray[self.currentLabelIndex].transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
            
        }) { (finished)  in
            
            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {                 self.labelsArray[self.currentLabelIndex].transform = CGAffineTransform.identity
                
            }) { (finished) in
                self.currentLabelIndex += 1
                
                if self.currentLabelIndex < self.labelsArray.count {
                    self.animateRefreshStep1()
                }
                else {
                    self.animateRefreshStep2()
                }
            }
        }
    }
    
    func animateRefreshStep2() {
        UIView.animate(withDuration: 0.35, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            
            self.labelsArray[0].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[1].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[2].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[3].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[4].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[5].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[6].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
        }) { (finished) in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.labelsArray[0].transform = CGAffineTransform.identity
                self.labelsArray[1].transform = CGAffineTransform.identity
                self.labelsArray[2].transform = CGAffineTransform.identity
                self.labelsArray[3].transform = CGAffineTransform.identity
                self.labelsArray[4].transform = CGAffineTransform.identity
                self.labelsArray[5].transform = CGAffineTransform.identity
                self.labelsArray[6].transform = CGAffineTransform.identity
                
            }) {(finished) in
                if (self.refreshControl?.isRefreshing)! {
                    self.currentLabelIndex = 0
                    self.animateRefreshStep1()
                }
                else {
                    self.isAnimating = false
                    self.currentLabelIndex = 0
                    for i in 0 ..< self.labelsArray.count {
                        self.labelsArray[i].textColor = UIColor.black
                        self.labelsArray[i].transform = CGAffineTransform.identity
                    }
                }
            }
        }
    }
    
    open func startRefreshing() {
        if refreshControl?.isRefreshing == true {
            if isAnimating == false {
                animateRefreshStep1()
            }
        }
    }
    
    open func stopRefreshing() {
        refreshControl?.endRefreshing()
        
    }
    
}
