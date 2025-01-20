//
//  VSTrimmerView.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 09/12/24.
//

import UIKit
import Foundation

struct VSTrimmerViewConfig
{
    var maxTrimDuration:Float
    var minTrimDuration:Float
    
    var startTrimTime:Float
    var endTrimTime:Float
    
    var duration:Float
    
    var spacerViewColor:UIColor
    var trimViewColor:UIColor
    var trimWindowSelectedStateColor:UIColor
    var trimWindowNormalStateColor:UIColor
    
    var trimLabelFont:UIFont
    var trimLabelFontColor:UIColor
    var trimLabelBackgroundColor:UIColor
    var trimLabelBorderRadius:CGFloat
    
    
}


class VSTrimmerView:BaseView
{
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var leadingTrimSpacerView: UIView!
    
    @IBOutlet weak var trailingTrimSpacerView: UIView!
    
    @IBOutlet weak var trailingTrimView: UIView!
    
    @IBOutlet weak var leadingTrimView: UIView!
    
    @IBOutlet weak var trimWindowView: UIView!
    
    //Constraints
    
    @IBOutlet weak var leadingTrimSpacerWidthConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var trailingTrimSpacerWidthConstraints: NSLayoutConstraint!
    
    
    @IBOutlet weak var trailingTrimWidthConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var leadingTrimWidthConstraints: NSLayoutConstraint!
    
    
    //Trim Labels
    @IBOutlet weak var leadingTrimLabel: UILabel!
    @IBOutlet weak var trailingTrimLabel: UILabel!
    
    
    var playerDuration:Float = 0
    var currentPosition:CGFloat = 0
    
    var leadingTrimPosition:Float = 0
    var trailingTrimPosition:Float = 0
    
    var minTrimWindowWidth:CGFloat = 100
    var minSpacerWidth:CGFloat = 0
    
    //Width for each trim view
    var trimViewWidth:CGFloat = 20
    
    var panGesture:UIPanGestureRecognizer?
    
    var config:VSTrimmerViewConfig?
    
    override var nibName: String
    {
        return "VSTrimmerView"
    }
    
    override func xibSetup() {
        super.xibSetup()
        setupGestures()
        
        
        leadingTrimSpacerView?.backgroundColor = .lightGray.withAlphaComponent(0.5)
        
        trailingTrimSpacerView?.backgroundColor = .lightGray.withAlphaComponent(0.5)
        
        leadingTrimView?.backgroundColor = .red
        trailingTrimView?.backgroundColor = .red
    }
    
    
    
