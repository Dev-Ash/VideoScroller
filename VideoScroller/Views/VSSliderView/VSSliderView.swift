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

public class VSSliderView:BaseView
{
    var config:VSSliderViewConfig?
    
    public override var nibName: String{
        return "VSSliderView"
    }
    
    @IBOutlet weak var sliderView: UIView!
    
    @IBOutlet weak var sliderWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sliderLeadingConstraint: NSLayoutConstraint!
    
    var minSliderPosition:CGFloat = 0
    var maxSliderPosition:CGFloat = 0
    var totalWidth:CGFloat = 0
    
    func setup(config:VSSliderViewConfig,leadingAndTrailingSpace:CGFloat)
    {
        self.minSliderPosition = leadingAndTrailingSpace
        self.maxSliderPosition =  self.frame.width - leadingAndTrailingSpace
        self.config = config
        
        sliderView?.backgroundColor = config.color
        sliderView?.layer.borderColor = config.borderColor.cgColor
        sliderView?.layer.borderWidth = config.borderWidth
        
        sliderView?.layer.cornerRadius = config.cornerRadius
        
        sliderWidthConstraint.constant = config.sliderWidth
        
        totalWidth = self.view.frame.width - (self.minSliderPosition * 2)
        
    }
    
    func updateSliderLocation(position:Float,duration:Float)
    {
        
        guard let sliderWidth = config?.sliderWidth else {return}
        
        var currentPosition = CGFloat(position) / CGFloat(duration) * totalWidth
        
        print("Slider Update \(currentPosition): \(totalWidth) -- > \(position) : \(duration)")
        
        currentPosition = currentPosition + minSliderPosition - sliderWidth/2
        
        sliderLeadingConstraint.constant = currentPosition
        
        
    }
    
}
