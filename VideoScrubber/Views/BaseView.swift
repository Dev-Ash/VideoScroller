//
//  BaseView.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 26/09/24.
//

import Foundation
import UIKit

public class BaseView: UIView {
    
    public var view: UIView!
    
    override public init(frame: CGRect) {
        // 1. setup any properties here
        // 2. call super.init(frame:)
        super.init(frame: frame)
        self.contentMode = .redraw
        // 3. Setup view from .xib file
        xibSetup()
        print("Init frame")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        self.contentMode = .redraw
        // 3. Setup view from .xib file
        xibSetup()
        //AppUtilities.printLog(message: "Decoder")
    }
    
    public func xibSetup() {
        view = loadViewFromNib()
        // use bounds not frame or it'll be offset
        view.frame = bounds
        // Make the view stretch with containing view
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
        
        view.backgroundColor = .clear
    }

    public var nibName: String {
        fatalError("Must override and nibName set to corresponding view nib")
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.backgroundColor = .clear
        return view
    }
}
