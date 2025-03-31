//
//  VSTrimWindowView.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 13/03/25.
//

import UIKit
import Foundation

/// A configuration structure for customizing the appearance of the trim window view in the video trimmer.
public struct VSTrimWindowViewConfig
{
    /// The background color of the trim window when it is in a normal (unselected) state.
    var normalBackgroundColor:UIColor
    /// The background color of the trim window when it is selected.
    var selectedBacgroundColor:UIColor
    /// The border color of the trim window.
    var borderColor:UIColor
    /// The width of the border around the trim window.
    var borderWidth:CGFloat
    /// The corner radius of the trim window, allowing for rounded edges.
    var cornerRadius:CGFloat
    
    public init(normalBackgroundColor: UIColor,selectedBacgroundColor:UIColor, borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        self.normalBackgroundColor  = normalBackgroundColor
        self.selectedBacgroundColor = selectedBacgroundColor
        self.borderColor            = borderColor
        self.borderWidth            = borderWidth
        self.cornerRadius           = cornerRadius
        
        validate()
    }
    
    /// Validates and adjusts the trim window view configuration to ensure proper values.
    ///
    /// - Ensures `cornerRadius` is not negative.
    /// - Ensures `borderWidth` is not negative.
    mutating func validate()
    {
        if cornerRadius < 0 {
            cornerRadius = 0
        }
        
        if borderWidth < 0
        {
            borderWidth = 0
        }
    }
}


public class VSTrimWindowView:BaseView
{
    public override var nibName: String {return "VSTrimWindowView"}
    
    
    func setup(config:VSTrimWindowViewConfig)
    {
        self.backgroundColor            = .clear
        self.view.backgroundColor       = config.normalBackgroundColor
        self.view.layer.cornerRadius    = config.cornerRadius
        self.view.layer.borderColor     = config.borderColor.cgColor
        self.view.layer.borderWidth     = config.borderWidth
    }
}