    private func setupGestures() {
        // Adding pan gesture to the leading trim spacer view
        let leadingPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLeadingPanGesture(_:)))
        leadingTrimView.addGestureRecognizer(leadingPanGesture)
        
        // Adding pan gesture to the trailing trim spacer view
        let trailingPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTrailingPanGesture(_:)))
        trailingTrimView.addGestureRecognizer(trailingPanGesture)
        
        // Long press and pan gesture for the trim window
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTrimWindowPan(_:)))
        
        trimWindowView.addGestureRecognizer(longPressGesture)
        trimWindowView.addGestureRecognizer(panGesture!)
        
        panGesture?.isEnabled = false // Initially disable pan gesture
        
        self.leadingTrimView?.isUserInteractionEnabled = true
        self.trailingTrimView?.isUserInteractionEnabled = true
        self.trimWindowView?.isUserInteractionEnabled = true
        
        self.isUserInteractionEnabled = true
    }
    
    func setup(config:VSTrimmerViewConfig)
    {
        leadingTrimView?.backgroundColor = config.trimViewColor
        trailingTrimView?.backgroundColor = config.trimViewColor
        
        leadingTrimSpacerView?.backgroundColor = config.spacerViewColor
        trailingTrimSpacerView?.backgroundColor = config.spacerViewColor
        
        trimWindowView?.backgroundColor = config.trimWindowNormalStateColor
        panGesture?.isEnabled = false
        
        leadingTrimWidthConstraints.constant = trimViewWidth
        trailingTrimWidthConstraints.constant = trimViewWidth
        
        playerDuration = config.duration
        
        self.config = config
        
        updateTrimLabels()
        
    }
    
    func setTrimPosition(leading:Float,trailing:Float)
    {
        
    }
    
    func updateTrimLabels()
    {
        
        
        if playerDuration == 0
        {
            leadingTrimLabel?.text = "00:00"
            trailingTrimLabel?.text = "00:00"
            return
        }
        
        //View width - leading and trailing spacer width - leading and trailing trim view width
        let totalWidth = self.frame.width - (minSpacerWidth * 2) - (trimViewWidth * 2)
        
        let trimWindowLeadingPosition = trimWindowView.frame.origin.x - trimViewWidth
        let trimWindowTrailingPosition = trimWindowLeadingPosition + trimWindowView.frame.width
        
        let leadingPosition = Float((trimWindowLeadingPosition)/(totalWidth)) * playerDuration
        
        
        let trailingPosition = Float((trimWindowTrailingPosition)/(totalWidth))*playerDuration
        
        print("Bounds \(self.bounds.width) Total \(totalWidth) Leading \(trimWindowLeadingPosition) Trailing \(trimWindowTrailingPosition)  LP \(leadingPosition) TP \(trailingPosition)")
        
        leadingTrimLabel?.text = formatSecondsToString(leadingPosition)
        trailingTrimLabel?.text = formatSecondsToString(trailingPosition)
        
    }
    
    fileprivate func formatSecondsToString(_ seconds: Float) -> String {
        if seconds.isNaN
        {
            return ""
        }



        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let Hr = Int(Min/60)

        if Hr > 0
        {
            let newMin = Min%60
            let time = String(format: "%d:%02d:%02d",Hr, newMin, Sec)
            return time
        }
        else
        {
            return String(format: "%02d:%02d", Min, Sec)
        }
    }
    
    @objc private func handleLeadingPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .changed:
            // Adjust the leading trim spacer view constraint based on the horizontal translation
            guard let trimWindowWidth = trimWindowView?.frame.width else {
                gesture.setTranslation(.zero, in: self)
                return
            }
            
            
            
            let newWidth = max(minSpacerWidth, leadingTrimSpacerWidthConstraints.constant + translation.x)
            
            if newWidth != minSpacerWidth && trimWindowWidth - translation.x <= minTrimWindowWidth
            {
                gesture.setTranslation(.zero, in: self)
                provideHapticFeedback()
                return
            }
            
            print("New leading width :\(newWidth)  trimWindow = \(trimWindowView!.frame.width)")
            leadingTrimSpacerWidthConstraints.constant = newWidth
            gesture.setTranslation(.zero, in: self)
            updateTrimLabels()
            
        case .ended, .cancelled, .failed:
            // Add any additional logic for when the gesture ends
            break
            
        default:
            break
        }
    }
    
    @objc private func handleTrailingPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .changed:
            // Adjust the trailing trim spacer width constraint based on the horizontal translation
            guard let trimWindowWidth = trimWindowView?.frame.width else {
                gesture.setTranslation(.zero, in: self)
                return
            }
            
            let newWidth = max(minSpacerWidth, trailingTrimSpacerWidthConstraints.constant - translation.x)
            
            if newWidth != minSpacerWidth && trimWindowWidth + translation.x <= minTrimWindowWidth
            {
                gesture.setTranslation(.zero, in: self)
                provideHapticFeedback()
                return
            }
            
            print("New trailing width :\(newWidth) : \(translation.x) : trimWindow = \(trimWindowView!.frame.width)")
            trailingTrimSpacerWidthConstraints.constant = newWidth
            gesture.setTranslation(.zero, in: self)
            updateTrimLabels()
            
        case .ended, .cancelled, .failed:
            // Add any additional logic for when the gesture ends
            break
            
        default:
            break
        }
    }
    
    private func provideHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        
        print("Long Press")
        guard let panGesture = trimWindowView.gestureRecognizers?.first(where: { $0 is UIPanGestureRecognizer }) as? UIPanGestureRecognizer else { return }
        
        switch gesture.state {
        case .began:
            toogleTrimWindowState(panGesture: panGesture)
            break
        case .ended, .cancelled:
            print("Long Press Deactive")
            
        default:
            break
        }
    }
    
    func toogleTrimWindowState(panGesture: UIPanGestureRecognizer)
    {
        if panGesture.isEnabled == true
        {
            panGesture.isEnabled = false
            trimWindowView?.backgroundColor = config!.trimWindowNormalStateColor
        }
        else
        {
            panGesture.isEnabled = true
            trimWindowView?.backgroundColor = config!.trimWindowSelectedStateColor
        }
    }
    
    
    @objc private func handleTrimWindowPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        //print ("Pan Start")
        switch gesture.state {
        case .changed:
        
            guard let trimWindowWidth = trimWindowView?.frame.width else {
                gesture.setTranslation(.zero, in: self)
                return
            }
            
            //Calculate leading Spacer View new Width and make sure it is greater than the minSpacerWidth
            let newLeadingWidth = max(minSpacerWidth, leadingTrimSpacerWidthConstraints.constant + translation.x)
            
            //Calculate trailing spacer width and make sure it is greater than minSpacerWidth
            let newTrailingWidth = max(minSpacerWidth, trailingTrimSpacerWidthConstraints.constant - translation.x)
            
            //Check if we have panned to the leading edge of the view
            if newLeadingWidth == minSpacerWidth
            {
                leadingTrimSpacerWidthConstraints.constant = newLeadingWidth
                gesture.setTranslation(.zero, in: self)
                updateTrimLabels()
                return
            }
            
            //Check if we have panned to the trailing edge of the view
            if newTrailingWidth == minSpacerWidth
            {
                trailingTrimSpacerWidthConstraints.constant = newTrailingWidth
                gesture.setTranslation(.zero, in: self)
                updateTrimLabels()
                return
            }
            
        
             
            // Ensure the trim window remains within bounds
            guard newLeadingWidth + newTrailingWidth + minTrimWindowWidth <= self.bounds.width else {
                print("Trim WIndow out of bounds")
                gesture.setTranslation(.zero, in: self)
                return
            }
            
            
            
            print("Trim Window move")
            
            //Update leading and trailing constraints.
            leadingTrimSpacerWidthConstraints.constant = newLeadingWidth
            trailingTrimSpacerWidthConstraints.constant = newTrailingWidth
            gesture.setTranslation(.zero, in: self)
            updateTrimLabels()
            
        default:
            break
        }
    }
}
