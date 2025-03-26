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

public enum VSScrubberMode
{
    case Trim
    case TrimWithoutTrimLabels
    case SeekOnlyMode
}


public class VSVideoScrubber:BaseView
{
    public override var nibName: String
    {
        return "VSVideoScrubber"
    }
    
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
    
   
    
    public func setupConfig(player:AVPlayer?,config:VSTrimmerViewConfig,videoThumbnailConfig:VSVideoThumbnail_CVConfig, videoScrubberDelegate:VSVideoScrubberDelegate?) async
    {
        self.player = player
        
        //Used to increase space above the collection view to give space for the TrimLabelViews that are shown above the TrimmerView
        if config.trimMode == .Trim
        {
            videoCVTopSpaceConstraint.constant = config.trimLabelConfig.viewHeight * 2
        }
        else
        {
            //Remove Top space constraints as Trim Labels are not shown
            videoCVTopSpaceConstraint.constant = 0
        }
        
        //Same as trim tab config width to allow extra space before and after the video Thumbnail view for the tabs to extend to.
        leadingTrailingVideoThumbnailConstraints?.constant = config.trimTabConfig.viewWidth
        
        trimmerView?.setup(config: config,
                           player: player)
        
        //Set Delegate
        self.trimmerView?.videoScrubberDelegate = videoScrubberDelegate
        
        if let asset = player?.currentItem?.asset
        {
            await self.videoThumbnailCollectionView?.setup(config: videoThumbnailConfig, asset: asset)
        }
        
    }
    
}



