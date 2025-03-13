//
//  ViewController.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 26/09/24.
//

import UIKit
import AVFoundation

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
        
        
        //Setup Scrubber
        Task {
                
            await videoScrubber.setupConfig(player: player, videoScrubberDelegate: self)
            
            }
    }


}

extension ViewController:VSVideoScrubberDelegate
{
    func playerPositionChanged(currentPosition: Double, duration: Double) {
        
    }
    
    func trimPositionChanged(startTime: Double, endTime: Double) {
        
    }
    
    
}
