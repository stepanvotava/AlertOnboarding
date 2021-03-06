//
//  AlertOnboarding.swift
//  AlertOnboarding
//
//  Created by Philippe on 26/09/2016.
//  Copyright © 2016 CookMinute. All rights reserved.
//

import UIKit

public protocol AlertOnboardingDelegate {
    func alertOnboardingSkipped(_ currentStep: Int, maxStep: Int)
    func alertOnboardingCompleted()
    func alertOnboardingNext(_ nextStep: Int)
}

public struct AlertOnboardingOptions {
    var colorForAlertViewBackground = UIColor.white

    var colorButtonBottomBackground = UIColor(red: 226/255, green: 237/255, blue: 248/255, alpha: 1.0)
    var colorButtonText = UIColor(red: 118/255, green: 125/255, blue: 152/255, alpha: 1.0)

    var colorTitleLabel: UIColor = UIColor(red: 171/255, green: 177/255, blue: 196/255, alpha: 1.0)
    var colorDescriptionLabel: UIColor = UIColor(red: 171/255, green: 177/255, blue: 196/255, alpha: 1.0)

    var colorPageIndicator = UIColor(red: 171/255, green: 177/255, blue: 196/255, alpha: 1.0)
    var colorCurrentPageIndicator = UIColor(red: 118/255, green: 125/255, blue: 152/255, alpha: 1.0)

    var percentageRatioHeight: CGFloat = 0.8
    var percentageRatioWidth: CGFloat = 0.8

    var titleSkipButton = "SKIP"
    var titleGotItButton = "GOT IT !"

    var titleFont = UIFont(name: "Avenir Heavy", size: 17.0)
    var descriptionFont = UIFont(name: "Avenir Book ", size: 13.0)
}

open class AlertOnboarding: UIView, AlertPageViewDelegate {
    
    //FOR DATA  ------------------------
    fileprivate var arrayOfImage = [UIImage]()
    fileprivate var arrayOfTitle = [String]()
    fileprivate var arrayOfDescription = [String]()
    
    //FOR DESIGN    ------------------------
    open var buttonBottom: UIButton!
    fileprivate var container: AlertPageViewController!
    open var background: UIView!
    
    
    //PUBLIC VARS   ------------------------
    var heightForAlertView: CGFloat!
    var widthForAlertView: CGFloat!

    open var options = AlertOnboardingOptions()
    
