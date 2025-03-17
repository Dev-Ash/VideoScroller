//
//  VSTrimWindowView.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 13/03/25.
//

import UIKit
import Foundation

public struct VSTrimWindowViewConfig
{
    var normalBackgroundColor:UIColor
    var selectedBacgroundColor:UIColor
    var borderColor:UIColor
    var borderWidth:CGFloat
    var cornerRadius:CGFloat
    
    public init(normalBackgroundColor: UIColor,selectedBacgroundColor:UIColor, borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        self.normalBackgroundColor  = normalBackgroundColor
        self.selectedBacgroundColor = selectedBacgroundColor
        self.borderColor            = borderColor
        self.borderWidth            = borderWidth
        self.cornerRadius           = cornerRadius
        
        validate()
    }
    
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
