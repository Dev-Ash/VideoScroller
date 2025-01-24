//
//  VSTrimmerView.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 09/12/24.
//

import UIKit
import Foundation
import AVFoundation

struct VSTrimmerViewConfig
{
    var maxTrimDuration:Float
    var minTrimDuration:Float
    
    var startTrimTime:Float
    var endTrimTime:Float
    
    var duration:Float
    
    var spacerViewColor:UIColor
    var trimViewColor:UIColor
    var trimWindowSelectedStateColor:UIColor
    var trimWindowNormalStateColor:UIColor
    
    var trimLabelFont:UIFont
    var trimLabelFontColor:UIColor
    var trimLabelBackgroundColor:UIColor
    var trimLabelBorderRadius:CGFloat
    
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
    }
}


class VSTrimmerView:BaseView
{
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var leadingTrimSpacerView: UIView!
    
    @IBOutlet weak var trailingTrimSpacerView: UIView!
    
    @IBOutlet weak var trailingTrimView: UIView!
    
    @IBOutlet weak var leadingTrimView: UIView!
    
    @IBOutlet weak var trimWindowView: UIView!
    
    @IBOutlet weak var sliderView: VSSliderView!
    //Constraints
    
    @IBOutlet weak var leadingTrimSpacerWidthConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var trailingTrimSpacerWidthConstraints: NSLayoutConstraint!
    
    
    @IBOutlet weak var trailingTrimWidthConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var leadingTrimWidthConstraints: NSLayoutConstraint!
    
    
    //Trim Labels
    @IBOutlet weak var leadingTrimLabel: UILabel!
    @IBOutlet weak var trailingTrimLabel: UILabel!
    
    
    var playerDuration:Float = 0
    var currentPosition:CGFloat = 0
    
    var startTrimTime:Float = 0
    var endTrimTime:Float = 0
    
    var minTrimWindowWidth:CGFloat = 0
    var maxTrimWindowWidth:CGFloat = 0
    
    var viewTotalWidth:CGFloat = 0
    
    //Width for each trim view
    var trimViewWidth:CGFloat = 20
    
    var panGesture:UIPanGestureRecognizer?
    
    var config:VSTrimmerViewConfig?
    
    weak var player:AVPlayer?
    var timeObserverToken: Any?

    
    override var nibName: String
    {
        return "VSTrimmerView"
    }
    
    override func xibSetup() {
        super.xibSetup()
        setupGestures()
        leadingTrimSpacerView?.backgroundColor  = .lightGray.withAlphaComponent(0.5)
        trailingTrimSpacerView?.backgroundColor = .lightGray.withAlphaComponent(0.5)
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
    
    private func setupGestures() {
        // Adding pan gesture to the leading trim spacer view
        let leadingPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLeadingPanGesture(_:)))
        leadingTrimView.addGestureRecognizer(leadingPanGesture)
        
