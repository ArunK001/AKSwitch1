//
//  AKSwitch.swift
//  AKSwitch
//
//  Created by Arun Kumar Pattanayak on 17/03/17.
//  Copyright © 2017 Arun Kumar Pattanayak. All rights reserved.
//

import UIKit

enum SwitchStyle : Int {
    case light
    case dark
    case defaultStyle
}
enum SwitchState : Int {
    case on
    case off
}
enum SwitchSize : Int {
    case big
    case normal
    case small
}

protocol SwitchDelegate: NSObjectProtocol {
    // Delegate method
    func switchStateChanged(_ currentState: SwitchState)
}

class AKSwitch: UIControl {
    weak var delegate: SwitchDelegate?
    var isOn: Bool = false
    var isSwitchEnabled: Bool = false
    var isBounceEnabled: Bool = false
    var isRippleEnabled: Bool = false
    var thumbOnTintColor: UIColor!
    var thumbOffTintColor: UIColor!
    var trackOnTintColor: UIColor!
    var trackOffTintColor: UIColor!
    var thumbDisabledTintColor: UIColor!
    var trackDisabledTintColor: UIColor!
    var rippleFillColor: UIColor!
    var switchThumb: UIButton!
    var track: UIView!
    var trackThickness: CGFloat = 0.0
    var thumbSize: CGFloat = 0.0

    var thumbOnPosition: Float = 0.0
    var thumbOffPosition: Float = 0.0
    var bounceOffset: Float = 0.0
    var thumbStyle = SwitchStyle(rawValue: SwitchStyle.light.rawValue)
    var rippleLayer: CAShapeLayer?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
//    convenience init() {
//        self.init(size: .normal, style: .defaultStyle, state: .on)
//    }
    
