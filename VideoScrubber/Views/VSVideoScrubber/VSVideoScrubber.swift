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

/// An enumeration representing different modes for a video scrubber.
public enum VSScrubberMode
{
    /// The trimming mode which allows users to trim a video.
    /// - Parameters:
    ///   - hideTrimLabels: A Boolean value that determines whether trim labels should be hidden.
    ///   - hasRestrictedSeek: A Boolean value indicating whether seeking is restricted in this mode.

    case Trim(hideTrimLabels:Bool,hasRestrictedSeek:Bool)
    
    /// The seeking-only mode, where trimming is disabled, and users can only seek.
    case SeekOnlyMode
    
    /// A Boolean value indicating whether seeking is restricted in the current mode.
    ///
    /// - Returns: `true` if seeking is restricted, `false` otherwise.
    public var hasRestrictedSeek:Bool
    {
        switch self
        {
            
        case .Trim(hideTrimLabels: let hideTrimLabels, hasRestrictedSeek: let hasRestrictedSeek):
            return hasRestrictedSeek
        case .SeekOnlyMode:
            return false
        }
    }
    
    /// A Boolean value that determines whether trim labels should be hidden.
    ///
    /// - Returns: `true` if trim labels should be hidden, `false` otherwise.
    public var hideTrimLabels:Bool
    {
        switch self{
        case .Trim(hideTrimLabels: let hideTrimLabels, hasRestrictedSeek: let hasRestrictedSeek):
            return hideTrimLabels
        case .SeekOnlyMode:
            return true
        }
    }
    
    /// A Boolean value indicating whether trimming functionality is enabled.
    ///
    /// - Returns: `true` if trimming is enabled, `false` otherwise.
    public var trimEnabled:Bool
    {
        switch self
        {
            
        case .Trim(hideTrimLabels: let hideTrimLabels, hasRestrictedSeek: let hasRestrictedSeek):
            return true
        case .SeekOnlyMode:
            return false
        }
    }
}

/// A customizable video scrubber that provides trimming and thumbnail navigation functionality.
public class VSVideoScrubber:BaseView
{
    public override var nibName: String
    {
        return "VSVideoScrubber"
    }
    
    @IBOutlet weak var holderView: UIView!
    
   
    
    /// Constraint for setting the leading and trailing space of the video thumbnail collection view.
    ///
    /// - This is equal to the width of the spacer view in the `VSTrimmerView`.
    /// - **Note:** The trailing constraint is equal to the leading constraint.
    @IBOutlet weak var leadingTrailingVideoThumbnailConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var leadingSpacerView: UIView!
    @IBOutlet weak var trailingSpacerView: UIView!
    
    /// Constraint for adjusting the top space of the video thumbnail collection view to accomodate the trim label views
    @IBOutlet weak var videoCVTopSpaceConstraint: NSLayoutConstraint!
    /// Collection view displaying the video thumbnails.
    @IBOutlet weak var videoThumbnailCollectionView: VSVideoThumbnail_CV!
    /// The trimmer view used for selecting a specific portion of the video.
    @IBOutlet weak var trimmerView: VSTrimmerView!
    
    weak var player:AVPlayer?
    
   
    /// Configures the video scrubber with the specified parameters.
       ///
       /// - Parameters:
       ///   - player: The `AVPlayer` instance used for video playback.
       ///   - config: The configuration settings for the trimmer view.
       ///   - videoThumbnailConfig: The configuration settings for the video thumbnail collection view.
       ///   - videoScrubberDelegate: The delegate for handling video scrubber interactions.
    public func setupConfig(player:AVPlayer?,config:VSTrimmerViewConfig,videoThumbnailConfig:VSVideoThumbnail_CVConfig, videoScrubberDelegate:VSVideoScrubberDelegate?) async
    {
        self.player = player
        
        
        if config.mode.hideTrimLabels
        {
            //Remove Top space constraints as Trim Labels are not shown
            videoCVTopSpaceConstraint.constant = 0
        }
        else
        {
            //Used to increase space above the collection view to give space for the TrimLabelViews that are shown above the TrimmerView
            videoCVTopSpaceConstraint.constant = config.trimLabelConfig.viewHeight * 2
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



