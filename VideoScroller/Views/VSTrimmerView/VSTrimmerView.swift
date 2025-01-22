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
    
    var leadingTrimPosition:Float = 0
    var trailingTrimPosition:Float = 0
    
    var startTrimTime:Float = 0
    var endTrimTime:Float = 0
    
    var minTrimWindowWidth:CGFloat = 100
    var maxTrimWindowWidth:CGFloat = 100
    
    var minSpacerWidth:CGFloat = 0
    
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
        
        
        leadingTrimSpacerView?.backgroundColor = .lightGray.withAlphaComponent(0.5)
        
        trailingTrimSpacerView?.backgroundColor = .lightGray.withAlphaComponent(0.5)
        
        leadingTrimView?.backgroundColor = .red
        trailingTrimView?.backgroundColor = .red
    }
    
    deinit {
           // Remove the periodic time observer when the view controller is deallocated
           if let timeObserverToken = timeObserverToken {
               player?.removeTimeObserver(timeObserverToken)
               self.timeObserverToken = nil
           }
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
        
        leadingTrimView?.backgroundColor = config.trimViewColor
        trailingTrimView?.backgroundColor = config.trimViewColor
        
        leadingTrimSpacerView?.backgroundColor = config.spacerViewColor
        trailingTrimSpacerView?.backgroundColor = config.spacerViewColor
        
        trimWindowView?.backgroundColor = config.trimWindowNormalStateColor
        panGesture?.isEnabled = false
    
        //TODO: Add trim view width to config
        leadingTrimWidthConstraints.constant = trimViewWidth
        trailingTrimWidthConstraints.constant = trimViewWidth
        
        playerDuration = config.duration
        
        leadingTrimLabel?.font = config.trimLabelFont
        leadingTrimLabel?.textColor = config.trimLabelFontColor
        
        trailingTrimLabel?.font = config.trimLabelFont
        trailingTrimLabel?.textColor = config.trimLabelFontColor
        
        leadingTrimView.accessibilityLabel = "Start Trim Handle"
        trailingTrimView.accessibilityLabel = "End Trim Handle"
        
        self.config = config
        
        self.view.layoutIfNeeded()
        //Setup Slider View
        sliderView?.setup(config: sliderConfig, leadingAndTrailingSpace: minSpacerWidth + trimViewWidth,startTime: 0,endTime: self.getDuration())
        
        //calculate max and min trim window width
        updateMiniumTrimeWindowSize()
        
        
        
        //Setup initial Trim location
        setupTrimViewLocation(startTime: config.startTrimTime, endTime: config.endTrimTime)
        
        
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
    func setupTrimViewLocation(startTime:Float?,endTime:Float?)
    {
        guard let config = self.config else {return}
        
       // if config.maxTrimDuration > config.duration {return}
        
        // TODO:Update Trim location if leading and trailing trim location is avalible
        
        //Update Trailing trim location
        
       
        if let st = startTime, let et = endTime
        {
            let newLeadingPosition = getLeadingPositionForTime(time: st)
            let newTrailingPosition = getTrailingPositionForTime(time: et)
            
            print("Start time = \(startTime) End Time \(endTime)   \(newLeadingPosition) :: \(newTrailingPosition)")
            
            leadingTrimSpacerWidthConstraints.constant  = newLeadingPosition
            trailingTrimSpacerWidthConstraints.constant = newTrailingPosition
            
            self.view.layoutIfNeeded()
            //TODO: Max trim duration check
            
            updateTrimLabels()
            
            self.startTrimTime = st
            self.endTrimTime = et
            return
        }
        
        
        if config.maxTrimDuration > config.duration {
            self.startTrimTime = 0
            self.endTrimTime = config.duration
            return
        }
        
        
        self.startTrimTime = 0
        self.endTrimTime = config.maxTrimDuration
        
        let totalWidth = getTotalWidth()
        let newTrailingPosition = getTrailingPositionForTime(time: config.maxTrimDuration)
        
        trailingTrimSpacerWidthConstraints.constant = newTrailingPosition
        updateTrimLabels()
        
    }
    
    func getTotalWidth() -> CGFloat
    {
        //view width - minSpacerWidth(Extra margin leading and trailing) - trim view width * 2
        return  self.frame.width - (minSpacerWidth * 2) - (trimViewWidth * 2)
    }
    
    func getLeadingPositionForTime(time:Float) -> CGFloat
    {
        
        let totalWidth = getTotalWidth()
        
        let position = CGFloat(totalWidth)/CGFloat(getDuration()) * CGFloat(time) + minSpacerWidth
        
        return position
    }
    
    func getTrailingPositionForTime(time:Float) -> CGFloat
    {
        let totalWidth = getTotalWidth()
       
        let position = (CGFloat(totalWidth)/CGFloat(getDuration())) * CGFloat(time)
        
        let trailingPosition = totalWidth - position
        
        return trailingPosition
    }
    
    //Caculate Max and Min trim window size
    func updateMiniumTrimeWindowSize()
    {
        let totalWidth = getTotalWidth()
        
        guard let minDuration = config?.minTrimDuration, let maxDuration = config?.maxTrimDuration else {return}
        
        self.minTrimWindowWidth = totalWidth / CGFloat(getDuration()) * CGFloat(minDuration)
        
        self.maxTrimWindowWidth = totalWidth / CGFloat(getDuration()) * CGFloat(maxDuration)
        
    }
    
    func getDuration() -> Float
    {
        return self.playerDuration
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
        
        //trimWindowView.frame.origin.x - trimViewWidth( to move x to the leading TrimView origin x)
        //This is done to start the leading position from 0
        //default trimWindowView.frame.origin.x = width of the time window so trimViewWidth is subtracted
        //from origin.x to set inital position to 0
        let trimWindowLeadingPosition = trimWindowView.frame.origin.x - trimViewWidth
        
        //The trimWindowView.frame.width is the actual trim duration so adding
        //trimWindowTrailingPosition + trim window width gives the trailing position
        let trimWindowTrailingPosition = trimWindowLeadingPosition + trimWindowView.frame.width
        
        let leadingTrimTime = Float((trimWindowLeadingPosition)/(totalWidth)) * playerDuration
        let trailingTrimTime = Float((trimWindowTrailingPosition)/(totalWidth)) * playerDuration
        
        print("Bounds \(self.bounds.width) Total \(totalWidth) Leading \(trimWindowLeadingPosition) Trailing \(trimWindowTrailingPosition)  LP \(leadingTrimTime) TP \(trailingTrimTime)")
        
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
    
    @objc private func handleLeadingPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .changed:
            // Adjust the leading trim spacer view constraint based on the horizontal translation
            guard let trimWindowWidth = trimWindowView?.frame.width else {
                gesture.setTranslation(.zero, in: self)
                return
            }
            
            
            
            let newWidth = max(minSpacerWidth, leadingTrimSpacerWidthConstraints.constant + translation.x)
            
            if newWidth != minSpacerWidth && trimWindowWidth - translation.x <= minTrimWindowWidth
            {
                gesture.setTranslation(.zero, in: self)
                provideHapticFeedback()
                return
            }
            
            print("New leading width :\(newWidth)  trimWindow = \(trimWindowView!.frame.width)")
            leadingTrimSpacerWidthConstraints.constant = newWidth
            gesture.setTranslation(.zero, in: self)
            updateTrimLabels()
            
        case .ended, .cancelled, .failed:
            // Add any additional logic for when the gesture ends
            break
            
        default:
            break
        }
    }
    
    @objc private func handleTrailingPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .changed:
            // Adjust the trailing trim spacer width constraint based on the horizontal translation
            guard let trimWindowWidth = trimWindowView?.frame.width else {
                gesture.setTranslation(.zero, in: self)
                return
            }
            
            let newWidth = max(minSpacerWidth, trailingTrimSpacerWidthConstraints.constant - translation.x)
            
            if newWidth != minSpacerWidth && trimWindowWidth + translation.x <= minTrimWindowWidth
            {
                gesture.setTranslation(.zero, in: self)
                provideHapticFeedback()
                return
            }
            
            print("New trailing width :\(newWidth) : \(translation.x) : trimWindow = \(trimWindowView!.frame.width)")
            trailingTrimSpacerWidthConstraints.constant = newWidth
            gesture.setTranslation(.zero, in: self)
            updateTrimLabels()
            
        case .ended, .cancelled, .failed:
            // Add any additional logic for when the gesture ends
            break
            
        default:
            break
        }
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
    
    
    @objc private func handleTrimWindowPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        //print ("Pan Start")
        switch gesture.state {
        case .changed:
        
            guard let trimWindowWidth = trimWindowView?.frame.width else {
                gesture.setTranslation(.zero, in: self)
                return
            }
            
            //Calculate leading Spacer View new Width and make sure it is greater than the minSpacerWidth
            let newLeadingWidth = max(minSpacerWidth, leadingTrimSpacerWidthConstraints.constant + translation.x)
            
            //Calculate trailing spacer width and make sure it is greater than minSpacerWidth
            let newTrailingWidth = max(minSpacerWidth, trailingTrimSpacerWidthConstraints.constant - translation.x)
            
            //Check if we have panned to the leading edge of the view
            if newLeadingWidth == minSpacerWidth
            {
                leadingTrimSpacerWidthConstraints.constant = newLeadingWidth
                gesture.setTranslation(.zero, in: self)
                updateTrimLabels()
                return
            }
            
            //Check if we have panned to the trailing edge of the view
            if newTrailingWidth == minSpacerWidth
            {
                trailingTrimSpacerWidthConstraints.constant = newTrailingWidth
                gesture.setTranslation(.zero, in: self)
                updateTrimLabels()
                return
            }
            
        
             
            // Ensure the trim window remains within bounds
            guard newLeadingWidth + newTrailingWidth + minTrimWindowWidth <= self.bounds.width else {
                print("Trim WIndow out of bounds")
                gesture.setTranslation(.zero, in: self)
                return
            }
            
            
            
            print("Trim Window move")
            
            //Update leading and trailing constraints.
            leadingTrimSpacerWidthConstraints.constant = newLeadingWidth
            trailingTrimSpacerWidthConstraints.constant = newTrailingWidth
            gesture.setTranslation(.zero, in: self)
            updateTrimLabels()
            
        default:
            break
        }
    }
    
   
}