    init(size: SwitchSize, state: SwitchState) {
        var frame: CGRect
        switch size {
        case .big:
            frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(50), height: CGFloat(40))
            self.trackThickness = 23.0
            self.thumbSize = 31.0
        case .normal:
            frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(40), height: CGFloat(30))
            self.trackThickness = 17.0
            self.thumbSize = 24.0
        case .small:
            frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(30), height: CGFloat(25))
            self.trackThickness = 13.0
            self.thumbSize = 18.0
        default:
            frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(40), height: CGFloat(30))
            self.trackThickness = 13.0
            self.thumbSize = 20.0
        }
        super.init(frame: frame)
        
        // initialize parameters
        self.thumbOnTintColor = UIColor(red: CGFloat(52.0 / 255.0), green: CGFloat(109.0 / 255.0), blue: CGFloat(241.0 / 255.0), alpha: CGFloat(1.0))
        self.thumbOffTintColor = UIColor(red: CGFloat(249.0 / 255.0), green: CGFloat(249.0 / 255.0), blue: CGFloat(249.0 / 255.0), alpha: CGFloat(1.0))
        self.trackOnTintColor = UIColor(red: CGFloat(143.0 / 255.0), green: CGFloat(179.0 / 255.0), blue: CGFloat(247.0 / 255.0), alpha: CGFloat(1.0))
        self.trackOffTintColor = UIColor(red: CGFloat(193.0 / 255.0), green: CGFloat(193.0 / 255.0), blue: CGFloat(193.0 / 255.0), alpha: CGFloat(1.0))
        self.thumbDisabledTintColor = UIColor(red: CGFloat(174.0 / 255.0), green: CGFloat(174.0 / 255.0), blue: CGFloat(174.0 / 255.0), alpha: CGFloat(1.0))
        self.trackDisabledTintColor = UIColor(red: CGFloat(203.0 / 255.0), green: CGFloat(203.0 / 255.0), blue: CGFloat(203.0 / 255.0), alpha: CGFloat(1.0))
        self.isEnabled = true
        self.isRippleEnabled = true
        self.isBounceEnabled = true
        self.rippleFillColor = UIColor.blue
        bounceOffset = 3.0
        
        var trackFrame = CGRect.zero
        var thumbFrame = CGRect.zero
        

        
        trackFrame.size.height = self.trackThickness
        trackFrame.size.width = frame.size.width
        trackFrame.origin.x = 0.0
        trackFrame.origin.y = (frame.size.height - trackFrame.size.height) / 2
        thumbFrame.size.height = self.thumbSize
        thumbFrame.size.width = thumbFrame.size.height
        thumbFrame.origin.x = 0.0
        thumbFrame.origin.y = (frame.size.height - thumbFrame.size.height) / 2
        // Actual initialization with selected size
        
        
        self.track = UIView(frame: trackFrame)
        self.track.backgroundColor = UIColor.gray
        self.track.layer.cornerRadius = min(self.track.frame.size.height, self.track.frame.size.width) / 2
        self.addSubview(self.track)
        self.switchThumb = UIButton(frame: thumbFrame)
        self.switchThumb.backgroundColor = UIColor.white
        self.switchThumb.layer.cornerRadius = self.switchThumb.frame.size.height / 2
        self.switchThumb.layer.shadowOpacity = 0.5
        self.switchThumb.layer.shadowOffset = CGSize(width: CGFloat(0.0), height: CGFloat(1.0))
        self.switchThumb.layer.shadowColor = UIColor.black.cgColor
        self.switchThumb.layer.shadowRadius = 2.0
        // Add events for user action
        self.switchThumb.addTarget(self, action: #selector(onTouchDown(_:with:)), for: .touchDown)
        self.switchThumb.addTarget(self, action: #selector(onTouchUpOutsideOrCanceled(_:with:)), for: .touchUpOutside)
        self.switchThumb.addTarget(self, action: #selector(self.switchThumbTapped), for: .touchUpInside)
        self.switchThumb.addTarget(self, action: #selector(onTouchDrag(inside:with:)), for: .touchDragInside)
        self.switchThumb.addTarget(self, action: Selector(("onTouchUpOutsideOrCanceled:withEvent:")), for: .touchCancel)
        
        self.addSubview(self.switchThumb)
        thumbOnPosition = Float(self.frame.size.width) - Float(self.switchThumb.frame.size.width)
        thumbOffPosition = Float(self.switchThumb.frame.origin.x)
        // Set thumb's initial position from state property
        switch state {
        case .on:
            self.isOn = true
            self.switchThumb.backgroundColor = self.thumbOnTintColor
            thumbFrame = self.switchThumb.frame
            thumbFrame.origin.x = CGFloat(thumbOnPosition)
            self.switchThumb.frame = thumbFrame
        case .off:
            self.isOn = false
            self.switchThumb.backgroundColor = self.thumbOffTintColor
        default:
            self.isOn = false
            self.switchThumb.backgroundColor = self.thumbOffTintColor
        }
        
        var singleTap = UITapGestureRecognizer(target: self, action: #selector(self.switchAreaTapped))
        self.addGestureRecognizer(singleTap)
    }
    
    convenience init(size: SwitchSize, style: SwitchStyle, state: SwitchState) {
        self.init(size: size, state: state)
        thumbStyle = style
        switch style {
        case .light:
            self.thumbOnTintColor = UIColor(red: CGFloat(0.0 / 255.0), green: CGFloat(134.0 / 255.0), blue: CGFloat(117.0 / 255.0), alpha: CGFloat(1.0))
            self.thumbOffTintColor = UIColor(red: CGFloat(237.0 / 255.0), green: CGFloat(237.0 / 255.0), blue: CGFloat(237.0 / 255.0), alpha: CGFloat(1.0))
            self.trackOnTintColor = UIColor(red: CGFloat(90.0 / 255.0), green: CGFloat(178.0 / 255.0), blue: CGFloat(169.0 / 255.0), alpha: CGFloat(1.0))
            self.trackOffTintColor = UIColor(red: CGFloat(129.0 / 255.0), green: CGFloat(129.0 / 255.0), blue: CGFloat(129.0 / 255.0), alpha: CGFloat(1.0))
            self.thumbDisabledTintColor = UIColor(red: CGFloat(175.0 / 255.0), green: CGFloat(175.0 / 255.0), blue: CGFloat(175.0 / 255.0), alpha: CGFloat(1.0))
            self.trackDisabledTintColor = UIColor(red: CGFloat(203.0 / 255.0), green: CGFloat(203.0 / 255.0), blue: CGFloat(203.0 / 255.0), alpha: CGFloat(1.0))
            self.rippleFillColor = UIColor.gray
            
        case .dark:
            self.thumbOffTintColor = UIColor(red: CGFloat(175.0 / 255.0), green: CGFloat(175.0 / 255.0), blue: CGFloat(175.0 / 255.0), alpha: CGFloat(1.0))
            self.trackOnTintColor = UIColor(red: CGFloat(72.0 / 255.0), green: CGFloat(109.0 / 255.0), blue: CGFloat(105.0 / 255.0), alpha: CGFloat(1.0))
            self.trackOffTintColor = UIColor(red: CGFloat(94.0 / 255.0), green: CGFloat(94.0 / 255.0), blue: CGFloat(94.0 / 255.0), alpha: CGFloat(1.0))
            self.thumbDisabledTintColor = UIColor(red: CGFloat(50.0 / 255.0), green: CGFloat(51.0 / 255.0), blue: CGFloat(50.0 / 255.0), alpha: CGFloat(1.0))
            self.trackDisabledTintColor = UIColor(red: CGFloat(56.0 / 255.0), green: CGFloat(56.0 / 255.0), blue: CGFloat(56.0 / 255.0), alpha: CGFloat(1.0))
            self.rippleFillColor = UIColor.gray
            break
            
        case .defaultStyle:
            self.thumbOnTintColor = UIColor(red: CGFloat(52.0 / 255.0), green: CGFloat(109.0 / 255.0), blue: CGFloat(241.0 / 255.0), alpha: CGFloat(1.0))
            self.thumbOffTintColor = UIColor(red: CGFloat(249.0 / 255.0), green: CGFloat(249.0 / 255.0), blue: CGFloat(249.0 / 255.0), alpha: CGFloat(1.0))
            self.trackOnTintColor = UIColor(red: CGFloat(143.0 / 255.0), green: CGFloat(179.0 / 255.0), blue: CGFloat(247.0 / 255.0), alpha: CGFloat(1.0))
            self.trackOffTintColor = UIColor(red: CGFloat(193.0 / 255.0), green: CGFloat(193.0 / 255.0), blue: CGFloat(193.0 / 255.0), alpha: CGFloat(1.0))
            self.thumbDisabledTintColor = UIColor(red: CGFloat(174.0 / 255.0), green: CGFloat(174.0 / 255.0), blue: CGFloat(174.0 / 255.0), alpha: CGFloat(1.0))
            self.trackDisabledTintColor = UIColor(red: CGFloat(203.0 / 255.0), green: CGFloat(203.0 / 255.0), blue: CGFloat(203.0 / 255.0), alpha: CGFloat(1.0))
            self.rippleFillColor = UIColor.blue
            break
            
        }
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        // Set colors for proper positions
        if self.isOn == true {
            self.switchThumb.backgroundColor = self.thumbOnTintColor
            self.track.backgroundColor = self.trackOnTintColor
        }
        else {
            self.switchThumb.backgroundColor = self.thumbOffTintColor
            self.track.backgroundColor = self.trackOffTintColor
            // set initial position
            self.changeThumbStateOFFwithoutAnimation()
        }
        if self.isEnabled == false {
            self.switchThumb.backgroundColor = self.thumbDisabledTintColor
            self.track.backgroundColor = self.trackDisabledTintColor
        }
        // Set bounce value, 3.0 if enabled and none for disabled
        if self.isBounceEnabled == true {
            bounceOffset = 3.0
        }
        else {
            bounceOffset = 0.0
        }
    }
    
    
    func getSwitchState() -> Bool {
        return self.isOn
    }
    // Change switch state if necessary, with the animated option parameter
    
    
    
    func setOn(_ on: Bool, animated: Bool) {
        if on == true {
            if animated == true {
                // set on with animation
                self.changeThumbStateONwithAnimation()
            }
            else {
                // set on without animation
                self.changeThumbStateONwithoutAnimation()
            }
        }
        else {
            if animated == true {
                // set off with animation
                self.changeThumbStateOFFwithAnimation()
            }
            else {
                // set off without animation
                self.changeThumbStateOFFwithoutAnimation()
            }
        }
    }
    
    func enabled(_ enabled: Bool) {
        super.isEnabled = enabled
        // Animation for better transfer, better UX
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            if enabled == true {
                if self.isOn == true {
                    self.switchThumb.backgroundColor = self.thumbOnTintColor
                    self.track.backgroundColor = self.trackOnTintColor
                }
                else {
                    self.switchThumb.backgroundColor = self.thumbOffTintColor
                    self.track.backgroundColor = self.trackOffTintColor
                }
                self.isEnabled = true
            }
            else {
                self.switchThumb.backgroundColor = self.thumbDisabledTintColor
                self.track.backgroundColor = self.trackDisabledTintColor
                self.isEnabled = false
            }
        })
    }
    
    func switchAreaTapped(_ recognizer: UITapGestureRecognizer) {
        // Delegate method
        if self.delegate?.responds(to: Selector(("switchStateChanged"))) == true {
            if self.isOn == true {
                self.delegate?.switchStateChanged(.off)
            }
            else {
                self.delegate?.switchStateChanged(.on)
            }
        }
        self.changeThumbState()
    }
    
    func changeThumbState() {
        // NSLog(@"thumb origin pos: %@", NSStringFromCGRect(self.switchThumb.frame));
        if self.isOn == true {
            self.changeThumbStateOFFwithAnimation()
        }
        else {
            self.changeThumbStateONwithAnimation()
        }
        if self.isRippleEnabled == true {
            self.animateRippleEffect()
        }
    }
    
    func changeThumbStateONwithAnimation() {
        // switch movement animation
        UIView.animate(withDuration: 0.15, delay: 0.05, options: .curveEaseInOut, animations: {() -> Void in
            var thumbFrame: CGRect = self.switchThumb.frame
            thumbFrame.origin.x = CGFloat(self.thumbOnPosition) + CGFloat(self.bounceOffset)
            self.switchThumb.frame = thumbFrame
            if self.isEnabled == true {
                self.switchThumb.backgroundColor = self.thumbOnTintColor
                self.track.backgroundColor = self.trackOnTintColor
            }
            else {
                self.switchThumb.backgroundColor = self.thumbDisabledTintColor
                self.track.backgroundColor = self.trackDisabledTintColor
            }
            self.isUserInteractionEnabled = false
        }, completion: {(_ finished: Bool) -> Void in
            // change state to ON
            if self.isOn == false {
                self.isOn = true
                // Expressly put this code here to change surely and send action correctly
                self.sendActions(for: .valueChanged)
            }
            self.isOn = true
            // NSLog(@"now isOn: %d", self.isOn);
            // NSLog(@"thumb end pos: %@", NSStringFromCGRect(self.switchThumb.frame));
            // Bouncing effect: Move thumb a bit, for better UX
            UIView.animate(withDuration: 0.15, animations: {() -> Void in
                // Bounce to the position
                var thumbFrame: CGRect = self.switchThumb.frame
                thumbFrame.origin.x = CGFloat(self.thumbOnPosition)
                self.switchThumb.frame = thumbFrame
            }, completion: {(_ finished: Bool) -> Void in
                self.isUserInteractionEnabled = true
            })
        })
    }
    
    func changeThumbStateOFFwithAnimation() {
        // switch movement animation
        UIView.animate(withDuration: 0.15, delay: 0.05, options: .curveEaseInOut, animations: {() -> Void in
            var thumbFrame: CGRect = self.switchThumb.frame
            thumbFrame.origin.x = CGFloat(self.thumbOffPosition) - CGFloat(self.bounceOffset)
            self.switchThumb.frame = thumbFrame
            if self.isEnabled == true {
                self.switchThumb.backgroundColor = self.thumbOffTintColor
                self.track.backgroundColor = self.trackOffTintColor
            }
            else {
                self.switchThumb.backgroundColor = self.thumbDisabledTintColor
                self.track.backgroundColor = self.trackDisabledTintColor
            }
            self.isUserInteractionEnabled = false
        }, completion: {(_ finished: Bool) -> Void in
            // change state to OFF
            if self.isOn == true {
                self.isOn = false
                // Expressly put this code here to change surely and send action correctly
                self.sendActions(for: .valueChanged)
            }
            self.isOn = false
            // NSLog(@"now isOn: %d", self.isOn);
            // NSLog(@"thumb end pos: %@", NSStringFromCGRect(self.switchThumb.frame));
            // Bouncing effect: Move thumb a bit, for better UX
            UIView.animate(withDuration: 0.15, animations: {() -> Void in
                // Bounce to the position
                var thumbFrame: CGRect = self.switchThumb.frame
                thumbFrame.origin.x = CGFloat(self.thumbOffPosition)
                self.switchThumb.frame = thumbFrame
            }, completion: {(_ finished: Bool) -> Void in
                self.isUserInteractionEnabled = true
            })
        })
    }
    
    func changeThumbStateONwithoutAnimation() {
        var thumbFrame: CGRect = self.switchThumb.frame
        thumbFrame.origin.x = CGFloat(thumbOnPosition)
        self.switchThumb.frame = thumbFrame
        if self.isEnabled == true {
            self.switchThumb.backgroundColor = self.thumbOnTintColor
            self.track.backgroundColor = self.trackOnTintColor
        }
        else {
            self.switchThumb.backgroundColor = self.thumbDisabledTintColor
            self.track.backgroundColor = self.trackDisabledTintColor
        }
        if self.isOn == false {
            self.isOn = true
            self.sendActions(for: .valueChanged)
        }
        self.isOn = true
    }
    
    func changeThumbStateOFFwithoutAnimation() {
        var thumbFrame: CGRect = self.switchThumb.frame
        thumbFrame.origin.x = CGFloat(thumbOffPosition)
        self.switchThumb.frame = thumbFrame
        if self.isEnabled == true {
            self.switchThumb.backgroundColor = self.thumbOffTintColor
            self.track.backgroundColor = self.trackOffTintColor
        }
        else {
            self.switchThumb.backgroundColor = self.thumbDisabledTintColor
            self.track.backgroundColor = self.trackDisabledTintColor
        }
        if self.isOn == true {
            self.isOn = false
            self.sendActions(for: .valueChanged)
        }
        self.isOn = false
    }
    
    func initializeRipple() {
        // Ripple size is twice as large as switch thumb
        var rippleScale: Float = 2
        var rippleFrame = CGRect.zero
        rippleFrame.origin.x -= self.switchThumb.frame.size.width / CGFloat(rippleScale * 2)
        rippleFrame.origin.y -= self.switchThumb.frame.size.height / CGFloat(rippleScale * 2)
        rippleFrame.size.height = self.switchThumb.frame.size.height * CGFloat(rippleScale)
        rippleFrame.size.width = rippleFrame.size.height
        //  NSLog(@"");
        //  NSLog(@"thumb State: %d", self.isOn);
        //  NSLog(@"switchThumb pos: %@", NSStringFromCGRect(self.switchThumb.frame));
        var path = UIBezierPath(roundedRect: rippleFrame, cornerRadius: self.switchThumb.layer.cornerRadius * 2)
        // Set ripple layer attributes
        rippleLayer = CAShapeLayer()
        rippleLayer?.path = path.cgPath
        rippleLayer?.frame = rippleFrame
        rippleLayer?.opacity = 0.2
        rippleLayer?.strokeColor = UIColor.clear.cgColor
        rippleLayer?.fillColor = self.rippleFillColor.cgColor
        rippleLayer?.lineWidth = 0
        //  NSLog(@"Ripple origin pos: %@", NSStringFromCGRect(circleShape.frame));
        self.switchThumb.layer.insertSublayer(rippleLayer!, below: self.switchThumb.layer)
        //    [self.layer insertSublayer:circleShape above:self.switchThumb.layer];
    }
    
    func animateRippleEffect() {
        // Create ripple layer
        if rippleLayer == nil {
            self.initializeRipple()
        }
        // Animation begins from here
        rippleLayer?.opacity = 0.0
        CATransaction.begin()
        //remove layer after animation completed
        CATransaction.setCompletionBlock({() -> Void in
            self.rippleLayer?.removeFromSuperlayer()
            self.rippleLayer = nil
        })
        // Scale ripple to the modelate size
        var scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = Int(0.5)
        scaleAnimation.toValue = Int(1.25)
        // Alpha animation for smooth disappearing
        var alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 0.4
        alphaAnimation.toValue = 0
        // Do above animations at the same time with proper duration
        var animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, alphaAnimation]
        animation.duration = 0.4
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        rippleLayer?.add(animation, forKey: nil)
        CATransaction.commit()
        // End of animation, then remove ripple layer
        // NSLog(@"Ripple removed");
    }
    
    func onTouchDown(_ btn: UIButton, with event: UIEvent) {
        // NSLog(@"touchDown called");
        if self.isRippleEnabled == true {
            self.initializeRipple()
        }
        // Animate for appearing ripple circle when tap and hold the switch thumb
        CATransaction.begin()
        var scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = Int(0.0)
        scaleAnimation.toValue = Int(1.0)
        var alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 0
        alphaAnimation.toValue = 0.2
        // Do above animations at the same time with proper duration
        var animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, alphaAnimation]
        animation.duration = 0.4
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        rippleLayer?.add(animation, forKey: nil)
        CATransaction.commit()
        //  NSLog(@"Ripple end pos: %@", NSStringFromCGRect(circleShape.frame));
    }
    
    func switchThumbTapped(_ sender: Any) {

//        if (self.delegate?.responds(to: Selector("switchStateChanged")))! {
        if let _ = self.delegate?.switchStateChanged(.off){
            if self.isOn == true {
                self.delegate?.switchStateChanged(.off)
            }
            else {
                self.delegate?.switchStateChanged(.on)
            }
        }
        self.changeThumbState()
    }
    
    func onTouchUpOutsideOrCanceled(_ btn: UIButton, with event: UIEvent) {
        // NSLog(@"Touch released at ouside");
        let touch: UITouch? = event.touches(for: btn)?.first//event.touches(forView: btn)?.first
        let prevPos: CGPoint? = touch?.previousLocation(in: btn)//touch?.previousLocation(in: btn)
        let pos: CGPoint? = touch?.location(in: btn)
        let dX: CGFloat? = (pos?.x)! - (prevPos?.x)!
        //Get the new origin after this motion
        let newXOrigin: CGFloat = btn.frame.origin.x + CGFloat(dX!)
        //NSLog(@"Released tap X pos: %f", newXOrigin);
        if CGFloat(newXOrigin) > (self.frame.size.width - self.switchThumb.frame.size.width) / 2 {
            //NSLog(@"thumb pos should be set *ON*");
            self.changeThumbStateONwithAnimation()
        }
        else {
            //NSLog(@"thumb pos should be set *OFF*");
            self.changeThumbStateOFFwithAnimation()
        }
        if self.isRippleEnabled == true {
            self.animateRippleEffect()
        }
    }
    
    func onTouchDrag(inside btn: UIButton, with event: UIEvent) {
        //This code can go awry if there is more than one finger on the screen
        var touch: UITouch? = event.touches(for: btn)?.first//event.touches(forView: btn)?.first
        var prevPos: CGPoint? = touch?.previousLocation(in: btn)
        var pos: CGPoint? = touch?.location(in: btn)
        var dX: CGFloat? = (pos?.x)! - (prevPos?.x)!
        //Get the original position of the thumb
        var thumbFrame: CGRect = btn.frame
        thumbFrame.origin.x += dX!
        //Make sure it's within two bounds
        thumbFrame.origin.x = min(thumbFrame.origin.x, CGFloat(thumbOnPosition))
        thumbFrame.origin.x = max(thumbFrame.origin.x, CGFloat(thumbOffPosition))
        //Set the thumb's new frame if need to
        if thumbFrame.origin.x != btn.frame.origin.x {
            btn.frame = thumbFrame
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
