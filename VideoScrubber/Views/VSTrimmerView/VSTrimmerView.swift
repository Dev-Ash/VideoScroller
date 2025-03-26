//
//  VSTrimmerView.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 09/12/24.
//

import UIKit
import Foundation
import AVFoundation

public struct VSTrimmerViewConfig
{
    var maxTrimDuration:Double
    var minTrimDuration:Double
    
    var startTrimTime:Double
    var endTrimTime:Double
    var duration:Double
    
    var spacerViewColor:UIColor
   
    var trimTabConfig:VSTrimTabViewConfig
    var trimLabelConfig:VSTrimLabelConfig
    var trimWindowViewConfig:VSTrimWindowViewConfig
    var sliderViewConfig:VSSliderViewConfig
    var trimMode:VSScrubberMode = .Trim
    
    public init(maxTrimDuration: Double, minTrimDuration: Double, startTrimTime: Double, endTrimTime: Double, duration: Double, spacerViewColor: UIColor, trimTabConfig: VSTrimTabViewConfig, trimLabelConfig: VSTrimLabelConfig, trimWindowViewConfig: VSTrimWindowViewConfig, sliderViewConfig: VSSliderViewConfig, trimMode: VSScrubberMode) {
        self.maxTrimDuration = maxTrimDuration
        self.minTrimDuration = minTrimDuration
        self.startTrimTime = startTrimTime
        self.endTrimTime = endTrimTime
        self.duration = duration
        self.spacerViewColor = spacerViewColor
        self.trimTabConfig = trimTabConfig
        self.trimLabelConfig = trimLabelConfig
        self.trimWindowViewConfig = trimWindowViewConfig
        self.sliderViewConfig = sliderViewConfig
        self.trimMode = trimMode
        
        validate()
    }
    
    mutating func validate()
    {
        if duration <= 0 {
            minTrimDuration = 0
            maxTrimDuration = 0
        }
        
        if minTrimDuration < 0 || minTrimDuration > duration
        {
            minTrimDuration = 0
        }
        
        if maxTrimDuration < 0 || maxTrimDuration > duration
        {
            maxTrimDuration = duration
        }
        
        if maxTrimDuration < minTrimDuration
        {
            maxTrimDuration = minTrimDuration
        }
        
        if trimMode == .SeekOnlyMode
        {
            startTrimTime = 0
            endTrimTime = duration
            maxTrimDuration = duration
        }
    }
}

public enum TrimTabState
{
    case beginToMove
    case moving
    case stoppedMoving
    case none
}


class VSTrimmerView:BaseView
{
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var leadingTrimSpacerView: UIView!
    
    @IBOutlet weak var trailingTrimSpacerView: UIView!
    
    @IBOutlet weak var trailingTrimView: VSTrimTabView!
    
    @IBOutlet weak var leadingTrimView: VSTrimTabView!
    
    @IBOutlet weak var trimWindowView: VSTrimWindowView!
    
    @IBOutlet weak var sliderView: VSSliderView!
    
    //Constraints
    
    @IBOutlet weak var leadingTrimSpacerWidthConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var trailingTrimSpacerWidthConstraints: NSLayoutConstraint!
    
    
    @IBOutlet weak var trailingTrimWidthConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var leadingTrimWidthConstraints: NSLayoutConstraint!
    
    
    //MARK: Trim Label Var

    @IBOutlet weak var trailingTrimLabelHolderView: UIView!
    
    @IBOutlet weak var leadingTrimLableHolderView: UIView!
    
    @IBOutlet weak var trailingTrimLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leadingTrimLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leadingTrimLabel: VSTrimLabel!
    @IBOutlet weak var trailingTrimLabel: VSTrimLabel!
    
    //GestureRecognizers
    var leadingPanGesture:UIPanGestureRecognizer?
    var trailingPanGesture:UIPanGestureRecognizer?
    var longPressGesture:UILongPressGestureRecognizer?
    
    
    var playerDuration:Double = 0
    var currentPosition:CGFloat = 0
    
    var startTrimTime:Double = 0
    var endTrimTime:Double = 0
    
    var minTrimWindowWidth:CGFloat = 0
    var maxTrimWindowWidth:CGFloat = 0
    
    var viewTotalWidth:CGFloat = 0
    
    //Width for each trim view
    var trimViewWidth:CGFloat = 20
    
    var panGesture:UIPanGestureRecognizer?
    
    var config:VSTrimmerViewConfig?
    
