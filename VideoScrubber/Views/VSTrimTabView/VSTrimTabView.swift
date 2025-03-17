//
//  VSTrimTabView.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 13/03/25.
//
import UIKit
import Foundation

public struct VSTrimTabViewConfig
{
    var backgroundColor:UIColor
    var viewWidth:CGFloat
    var borderColor:UIColor
    var borderWidth:CGFloat
    var cornerRadius:CGFloat
    
    public init(backgroundColor: UIColor, viewWidth: CGFloat, borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        self.backgroundColor = backgroundColor
        self.viewWidth = viewWidth
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        
        validate()
    }
    
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
