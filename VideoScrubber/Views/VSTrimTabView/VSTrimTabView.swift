//
//  VSTrimTabView.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 13/03/25.
//
import UIKit
import Foundation

/// A configuration structure for customizing the appearance of the trim tab in the video trimmer.
public struct VSTrimTabViewConfig
{
    /// The background color of the trim tab.
    var backgroundColor:UIColor
    /// The width of the trim tab.
    var viewWidth:CGFloat
    /// The border color of the trim tab.
    var borderColor:UIColor
    /// The border width of the trim tab.
    var borderWidth:CGFloat
    /// The corner radius of the trim tab.
    var cornerRadius:CGFloat
    
    public init(backgroundColor: UIColor, viewWidth: CGFloat, borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        self.backgroundColor = backgroundColor
        self.viewWidth = viewWidth
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        
        validate()
    }
    
    /// Validates and adjusts the trim tab configuration to ensure proper sizing.
    ///
    /// - Ensures `viewWidth` is not less than 10 points to maintain usability.
    mutating func validate()
    {
        if self.viewWidth < 10
        {
            self.viewWidth = 10
        }
    }
}

public class VSTrimTabView:BaseView
{
    public override var nibName: String {return "VSTrimTabView"}
    
    
    func setup(config:VSTrimTabViewConfig)
    {
        self.backgroundColor         = .clear
        self.view.backgroundColor    = config.backgroundColor
        self.view.layer.borderWidth  = config.borderWidth
        self.view.layer.borderColor  = config.borderColor.cgColor
        self.view.layer.cornerRadius = config.cornerRadius
    }
    
   
    
}