    weak var player:AVPlayer?
    var timeObserverToken: Any?
    
    weak var videoScrubberDelegate:VSVideoScrubberDelegate?
    
    var trimMode:VSScrubberMode = .Trim

    var trimTabState:TrimTabState = .none
    {
        didSet{
            switch trimTabState
            {
                
            case .beginToMove:
                self.player?.pause()
            case .moving:
                break
            case .stoppedMoving:
                guard let currentPercentage = sliderView?.currentPosition
                else {
                    player?.play()
                    return
                }
                
                //if Out of trim bounds seek to start trim time
                let position = currentPercentage * getDuration()
                if position < startTrimTime || position > endTrimTime
                {
                    seek(to: startTrimTime)
                }
                
                self.videoScrubberDelegate?.trimPositionChanged(startTime: startTrimTime, endTime: endTrimTime)
                
                player?.play()
            case .none:
                break
            }
        }
    }
    
    override var nibName: String
    {
        return "VSTrimmerView"
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        leadingTrimSpacerView?.backgroundColor  = .clear
        trailingTrimSpacerView?.backgroundColor = .clear
        leadingTrimView?.backgroundColor = .red
        trailingTrimView?.backgroundColor = .red
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        viewTotalWidth = frame.width - (trimViewWidth * 2)
        updateMinMaxTrimWindowSize()
        setupTrimViewLocation(startTime: startTrimTime, endTime: endTrimTime)
    }
    
    deinit {
           // Remove the periodic time observer when the view controller is deallocated
           if let timeObserverToken = timeObserverToken {
               player?.removeTimeObserver(timeObserverToken)
               self.timeObserverToken = nil
           }
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
     }

//MARK: Gesture Setup
    private func setupGestures() {
        // Adding pan gesture to the leading trim spacer view
        leadingPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLeadingPanGesture(_:)))
        leadingTrimView.addGestureRecognizer(leadingPanGesture!)
        
        // Adding pan gesture to the trailing trim spacer view
        trailingPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTrailingPanGesture(_:)))
        trailingTrimView.addGestureRecognizer(trailingPanGesture!)
        
        // Long press and pan gesture for the trim window
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTrimWindowPan(_:)))
        
        trimWindowView.addGestureRecognizer(longPressGesture!)
        trimWindowView.addGestureRecognizer(panGesture!)
        
        panGesture?.isEnabled = false // Initially disable pan gesture
        
        self.leadingTrimView?.isUserInteractionEnabled = true
        self.trailingTrimView?.isUserInteractionEnabled = true
        self.trimWindowView?.isUserInteractionEnabled = true
        
        self.isUserInteractionEnabled = true
    }
    
    private func removeGestures()
    {
        if let gesture = leadingPanGesture
        {
            leadingTrimView?.removeGestureRecognizer(gesture)
        }
        
        if let gesture = trailingPanGesture
        {
            trailingTrimView?.removeGestureRecognizer(gesture)
        }
        
        if let gesture = longPressGesture
        {
            trimWindowView?.removeGestureRecognizer(gesture)
        }
        
        if let gesture = panGesture
        {
            trimWindowView?.removeGestureRecognizer(gesture)
        }
    }
    