        // Adding pan gesture to the trailing trim spacer view
        let trailingPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTrailingPanGesture(_:)))
        trailingTrimView.addGestureRecognizer(trailingPanGesture)
        
        // Long press and pan gesture for the trim window
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTrimWindowPan(_:)))
        
        trimWindowView.addGestureRecognizer(longPressGesture)
        trimWindowView.addGestureRecognizer(panGesture!)
        
        panGesture?.isEnabled = false // Initially disable pan gesture
        
        self.leadingTrimView?.isUserInteractionEnabled = true
        self.trailingTrimView?.isUserInteractionEnabled = true
        self.trimWindowView?.isUserInteractionEnabled = true
        
        self.isUserInteractionEnabled = true
    }
    
    func setup(config:VSTrimmerViewConfig,sliderConfig:VSSliderViewConfig, player:AVPlayer?)
    {
        //Validate config
        self.config = config
        self.config?.validate()
        
        leadingTrimView?.backgroundColor = self.config!.trimViewColor
        trailingTrimView?.backgroundColor = self.config!.trimViewColor
        
        leadingTrimSpacerView?.backgroundColor = self.config!.spacerViewColor
        trailingTrimSpacerView?.backgroundColor = self.config!.spacerViewColor
        
        trimWindowView?.backgroundColor = self.config!.trimWindowNormalStateColor
        panGesture?.isEnabled = false
    
        //TODO: Add trim view width to config
        leadingTrimWidthConstraints.constant = trimViewWidth
        trailingTrimWidthConstraints.constant = trimViewWidth
        
        playerDuration = self.config!.duration
        
        leadingTrimLabel?.font = self.config!.trimLabelFont
        leadingTrimLabel?.textColor = self.config!.trimLabelFontColor
        
        trailingTrimLabel?.font = self.config!.trimLabelFont
        trailingTrimLabel?.textColor = self.config!.trimLabelFontColor
        
        leadingTrimView.accessibilityLabel = "Start Trim Handle"
        trailingTrimView.accessibilityLabel = "End Trim Handle"
        

        
        self.view.layoutIfNeeded()
        
        //Caclculate total View Width
        updateTotalWidth()
        
        //Setup Slider View
        sliderView?.setup(config: sliderConfig, leadingAndTrailingSpace: trimViewWidth,startTime: 0,endTime: self.getDuration())
        
        //Calculate max and min trim window width
        updateMinMaxTrimWindowSize()
        
        
        //Setup initial Trim location
        setupTrimViewLocation(startTime: self.config!.startTrimTime, endTime: self.config!.endTrimTime)
        
        updateTrimLabels()
        
        self.player = player
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
                print("Current playback time: \(currentTime) seconds")
                
               // strongSelf.sliderView?.updateSliderLocation(position: Float(currentTime), duration: strongSelf.getDuration())

                // Update any UI components with the current time here, if needed
            }
        }
    
    // Observe changes to timeControlStatus
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            guard keyPath == "timeControlStatus", let player = object as? AVPlayer else { return }

            switch player.timeControlStatus {
            case .playing:
                print("Player is playing")
                sliderView?.isPlaying = true
            case .paused:
                print("Player is paused")
                sliderView?.isPlaying = false
            case .waitingToPlayAtSpecifiedRate:
                print("Player is buffering or waiting")
                sliderView?.isPlaying = false
            @unknown default:
                print("Unknown player state")
                sliderView?.isPlaying = false
            }
        }
    //MARK: END Player Functions
    

    //MARK: SETUP
    func setupTrimViewLocation(startTime:Float?,endTime:Float?)
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
    
    func getDuration() -> Float
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
        
        print("Width \(width) = \(getTotalWidth()) - \(leadingTrimSpacerWidthConstraints.constant) - \(trailingTrimSpacerWidthConstraints.constant) :: \(minTrimWindowWidth) || \(maxTrimWindowWidth)")
        
        return width
    }
    
    func getLeadingPositionForTime(time:Float) -> CGFloat
    {
        
        let totalWidth = getTotalWidth()
        
        let position = CGFloat(totalWidth)/CGFloat(getDuration()) * CGFloat(time)
        
        return position
    }
    
    func getTrailingPositionForTime(time:Float) -> CGFloat
    {
        let totalWidth = getTotalWidth()
       
        let position = (CGFloat(totalWidth)/CGFloat(getDuration())) * CGFloat(time)
        
        let trailingPosition = totalWidth - position
        
        return trailingPosition
    }
    
    
    
    func updateTrimLabels()
    {
        if playerDuration == 0
        {
            leadingTrimLabel?.text = "00:00"
            trailingTrimLabel?.text = "00:00"
            return
        }
        
        //View width - leading and trailing spacer width - leading and trailing trim view width
        let totalWidth = getTotalWidth()
        
        
        //Note: Avoid using frame coordinates for calculation as contraints get rounded off.
        let trimLeadingPosition =  leadingTrimSpacerWidthConstraints.constant
        let trimTrailingPosition = totalWidth - trailingTrimSpacerWidthConstraints.constant
        
        let duration_TotalWidthMultiplier = playerDuration/Float(totalWidth)
        
        let leadingTrimTime =  Float(trimLeadingPosition) * duration_TotalWidthMultiplier
        let trailingTrimTime = Float(trimTrailingPosition) * duration_TotalWidthMultiplier
        
       // print("Bounds \(self.bounds.width) Total \(totalWidth) Leading \(trimLeadingPosition) Trailing \(trimTrailingPosition)  LP \(leadingTrimTime) TP \(trailingTrimTime)")
        
        startTrimTime = leadingTrimTime
        endTrimTime = trailingTrimTime
        
        sliderView?.update(startTime: leadingTrimTime, endTime: trailingTrimTime)
        
        leadingTrimLabel?.text  = formatSecondsToString(leadingTrimTime)
        trailingTrimLabel?.text = formatSecondsToString(trailingTrimTime)
        
    }
    
    fileprivate func formatSecondsToString(_ seconds: Float) -> String {
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
        case .changed:
          
            handleLeadingPanGestureTranslation(translation: translation)
            gesture.setTranslation(.zero, in: self)
   
        case .ended, .cancelled, .failed:
            // Add any additional logic for when the gesture ends
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
        case .changed:
            handleTrailingPanGestureTranslation(translation: translation)
            gesture.setTranslation(.zero, in: self)
           
        case .ended, .cancelled, .failed:
            // Add any additional logic for when the gesture ends
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
            trimWindowView?.backgroundColor = config!.trimWindowNormalStateColor
        }
        else
        {
            panGesture.isEnabled = true
            trimWindowView?.backgroundColor = config!.trimWindowSelectedStateColor
        }
    }
    
    func trimWindowPan(translationX:CGFloat)
    {
        guard let trimWindowWidth = trimWindowView?.frame.width else {
            return
        }
        
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
        case .changed:
        
            trimWindowPan(translationX: translation.x)
            gesture.setTranslation(.zero, in: self)
            
        default:
            break
        }
    }
    
    //MARK: END GESTURES
    
   
}
