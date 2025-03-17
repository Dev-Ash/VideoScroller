//
//  ViewController.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 26/09/24.
//

import UIKit
import AVFoundation
import VideoScrubber

class ViewController: UIViewController {
    
    @IBOutlet weak var videoScrubber: VSVideoScrubber!
    
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    
    
    
    
    
    @IBOutlet weak var playerHolderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view?.backgroundColor = .black
        self.videoScrubber?.backgroundColor = .clear
        //Setup Player
        guard let videoURL = Bundle.main.url(forResource: "vert2", withExtension: "mp4") else {return}
        
        // Initialize the AVPlayer with the video URL
        player = AVPlayer(url: videoURL)
        
        // Create and configure the AVPlayerLayer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = playerHolderView.bounds // Match the view's bounds
        playerLayer?.videoGravity = .resizeAspect // Maintain aspect ratio
        
        // Add the player layer to the view's layer
        if let playerLayer = playerLayer {
            playerHolderView.layer.addSublayer(playerLayer)
        }
        
        // Start playback
        player?.play()
        
        
        
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
        
        let videoThumbnailConfig = VSVideoThumbnail_CVConfig(interItemSpacing: 2,
                                                             imageScaling: .scaleAspectFit, miniumCellWidth: 50)
        
        let trimWindowViewConfig = VSTrimWindowViewConfig(normalBackgroundColor: .clear,
                                                          selectedBacgroundColor: .white.withAlphaComponent(0.4),
                                                          borderColor: .white,
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
                                         sliderViewConfig: sliderConfig,
                                         trimMode: .TrimWithoutTrimLabels
        )
        
        
        //Setup Scrubber
        Task {
            await videoScrubber.setupConfig(player: player,config: config,videoThumbnailConfig: videoThumbnailConfig, videoScrubberDelegate: self)
        }
    }
    
    
}

extension ViewController:VSVideoScrubberDelegate
{
    func playerPositionChanged(currentPosition: Double, duration: Double) {
        print("VSVideoScrubberDelegate : playerPositionChanged \(currentPosition) : \(duration)")
    }
    
    func trimPositionChanged(startTime: Double, endTime: Double) {
        print("VSVideoScrubberDelegate : trimPositionChanged \(startTime) : \(endTime)")
        
    }
    
    
}
