//
//  VSVideoScrubber.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 26/09/24.
//

import Foundation
import UIKit
import AVFoundation


public protocol VSVideoScrubberDelegate:AnyObject
{
    func playerPositionChanged(currentPosition:Double,duration:Double)
    func trimPositionChanged(startTime:Double,endTime:Double)
}

public struct VSVideoThumbnail_CVConfig
{
    var interItemSpacing:CGFloat
    var imageScaling:UIView.ContentMode
}

public class VSVideoScrubber:BaseView
{
    public override var nibName: String
    {
        return "VSVideoScrubber"
    }
    
   // @IBOutlet weak var scrollView: UIScrollView!
    
   // @IBOutlet weak var holderViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var holderView: UIView!
    
   
    
    //Constraint to set the leading trailing space for the thumbnailCollection view. It is equal to the spacer view width in the VSTrimmerView
    //Note:Trailing constraint is equal to Leading constraint
    
    @IBOutlet weak var leadingTrailingVideoThumbnailConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var leadingSpacerView: UIView!
    @IBOutlet weak var trailingSpacerView: UIView!

    
    let InterItemSpacing = 2.0
    
    
    @IBOutlet weak var videoCVTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoThumbnailCollectionView: VSVideoThumbnail_CV!
    
    @IBOutlet weak var trimmerView: VSTrimmerView!
    
    weak var player:AVPlayer?
    
   
    
    func setupConfig(player:AVPlayer?,videoScrubberDelegate:VSVideoScrubberDelegate?) async
    {
        self.player = player
        
        let trimLabelConfig = VSTrimLabelConfig(backgroundColor: .white,
                                                textColor: .black,
                                                textFont: UIFont(name: "Helvetica", size: 10)!,
                                                cornerRadius: 4,
                                                viewHeight: 15)
        
        let trimTabConfig = VSTrimTabViewConfig(backgroundColor: .white,
                                                viewWidth: 15,
                                                borderColor: .black,
                                                borderWidth: 1,
                                                cornerRadius: 2)
        
        let sliderConfig = VSSliderViewConfig(color: .red,
                                              cornerRadius: 5,
                                              borderWidth: 2,
                                              borderColor: .black.withAlphaComponent(0.4),
                                              sliderWidth: 5)
        
        let cvConfig = VSVideoThumbnail_CVConfig(interItemSpacing: 2,
                                                 imageScaling: .scaleAspectFit)
        
        let trimWindowViewConfig = VSTrimWindowViewConfig(normalBackgroundColor: .clear,
                                                          selectedBacgroundColor: .white.withAlphaComponent(0.4),
                                                          borderColor: .yellow,
                                                          borderWidth: 2,
                                                          cornerRadius: 10)
        
        let config = VSTrimmerViewConfig(maxTrimDuration: 15,
                                         minTrimDuration: 10,
                                         startTrimTime: 0,
                                         endTrimTime: 10,
                                         duration: 33,
                                         spacerViewColor: .black.withAlphaComponent(0.7),
                                         trimTabConfig:trimTabConfig ,
                                         trimLabelConfig: trimLabelConfig,
                                         trimWindowViewConfig: trimWindowViewConfig,
                                         sliderViewConfig: sliderConfig
                                         )
        
      
        
        //Used to increase space above the collection view to give space for the TrimLabelViews that are shown above the TrimmerView
        videoCVTopSpaceConstraint.constant = trimLabelConfig.viewHeight * 2
        
        //Same as trim tab config width to allow extra space before and after the video Thumbnail view for the tabs to extend to.
        leadingTrailingVideoThumbnailConstraints?.constant = trimTabConfig.viewWidth
        
        trimmerView?.setup(config: config,
                           player: player)
        
        //Set Delegate
        self.trimmerView?.videoScrubberDelegate = videoScrubberDelegate
        
        if let asset = player?.currentItem?.asset
        {
            await self.videoThumbnailCollectionView?.setup(config: cvConfig, asset: asset)
        }
        
    }
    
}