//MARK: Setup
    func setup(config:VSTrimmerViewConfig, player:AVPlayer?)
    {
        //Validate config
        self.config = config
        
        self.trimTabState = .none
        self.trimMode = config.trimMode
        
        leadingTrimView?.setup(config: config.trimTabConfig)
        trailingTrimView?.setup(config: config.trimTabConfig)
        
        leadingTrimWidthConstraints.constant    = config.trimTabConfig.viewWidth
        trailingTrimWidthConstraints.constant   = config.trimTabConfig.viewWidth
        
        trimViewWidth = config.trimTabConfig.viewWidth
        
        leadingTrimSpacerView?.backgroundColor  = .clear
        trailingTrimSpacerView?.backgroundColor = .clear
        
        trimWindowView?.setup(config: config.trimWindowViewConfig)
        panGesture?.isEnabled = false
    
        leadingTrimSpacerView?.backgroundColor  = config.spacerViewColor
        trailingTrimSpacerView?.backgroundColor = config.spacerViewColor
        
        playerDuration = self.config!.duration
        
        leadingTrimLabel?.setup(config: config.trimLabelConfig)
        trailingTrimLabel?.setup(config: config.trimLabelConfig)
        
        
        if trimMode == .Trim
        {
            leadingTrimLableHolderView?.isHidden = false
            trailingTrimLabelHolderView?.isHidden = false
            leadingTrimLabelHeightConstraint.constant = config.trimLabelConfig.viewHeight
            trailingTrimLabelHeightConstraint.constant = config.trimLabelConfig.viewHeight
        }
        else
        {
            leadingTrimLableHolderView?.isHidden = true
            trailingTrimLabelHolderView?.isHidden = true
        }
        
        leadingTrimView.accessibilityLabel = "Start Trim Handle"
        trailingTrimView.accessibilityLabel = "End Trim Handle"
        
        self.view.layoutIfNeeded()
        
        //Caclculate total View Width
        updateTotalWidth()
        
        //Setup Slider View
        sliderView?.setup(config: config.sliderViewConfig,
                          leadingAndTrailingSpace: trimViewWidth,
                          startTime: 0,endTime: self.getDuration())
        sliderView?.sliderDelegate = self
        
        //Calculate max and min trim window width
        updateMinMaxTrimWindowSize()
        
        self.startTrimTime = config.startTrimTime
        self.endTrimTime = config.endTrimTime
        
        //update trim Gestures recognizer state
        if trimMode == .SeekOnlyMode
        {
            leadingTrimView?.alpha = 0
            trailingTrimView?.alpha = 0
            removeGestures()
        }
        else
        {
            leadingTrimView?.alpha = 1
            trailingTrimView?.alpha = 1
            removeGestures()
            setupGestures()
        }
        
        //Setup initial Trim location
        setupTrimViewLocation(startTime: self.config!.startTrimTime, endTime: self.config!.endTrimTime)
        
        
        self.player = player
       
        //Update Player start position if startTrimTime is not 0
        if self.trimMode == .Trim || self.trimMode == .TrimWithoutTrimLabels
        {
            if startTrimTime > 0 && startTrimTime < config.duration
            {
                self.seek(to: startTrimTime)
            }
        }
        
        //Setup periodic timer to observe player position changes
        self.addPeriodicTimeObserver()
        // Observe timeControlStatus for playback state
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .initial], context: nil)

    }
    
    //MARK: Player Functions
    func addPeriodicTimeObserver() {
            // Check that the player exists
            guard let player = player else { return }

            // Set the time interval (e.g., 1 second)
        let timeInterval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

            // Add periodic time observer
            timeObserverToken = player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
                
                guard let strongSelf = self else {return}
                
                let currentTime = CMTimeGetSeconds(time)
                //print("Current playback time: \(currentTime) seconds")
                
                if currentTime >= strongSelf.endTrimTime && strongSelf.trimMode != .SeekOnlyMode{
                    strongSelf.seek(to: strongSelf.startTrimTime)
                }
                else
                {
                    
                    strongSelf.sliderView?.updateSliderLocation(position: Double(currentTime), duration: strongSelf.getDuration())
                    strongSelf.videoScrubberDelegate?.playerPositionChanged(currentPosition: Double(currentTime), duration: strongSelf.getDuration())
                }
                

                // Update any UI components with the current time here, if needed
            }
        }
    
    // Observe changes to timeControlStatus
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            guard keyPath == "timeControlStatus", let player = object as? AVPlayer else { return }

            switch player.timeControlStatus {
            case .playing:
                //print("Player is playing")
                sliderView?.isPlaying = true
            case .paused:
                //print("Player is paused")
                sliderView?.isPlaying = false
            case .waitingToPlayAtSpecifiedRate:
                //print("Player is buffering or waiting")
                sliderView?.isPlaying = false
            @unknown default:
                //print("Unknown player state")
                sliderView?.isPlaying = false
            }
        }
    //MARK: END Player Functions
    

    //MARK: SETUP
    func setupTrimViewLocation(startTime:Double?,endTime:Double?)
    {
        guard let config = self.config else {return}
        
        // Set default start and end times if not provided
        let st = startTime ?? 0.0  // Default to the start of the video
        let et = endTime ?? config.duration  // Default to the entire video duration
        
        // Ensure the start and end times are valid
        let validStartTime = max(0, min(st, config.duration))  // Clamp start time within [0, duration]
        let validEndTime = max(validStartTime, min(et, config.duration))  // Clamp end time within [start, duration]
        
        // Calculate leading and trailing positions
        let newLeadingPosition = getLeadingPositionForTime(time: validStartTime)
        var newTrailingPosition = getTrailingPositionForTime(time: validEndTime)
        
        print("Start time = \(validStartTime) End Time = \(validEndTime)   \(newLeadingPosition) :: \(newTrailingPosition)")
        
        // Check if the trim duration exceeds the max allowed duration
        if config.maxTrimDuration < (validEndTime - validStartTime) {
            newTrailingPosition = newLeadingPosition + self.maxTrimWindowWidth
        }
        
        // Update constraints based on calculated positions
        adjustTrimConstraints(newLeadingWidth: newLeadingPosition,
                              newTrailingWidth: newTrailingPosition)
        
    }
    
    
    //Update Total View Width
    
    func updateTotalWidth()
    {
        viewTotalWidth = frame.width - (trimViewWidth * 2)
    }
    
    //Calculate Max and Min trim window size
    func updateMinMaxTrimWindowSize() {
        let totalWidth = getTotalWidth()
        guard totalWidth > 0 else {
            self.minTrimWindowWidth = 0
            self.maxTrimWindowWidth = 0
            return
        }

        
        if playerDuration == 0
        {
            self.minTrimWindowWidth = 0
            self.maxTrimWindowWidth = 0
            return
        }
        
        // Ensure valid duration
        let duration = max(playerDuration, 0.001)  // Avoid division by zero; fallback to a small positive number
       
        // Validate min and max trim durations
        let minDuration = max(0, config?.minTrimDuration ?? 0)
        let maxDuration = max(minDuration, config?.maxTrimDuration ?? duration)

        // Calculate the min and max trim window widths
        self.minTrimWindowWidth = totalWidth / CGFloat(duration) * CGFloat(minDuration)
        self.maxTrimWindowWidth = totalWidth / CGFloat(duration) * CGFloat(maxDuration)
    }
    //MARK: END SETUP
    
    func getDuration() -> Double
    {
        return max(playerDuration, 0.001)
    }
    
    func getTotalWidth() -> CGFloat
    {
        return self.viewTotalWidth
    }
    
    func getTrimWindowWidth() -> CGFloat
    {
        let width = getTotalWidth() - leadingTrimSpacerWidthConstraints.constant - trailingTrimSpacerWidthConstraints.constant
        
       // print("Width \(width) = \(getTotalWidth()) - \(leadingTrimSpacerWidthConstraints.constant) - \(trailingTrimSpacerWidthConstraints.constant) :: \(minTrimWindowWidth) || \(maxTrimWindowWidth)")
        
        return width
    }
    
    func getLeadingPositionForTime(time:Double) -> CGFloat
    {
        
        let totalWidth = getTotalWidth()
        
        let position = CGFloat(totalWidth)/CGFloat(getDuration()) * CGFloat(time)
        
        return position
    }
    
    func getTrailingPositionForTime(time:Double) -> CGFloat
    {
        let totalWidth = getTotalWidth()
       
        let position = (CGFloat(totalWidth)/CGFloat(getDuration())) * CGFloat(time)
        
        let trailingPosition = totalWidth - position
        
        return trailingPosition
    }
    
    
    
    func updateTrimLabels()
    {
        if trimMode == .SeekOnlyMode
        {
            return
        }
        
        if playerDuration == 0
        {
            leadingTrimLabel?.text = "00:00"
            trailingTrimLabel?.text = "00:00"
            return
        }
        
        //View width - leading and trailing spacer width - leading and trailing trim view width
        let totalWidth = getTotalWidth()
        
        
        //Note: Avoid using frame coordinates for calculation as frame size gets rounded off.
        let trimLeadingPosition =  leadingTrimSpacerWidthConstraints.constant
        let trimTrailingPosition = totalWidth - trailingTrimSpacerWidthConstraints.constant
        
        let duration_TotalWidthMultiplier = playerDuration/Double(totalWidth)
        
        let leadingTrimTime =  Double(trimLeadingPosition) * duration_TotalWidthMultiplier
        let trailingTrimTime = Double(trimTrailingPosition) * duration_TotalWidthMultiplier
        
       // print("Bounds \(self.bounds.width) Total \(totalWidth) Leading \(trimLeadingPosition) Trailing \(trimTrailingPosition)  LP \(leadingTrimTime) TP \(trailingTrimTime)")
        
        startTrimTime = leadingTrimTime
        endTrimTime = trailingTrimTime
        
        sliderView?.update(startTime: leadingTrimTime, endTime: trailingTrimTime)
        
        leadingTrimLabel?.text  = formatSecondsToString(leadingTrimTime)
        trailingTrimLabel?.text = formatSecondsToString(trailingTrimTime)
        
    }
    
    fileprivate func formatSecondsToString(_ seconds: Double) -> String {
        if seconds.isNaN
        {
            return ""
        }
        
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let Hr =  Int(Min/60)

        if Hr > 0
        {
            let newMin = Min%60
            let time = String(format: "%d:%02d:%02d",Hr, newMin, Sec)
            return time
        }
        else
        {
            return String(format: "%02d:%02d", Min, Sec)
        }
    }
    
    private func adjustTrimConstraints(newLeadingWidth: CGFloat, newTrailingWidth: CGFloat) {
        guard newLeadingWidth + newTrailingWidth + minTrimWindowWidth <= self.bounds.width else { return }
        
        leadingTrimSpacerWidthConstraints.constant = newLeadingWidth
        trailingTrimSpacerWidthConstraints.constant = newTrailingWidth
        updateTrimLabels()
    }
    
    private func adjustLeadingTrimConstraints(newLeadingWidth: CGFloat) {
        leadingTrimSpacerWidthConstraints.constant = newLeadingWidth
        updateTrimLabels()
    }
    
    private func adjustTrailingTrimConstraints(newTrailingWidth: CGFloat) {
        trailingTrimSpacerWidthConstraints.constant = newTrailingWidth
        updateTrimLabels()
    }
    
    //MARK: GESTURES
    @objc internal func handleLeadingPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            trimTabState = .beginToMove
        
        case .changed:
          
            handleLeadingPanGestureTranslation(translation: translation)
            gesture.setTranslation(.zero, in: self)
            trimTabState = .moving
   
        case .ended, .cancelled, .failed:
            // Add any additional logic for when the gesture ends
            //Reset Seek position if necessary
            trimTabState = .stoppedMoving
            break
            
        default:
            break
        }
    }
    
   
    internal func handleLeadingPanGestureTranslation(translation:CGPoint)
    {
        // Adjust the leading trim spacer view constraint based on the horizontal translation
        let newWidth = max(0, leadingTrimSpacerWidthConstraints.constant + translation.x)
        let trimWindowWidth = getTrimWindowWidth()
        
        let diff = leadingTrimSpacerWidthConstraints.constant - newWidth
        
        // If no change has occured exit
        if diff == 0
        {
            return
        }
        
        //Check if new trim window width will become less than the minTrimWindowWidth
        if trimWindowWidth + diff <= minTrimWindowWidth && translation.x > 0
        {
            let newPosition = getTotalWidth() - trailingTrimSpacerWidthConstraints.constant - minTrimWindowWidth
            adjustLeadingTrimConstraints(newLeadingWidth: newPosition)
            return
        }
        
        //Check for max trim window width :trimWindowWidth is less than maxTrimWindowWidth AND translation direction is left to right
        if trimWindowWidth + diff <= maxTrimWindowWidth || translation.x > 0
        {
            adjustLeadingTrimConstraints(newLeadingWidth: newWidth)
            return
        }
        
        
        //Pan both leading and trailing
        adjustTrimConstraints(newLeadingWidth:  newWidth,
                              newTrailingWidth: getTotalWidth() - newWidth - maxTrimWindowWidth)
      
        
    }
    
    @objc private func handleTrailingPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            trimTabState = .beginToMove
            
        case .changed:
            handleTrailingPanGestureTranslation(translation: translation)
            gesture.setTranslation(.zero, in: self)
            trimTabState = .moving
           
        case .ended, .cancelled, .failed:
            // Add any additional logic for when the gesture ends
            trimTabState = .stoppedMoving
            break
            
        default:
            break
        }
    }
    
    internal func handleTrailingPanGestureTranslation(translation:CGPoint)
    {
        // Adjust the trailing trim spacer width constraint based on the horizontal translation
        let newWidth = max(0, trailingTrimSpacerWidthConstraints.constant - translation.x)
        let trimWindowWidth = getTrimWindowWidth()
        
        let diff = trailingTrimSpacerWidthConstraints.constant - newWidth
        
 
        // If no change has occured exit
        if diff == 0 { return }
        
        //Check if new trim window width will become less than the minTrimWindowWidth
        if trimWindowWidth + diff <= minTrimWindowWidth && translation.x < 0
        {
            let newPosition = getTotalWidth() - leadingTrimSpacerWidthConstraints.constant - minTrimWindowWidth
            adjustTrailingTrimConstraints(newTrailingWidth: newPosition)
            return
        }
        
        //check for max trim window width: trimWindowWidth is less than maxTrimWindowWidth AND translation direction is right to left
        if trimWindowWidth + diff <= maxTrimWindowWidth || translation.x < 0
        {
            adjustTrailingTrimConstraints(newTrailingWidth: newWidth)
            return
        }
        
        //Pan both leading and trailing
        adjustTrimConstraints(newLeadingWidth: getTotalWidth() - newWidth - maxTrimWindowWidth,
                              newTrailingWidth: newWidth)
    }
    
    private func provideHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        
        print("Long Press")
        guard let panGesture = trimWindowView.gestureRecognizers?.first(where: { $0 is UIPanGestureRecognizer }) as? UIPanGestureRecognizer else { return }
        
        switch gesture.state {
        case .began:
            toogleTrimWindowState(panGesture: panGesture)
            break
        case .ended, .cancelled:
            print("Long Press Deactive")
            
        default:
            break
        }
    }
    
    func toogleTrimWindowState(panGesture: UIPanGestureRecognizer)
    {
        if panGesture.isEnabled == true
        {
            panGesture.isEnabled = false
            trimWindowView?.backgroundColor = config?.trimWindowViewConfig.normalBackgroundColor ?? .clear
        }
        else
        {
            panGesture.isEnabled = true
            trimWindowView?.backgroundColor = config?.trimWindowViewConfig.selectedBacgroundColor ?? .clear
        }
    }
    
    func trimWindowPan(translationX:CGFloat)
    {
        
        //Calculate leading Spacer View new Width and make sure it is greater than the minSpacerWidth
        let newLeadingWidth = max(0, leadingTrimSpacerWidthConstraints.constant + translationX)
        
        //Calculate trailing spacer width and make sure it is greater than minSpacerWidth
        let newTrailingWidth = max(0, trailingTrimSpacerWidthConstraints.constant - translationX)
        
        //Check if we have panned to the leading edge of the view
        if newLeadingWidth == 0
        {
            let diff = leadingTrimSpacerWidthConstraints.constant - newLeadingWidth
            if diff == 0 {return}
            adjustTrimConstraints(newLeadingWidth:  newLeadingWidth,
                                  newTrailingWidth: trailingTrimSpacerWidthConstraints.constant + diff)
            return
        }
        
        //Check if we have panned to the trailing edge of the view
        if newTrailingWidth == 0
        {
            let diff = trailingTrimSpacerWidthConstraints.constant - newTrailingWidth
            if diff == 0 {return}
            
            adjustTrimConstraints(newLeadingWidth:  leadingTrimSpacerWidthConstraints.constant + diff,
                                  newTrailingWidth: newTrailingWidth)
            
            return
        }
    
         
        // Ensure the trim window remains within bounds
        guard newLeadingWidth + newTrailingWidth + minTrimWindowWidth <= self.bounds.width else {
            print("Trim WIndow out of bounds")
            return
        }
   
        //Update leading and trailing constraints.
        adjustTrimConstraints(newLeadingWidth:  newLeadingWidth,
                              newTrailingWidth: newTrailingWidth)
        
     }
    
    @objc private func handleTrimWindowPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        //print ("Pan Start")
        switch gesture.state {
        case .began: trimTabState = .beginToMove
        
        case .changed:
        
            trimWindowPan(translationX: translation.x)
            gesture.setTranslation(.zero, in: self)
            
        case .ended, .cancelled, .failed:
            // Add any additional logic for when the gesture ends
            trimTabState = .stoppedMoving
            break
            
        default:
            break
        }
    }
    
    //MARK: END GESTURES
    
    func seek(to time: Double) {
            guard let player = player else { return }
        
            //Check for time outside bounds
            if time > getDuration() || time < 0 {return}
        
            let targetTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            
            player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                if finished {
                    print("Seek completed")
                }
            }
        }
}


extension VSTrimmerView:VSSliderViewDelegate
{
    func canSeekToPosition(position: Double) -> Bool {
        if position < 0 || position > 1 {return false}
        
        let newVideoPosition = position * self.getDuration()
        
        if newVideoPosition >= startTrimTime && newVideoPosition <= endTrimTime {
            return true
        }
        
        return false
        
    }
    
    func sliderSeekStateUpdate(state: Bool) {
        if state == true
        {
            self.player?.pause()
        }
        else
        {
            self.player?.play()
        }
    }
    
    func sliderSeekPositionChanged(position: Double) {
        
        let newVideoPosition = position * self.getDuration()
        seek(to: Double(newVideoPosition))
    }
    
    
    
    
}