    open var delegate: AlertOnboardingDelegate?
    
    
    public init (arrayOfImage: [UIImage], arrayOfTitle: [String], arrayOfDescription: [String]) {
        super.init(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        self.configure(arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
        self.arrayOfImage = arrayOfImage
        self.arrayOfTitle = arrayOfTitle
        self.arrayOfDescription = arrayOfDescription
        
        self.interceptOrientationChange()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //-----------------------------------------------------------------------------------------
    // MARK: PUBLIC FUNCTIONS    --------------------------------------------------------------
    //-----------------------------------------------------------------------------------------
    
    open func show() {
        
        //Update Color
        self.buttonBottom.backgroundColor = options.colorButtonBottomBackground
        self.backgroundColor = options.colorForAlertViewBackground
        self.buttonBottom.setTitleColor(options.colorButtonText, for: UIControlState())
        self.buttonBottom.setTitle(options.titleSkipButton, for: UIControlState())
        
        self.container = AlertPageViewController(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription, alertView: self)
        self.container.delegate = self
        self.insertSubview(self.container.view, aboveSubview: self)
        self.insertSubview(self.buttonBottom, aboveSubview: self)
        
        // Only show once
        if self.superview != nil {
            return
        }
        
        // Find current stop viewcontroller
        if let topController = getTopViewController() {
            let superView: UIView = topController.view
            superView.addSubview(self.background)
            superView.addSubview(self)
            self.configureConstraints(topController.view)
            self.animateForOpening()
        }
    }
    
    //Hide onboarding with animation
    open func hide(){
        self.checkIfOnboardingWasSkipped()
        DispatchQueue.main.async { () -> Void in
            self.animateForEnding()
        }
    }
    
    
    //------------------------------------------------------------------------------------------
    // MARK: PRIVATE FUNCTIONS    --------------------------------------------------------------
    //------------------------------------------------------------------------------------------
    
    //MARK: Check if onboarding was skipped
    fileprivate func checkIfOnboardingWasSkipped(){
        let currentStep = self.container.currentStep
        if currentStep < (self.container.arrayOfImage.count - 1) && !self.container.isCompleted{
            self.delegate?.alertOnboardingSkipped(currentStep, maxStep: self.container.maxStep)
        }
        else {
            self.delegate?.alertOnboardingCompleted()
        }
    }
    
    
    //MARK: FOR CONFIGURATION    --------------------------------------
    fileprivate func configure(_ arrayOfImage: [UIImage], arrayOfTitle: [String], arrayOfDescription: [String]) {
        
        self.buttonBottom = UIButton(frame: CGRect(x: 0,y: 0, width: 0, height: 0))
        self.buttonBottom.titleLabel?.font = UIFont(name: "Avenir-Black", size: 15)
        self.buttonBottom.addTarget(self, action: #selector(AlertOnboarding.onClick), for: .touchUpInside)
        
        self.background = UIView(frame: CGRect(x: 0,y: 0, width: 0, height: 0))
        self.background.backgroundColor = UIColor.black
        self.background.alpha = 0.5
        
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
    }
    
    
    fileprivate func configureConstraints(_ superView: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.buttonBottom.translatesAutoresizingMaskIntoConstraints = false
        self.container.view.translatesAutoresizingMaskIntoConstraints = false
        self.background.translatesAutoresizingMaskIntoConstraints = false
        
        self.removeConstraints(self.constraints)
        self.buttonBottom.removeConstraints(self.buttonBottom.constraints)
        self.container.view.removeConstraints(self.container.view.constraints)
        
        heightForAlertView = UIScreen.main.bounds.height*options.percentageRatioHeight
        widthForAlertView = UIScreen.main.bounds.width*options.percentageRatioWidth
        
        //Constraints for alertview
        let horizontalContraintsAlertView = NSLayoutConstraint(item: self, attribute: .centerXWithinMargins, relatedBy: .equal, toItem: superView, attribute: .centerXWithinMargins, multiplier: 1.0, constant: 0)
        let verticalContraintsAlertView = NSLayoutConstraint(item: self, attribute:.centerYWithinMargins, relatedBy: .equal, toItem: superView, attribute: .centerYWithinMargins, multiplier: 1.0, constant: 0)
        let heightConstraintForAlertView = NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: heightForAlertView)
        let widthConstraintForAlertView = NSLayoutConstraint.init(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: widthForAlertView)
        
        //Constraints for button
        let verticalContraintsButtonBottom = NSLayoutConstraint(item: self.buttonBottom, attribute:.centerXWithinMargins, relatedBy: .equal, toItem: self, attribute: .centerXWithinMargins, multiplier: 1.0, constant: 0)
        let heightConstraintForButtonBottom = NSLayoutConstraint.init(item: self.buttonBottom, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: heightForAlertView*0.1)
        let widthConstraintForButtonBottom = NSLayoutConstraint.init(item: self.buttonBottom, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: widthForAlertView)
        let pinContraintsButtonBottom = NSLayoutConstraint(item: self.buttonBottom, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        //Constraints for container
        let verticalContraintsForContainer = NSLayoutConstraint(item: self.container.view, attribute:.centerXWithinMargins, relatedBy: .equal, toItem: self, attribute: .centerXWithinMargins, multiplier: 1.0, constant: 0)
        let heightConstraintForContainer = NSLayoutConstraint.init(item: self.container.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: heightForAlertView*0.9)
        let widthConstraintForContainer = NSLayoutConstraint.init(item: self.container.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: widthForAlertView)
        let pinContraintsForContainer = NSLayoutConstraint(item: self.container.view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        
        
        //Constraints for background
        let widthContraintsForBackground = NSLayoutConstraint(item: self.background, attribute:.width, relatedBy: .equal, toItem: superView, attribute: .width, multiplier: 1, constant: 0)
        let heightConstraintForBackground = NSLayoutConstraint.init(item: self.background, attribute: .height, relatedBy: .equal, toItem: superView, attribute: .height, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([horizontalContraintsAlertView, verticalContraintsAlertView,heightConstraintForAlertView, widthConstraintForAlertView,
                                     verticalContraintsButtonBottom, heightConstraintForButtonBottom, widthConstraintForButtonBottom, pinContraintsButtonBottom,
                                     verticalContraintsForContainer, heightConstraintForContainer, widthConstraintForContainer, pinContraintsForContainer,
                                     widthContraintsForBackground, heightConstraintForBackground])
    }
    
    //MARK: FOR ANIMATIONS ---------------------------------
    fileprivate func animateForOpening(){
        self.alpha = 1.0
        self.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
    }
    
    fileprivate func animateForEnding(){
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
            }, completion: {
                (finished: Bool) -> Void in
                // On main thread
                DispatchQueue.main.async {
                    () -> Void in
                    self.background.removeFromSuperview()
                    self.removeFromSuperview()
                    self.container.removeFromParentViewController()
                    self.container.view.removeFromSuperview()
                }
        })
    }
    
    //MARK: BUTTON ACTIONS ---------------------------------
    
    func onClick(){
        self.hide()
    }
    
    //MARK: ALERTPAGEVIEWDELEGATE    --------------------------------------
    
    func nextStep(_ step: Int) {
        self.delegate?.alertOnboardingNext(step)
    }
    
    //MARK: OTHERS    --------------------------------------
    fileprivate func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
    
    //MARK: NOTIFICATIONS PROCESS ------------------------------------------
    fileprivate func interceptOrientationChange(){
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(AlertOnboarding.onOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func onOrientationChange(){
        if let superview = self.superview {
            self.configureConstraints(superview)
            self.container.configureConstraintsForPageControl()
        }
    }
}
