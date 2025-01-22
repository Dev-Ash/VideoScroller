//
//  VSVideoScrubber.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 26/09/24.
//

import Foundation
import UIKit
import AVFoundation


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
    
    
    let SpacerViewWidth:CGFloat = 20
    let InterItemSpacing = 2.0
    
    
    @IBOutlet weak var videoThumbnailCollectionView: VideoThumbnail_CV!
    
    @IBOutlet weak var trimmerView: VSTrimmerView!
    
    weak var player:AVPlayer?
    
    func setupConfig(player:AVPlayer?)
    {
        self.player = player
        
        var config = VSTrimmerViewConfig(maxTrimDuration: 60,
                                         minTrimDuration: 2,
                                         startTrimTime: 10,
                                         endTrimTime: 15,
                                         duration: 33,
                                         spacerViewColor: .black.withAlphaComponent(0.5),
                                         trimViewColor: .red.withAlphaComponent(0.4),
                                         trimWindowSelectedStateColor: .white.withAlphaComponent(0.5),
                                         trimWindowNormalStateColor: .clear,
                                         trimLabelFont: UIFont(name: "Helvetica", size: 10)!,
                                         trimLabelFontColor: .white,
                                         trimLabelBackgroundColor: .white,
                                         trimLabelBorderRadius: 4)
        
        var sliderConfig = VSSliderViewConfig(color: .white,
                                              cornerRadius: 5,
                                              borderWidth: 1,
                                              borderColor: .black,
                                              sliderWidth: 10)
        
        leadingTrailingVideoThumbnailConstraints?.constant = SpacerViewWidth
        trimmerView?.setup(config: config, sliderConfig: sliderConfig, player: player)
    }
    
    func setup() async
    {
        guard let videoURL = Bundle.main.url(forResource: "vert2", withExtension: "mp4")
        else {
            print("Video file not found")
            return
        }
        
       // scrollView?.bounces = false
        
        let thumbnailExtractor = VideoThumbnailExtractor(videoURL: videoURL)
        let videoSize = VideoThumbnailExtractor.getVideoSize(url: videoURL)
        let aspectRatio = max(16/9, videoSize.height/videoSize.width)
        
        let thumbnailWidth =  videoThumbnailCollectionView.frame.height / aspectRatio
        
        let duration = VideoThumbnailExtractor.getvideoDuration(videoURL: videoURL)
        
        
        let noOfThumbnails = videoThumbnailCollectionView.frame.width/(thumbnailWidth+InterItemSpacing)
        
        let intervalBetweenThumbnails = duration/noOfThumbnails
        
        
        await thumbnailExtractor.generateThumbnails(every: intervalBetweenThumbnails) {[weak self] thumbnails in
            
            guard let strongSelf = self else {return}
            
            strongSelf.videoThumbnailCollectionView?.setupView(images: thumbnails, aspectRatio: aspectRatio)
            
           // strongSelf.holderViewWidthConstraint.constant = CGFloat((90 * 360)/640 + strongSelf.InterItemSpacing) * CGFloat(thumbnails.count) + 2 * strongSelf.SpacerViewWidth
        }
    }
    
}
