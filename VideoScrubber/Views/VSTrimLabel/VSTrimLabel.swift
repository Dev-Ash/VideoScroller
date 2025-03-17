//
//  VSTrimLabel.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 12/03/25.
//
import UIKit
import Foundation

public struct VSTrimLabelConfig
{
    var backgroundColor:UIColor
    var textColor:UIColor
    var textFont:UIFont
    var cornerRadius:CGFloat
    var viewHeight:CGFloat
    
    public init(backgroundColor: UIColor, textColor: UIColor, textFont: UIFont, cornerRadius: CGFloat, viewHeight: CGFloat) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.textFont = textFont
        self.cornerRadius = cornerRadius
        self.viewHeight = viewHeight
    }
}

public class VSTrimLabel:BaseView
{
    public override var nibName: String{ return "VSTrimLabel" }
    
    @IBOutlet weak var label: UILabel!
    
    public override func xibSetup() {
        super.xibSetup()
        self.backgroundColor = .clear
    }
    
    public func setup(config:VSTrimLabelConfig)
    {
        self.view.backgroundColor = config.backgroundColor
        self.label?.textColor = config.textColor
        
    
        self.label?.font = config.textFont
        self.view?.layer.cornerRadius = config.cornerRadius
        self.view.clipsToBounds = true
        
       
    }
    
   public var text:String?{
        didSet{
            self.label?.text = text ?? ""
            self.layoutIfNeeded()
        }
    }
}
