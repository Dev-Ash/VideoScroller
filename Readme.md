🎬 VSVideoScrubber

VSVideoScrubber is a customizable video scrubbing and trimming UI component for iOS. It allows users to preview and trim videos with a smooth experience, providing features like a thumbnail preview, trim controls, and customizable UI elements.

✨ Features
    •    🎥 Video Scrubbing: Navigate through videos with ease.
    •    ✂️ Video Trimming: Select start and end points for trimming.
    •    🎨 Highly Customizable UI: Customize colors, fonts, borders, and sizes.
    •    🖼 Thumbnail Previews: Displays video frames in a collection view.

                                                                                
🚀 Usage

1️⃣ Import the module
,,,import VSVideoScrubber'''
                                                                                    
2️⃣ Add VSVideoScrubber to your View or ViewController

                                                                                    
class ViewController: UIViewController {
    
    @IBOutlet weak var videoScrubber: VSVideoScrubber! // Connect via storyboard
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    @IBOutlet weak var playerHolderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view?.backgroundColor = .black
        self.videoScrubber?.backgroundColor = .clear
        
        
        guard let videoURL = Bundle.main.url(forResource: "vert2", withExtension: "mp4") else {return}
        
        // Player Setup
        // Initialize the AVPlayer with the video URL
        player = AVPlayer(url: videoURL)
        
        // Create and configure the AVPlayerLayer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = playerHolderView.bounds
        playerLayer?.videoGravity = .resizeAspect
        
        // Add the player layer to the view's layer
        if let playerLayer = playerLayer {
            playerHolderView.layer.addSublayer(playerLayer)
        }
        
        // Start playback
        player?.play()
         
        // Configure UI properties for trim labels
        let trimLabelConfig = VSTrimLabelConfig(
            backgroundColor: .white,              // Background color of trim labels
            textColor: .black,                    // Text color
            textFont: UIFont(name: "Helvetica", size: 10)!, // Font type and size
            cornerRadius: 4,                      // Rounded corners
            viewHeight: 15,                        // Height of the trim label
            borderColor: .white,                   // Border color
            borderWidth: 1.0                       // Border width
        )
        
        // Configuration for trim tabs (handles)
        let trimTabConfig = VSTrimTabViewConfig(
            backgroundColor: .white,  // Background color of the trim handle
            viewWidth: 15,            // Width of the trim handle
            borderColor: .black,      // Border color
            borderWidth: 1,           // Border width
            cornerRadius: 2           // Corner radius for rounded edges
        )
        
        // Configuration for the slider indicator
        let sliderConfig = VSSliderViewConfig(
            color: .red,                                     // Color of the slider line
            cornerRadius: 5,                                 // Corner radius for rounded edges
            borderWidth: 2,                                  // Width of the border
            borderColor: .black.withAlphaComponent(0.4),     // Border color with transparency
            sliderWidth: 5                                   // Width of the slider indicator
        )
        
        // Configuration for video thumbnails displayed in the scrubber
        let videoThumbnailConfig = VSVideoThumbnail_CVConfig(
            interItemSpacing: 2,                             // Space between thumbnails
            imageScaling: .scaleAspectFit,                   // Aspect fit scaling mode
            miniumCellWidth: 50                              // Minimum width of each thumbnail cell
        )
        
        // Configuration for the trimming window (selected range)
        let trimWindowViewConfig = VSTrimWindowViewConfig(
            normalBackgroundColor: .clear,                   // Default background color
            selectedBacgroundColor: .white.withAlphaComponent(0.4), // Background color when selected
            borderColor: .white,                             // Border color
            borderWidth: 2,                                  // Border width
            cornerRadius: 10                                 // Corner radius for rounded edges
        )
        
        // Main configuration object for the video scrubber
        let config = VSTrimmerViewConfig(
            maxTrimDuration: 15,                             // Maximum trimming duration allowed (seconds)
            minTrimDuration: 10,                             // Minimum trimming duration (seconds)
            startTrimTime: 10,                               // Initial start position for trimming
            endTrimTime: 20,                                 // Initial end position for trimming
            duration: 33,                                    // Total video duration
            spacerViewColor: .white.withAlphaComponent(0.8), // Spacer color for UI alignment
            trimTabConfig: trimTabConfig,                    // Assign the trim tab configuration
            trimLabelConfig: trimLabelConfig,                // Assign the trim label configuration
            trimWindowViewConfig: trimWindowViewConfig,      // Assign the trim window configuration
            sliderViewConfig: sliderConfig,                  // Assign the slider configuration
            trimMode: .Trim(hideTrimLabels: false, hasRestrictedSeek: true)
            // Trim mode: allows trimming with labels visible and restricted seek enabled
        )
        
        //Setup Scrubber
        Task {
            ///
            /// - Parameters:
            ///   - player: The `AVPlayer` instance used for video playback.
            ///   - config: The configuration settings for the trimmer view.
            ///   - videoThumbnailConfig: The configuration settings for the video thumbnail collection view.
            ///   - videoScrubberDelegate: The delegate for handling video scrubber interactions.
            await videoScrubber.setupConfig(player: player,config:
                                                    config,videoThumbnailConfig:
                                                    videoThumbnailConfig, videoScrubberDelegate: self)
        }
    }
}

// MARK: - VSVideoScrubberDelegate Methods
extension ViewController:VSVideoScrubberDelegate
{
    /// Called when the player's position changes during playback
    func playerPositionChanged(currentPosition: Double, duration: Double) {
        print("VSVideoScrubberDelegate : playerPositionChanged \(currentPosition) : \(duration)")
    }
    
    /// Called when the trim selection changes
    func trimPositionChanged(startTime: Double, endTime: Double) {
        print("VSVideoScrubberDelegate : trimPositionChanged \(startTime) : \(endTime)")
        
    }
}

                                                                                    
                                                                                
