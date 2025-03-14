//
//  VSSliderView.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 21/01/25.
//

import Foundation
import UIKit

public class VSSliderViewConfig
{
    var color:UIColor
    var cornerRadius:CGFloat
    var borderWidth:CGFloat
    var borderColor:UIColor
    var sliderWidth:CGFloat
    
    public init(color: UIColor, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor, sliderWidth: CGFloat) {
        self.color = color
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.sliderWidth = sliderWidth
    }
}

public protocol VSSliderViewDelegate:AnyObject
{
    func sliderSeekStateUpdate(state:Bool)
    func sliderSeekPositionChanged(position:Double)
    func canSeekToPosition(position:Double) -> Bool
}

public class VSSliderView:BaseView
{
    var config:VSSliderViewConfig?
    weak var sliderDelegate:VSSliderViewDelegate?
    
    /// current Position varies from 0 to 1.0 and represents seek position percentage
    var currentPosition:Double = 0
    
    public override var nibName: String{
        return "VSSliderView"
    }
    
    @IBOutlet weak var sliderHolderView: UIView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var sliderWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sliderLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    
    var isSeeking:Bool = false
    
    
    var isPlaying:Bool = false
    
    var startTime:Double = 0
    var endTime:Double = 0
    
    func setup(config:VSSliderViewConfig,leadingAndTrailingSpace:CGFloat,startTime:Double,endTime:Double)
    {
        
        let leading = leadingAndTrailingSpace
        let trailing = leadingAndTrailingSpace
        
        
        //Increase UI width to overlap half of slider with the trim views
        viewLeadingConstraint.constant = leading - config.sliderWidth/2
        viewTrailingConstraint.constant = trailing - config.sliderWidth/2
       
        
        self.config = config
        
        self.startTime = startTime
        self.endTime = endTime
        
        sliderView?.backgroundColor = config.color
        sliderView?.layer.borderColor = config.borderColor.cgColor
        sliderView?.layer.borderWidth = config.borderWidth
        
        sliderView?.layer.cornerRadius = config.cornerRadius
        
        sliderWidthConstraint.constant = config.sliderWidth
        
      //  totalWidth = sliderHolderView.frame.width - config.sliderWidth
        self.isUserInteractionEnabled = true
        //sliderView.isUserInteractionEnabled = true
        //sliderHolderView?.isUserInteractionEnabled = true
        setupGestures()
    }
    
    func setupGestures()
    {
        // Adding pan gesture to the leading trim spacer view
        let sliderPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSliderPanGesture(_:)))
        sliderView.addGestureRecognizer(sliderPanGesture)
        
       
       // sliderView?.isUserInteractionEnabled = true
    }
    
    func update(startTime:Double,endTime:Double)
    {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func updateSliderLocation(position:Double,duration:Double)
    {
        let totalWidth = sliderHolderView.frame.width
        
        guard duration > 0, position >= 0, position <= duration else { return }
        
        guard let sliderWidth = config?.sliderWidth,position <= duration, isPlaying == true else {return}
        
        if isSeeking == true{return}
        
        let percentage = CGFloat(position/duration)
        self.currentPosition = percentage
        
        
        var currentSliderPosition = percentage * (totalWidth - sliderWidth)
         
        //print("Slider Update \(percentage) \(currentPosition): \(totalWidth) -- > \(position) : \(duration)")
        
//        sliderLeadingConstraint.constant = currentPosition
        
        UIView.animate(withDuration: 0.5, delay: 0,options: [.curveLinear, .beginFromCurrentState, .allowUserInteraction] ,animations: {
            // Update the constraint's constant
            self.sliderLeadingConstraint.constant = currentSliderPosition
            // Force the layout to update with the new constraint
            self.view.layoutIfNeeded()
            
        })
    }
    
    @objc private func handleSliderPanGesture(_ gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began: isSeeking = true
            sliderDelegate?.sliderSeekStateUpdate(state: true)
            
        case .changed:
            // Adjust the leading trim spacer view constraint based on the horizontal translation
            guard let totalWidth = sliderHolderView?.frame.width else {
                gesture.setTranslation(.zero, in: self)
                return
            }
            
             var newPosition = sliderLeadingConstraint.constant + translation.x
             let halfSliderWidth = sliderWidthConstraint.constant/2
            
            //CHeck for slider lower bounds
            newPosition = max(0 ,newPosition)
            
            //Check for slider upper bounds
            newPosition = min(totalWidth - sliderWidthConstraint.constant, newPosition )
            
            //Check if slider is outside trimwindow
            let percentage = newPosition/(totalWidth - sliderWidthConstraint.constant)
            if sliderDelegate?.canSeekToPosition(position: percentage) == false
            {
                print("Outside Trim view bounds cannot seek")
                gesture.setTranslation(.zero, in: self)
                return
            }
//            if newPosition < minSliderPosition - sliderWidthConstraint.constant/2
//            {
//                gesture.setTranslation(.zero, in: self)
//                return
//            }
//            
//            if newPosition > totalWidth - minSliderPosition + sliderWidthConstraint.constant/2
//            {
//                gesture.setTranslation(.zero, in: self)
//                return
//            }
            
            sliderLeadingConstraint.constant = newPosition
            gesture.setTranslation(.zero, in: self)
            //let percentage = newPosition/(totalWidth - sliderWidthConstraint.constant)
            print("Slider new Position \(newPosition) :: \(percentage)")
            
            //Update player seek position
            sliderDelegate?.sliderSeekPositionChanged(position: Double(percentage))
          
            
            
        case .ended, .cancelled, .failed:
             isSeeking = false
            
            // Add any additional logic for when the gesture ends
            sliderDelegate?.sliderSeekStateUpdate(state: false)
            break
            
        default:
            break
        }
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if the touch point is within the bounds of the sliderView
            let hitView = super.hitTest(point, with: event)
            
            // Allow touches on the sliderView to remain, but pass other touches through
            if hitView == sliderView {
                return sliderView
            }
            
            // If the touch point is outside sliderView, pass the event to underlying views
            return nil
        }
    
    deinit {
        sliderView.gestureRecognizers?.forEach { sliderView.removeGestureRecognizer($0) }
    }
    
}
