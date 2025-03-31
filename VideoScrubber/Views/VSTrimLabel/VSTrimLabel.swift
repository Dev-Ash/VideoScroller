//
//  VSTrimLabel.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 12/03/25.
//
import UIKit
import Foundation

/// A configuration structure for customizing the appearance of the trim labels in the video trimmer.
public struct VSTrimLabelConfig
{
    /// The background color of the trim label.
    var backgroundColor:UIColor
    /// The text color of the trim label.
    var textColor:UIColor
    /// The font used for displaying text in the trim label.
    var textFont:UIFont
    /// The corner radius of the trim label, allowing for rounded edges.
    var cornerRadius:CGFloat
    /// The height of the trim label.
    var viewHeight:CGFloat
    
    /// The border color of the trim label.
    var borderColor:UIColor
    /// The border width of the trim label.
    var borderWidth:CGFloat

    
    public init(backgroundColor: UIColor, textColor: UIColor, textFont: UIFont, cornerRadius: CGFloat, viewHeight: CGFloat, borderColor:UIColor,borderWidth:CGFloat) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.textFont = textFont
        self.cornerRadius = cornerRadius
        self.viewHeight = viewHeight
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        
        self.validate()
    }
    
    /// Validates and adjusts the trim label view configuration to ensure proper values.
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
