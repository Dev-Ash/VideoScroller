//
//  VideoScrollerTests.swift
//  VideoScrollerTests
//
//  Created by Ashley Dsouza on 24/01/25.
//

import Testing

struct VideoScrollerTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}


import XCTest

@testable import VideoScrubber

class VSTrimmerViewTests: XCTestCase {
    var trimmerView: VSTrimmerView!
    var config: VSTrimmerViewConfig!
    var minMaxTrimWidthConfig:VSTrimmerViewConfig!
    
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

    
    
    

    override func setUp() {
        super.setUp()
        trimmerView = VSTrimmerView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        config = VSTrimmerViewConfig(
            maxTrimDuration: 30.0,
            minTrimDuration: 5.0,
            startTrimTime: 0.0,
            endTrimTime: 30.0,
            duration: 60.0,
            spacerViewColor: .white.withAlphaComponent(0.8),
            trimTabConfig:trimTabConfig ,
            trimLabelConfig: trimLabelConfig,
            trimWindowViewConfig: trimWindowViewConfig,
            sliderViewConfig: sliderConfig,
            trimMode: .Trim
        )
        
        minMaxTrimWidthConfig = VSTrimmerViewConfig(
                   maxTrimDuration: 30.0,
                   minTrimDuration: 5.0,
                   startTrimTime: 0.0,
                   endTrimTime: 30.0,
                   duration: 60.0,
                   spacerViewColor: .white.withAlphaComponent(0.8),
                   trimTabConfig:trimTabConfig ,
                   trimLabelConfig: trimLabelConfig,
                   trimWindowViewConfig: trimWindowViewConfig,
                   sliderViewConfig: sliderConfig,
                   trimMode: .Trim
               )
        
    }

    override func tearDown() {
        trimmerView = nil
        config = nil
        super.tearDown()
    }

    func testLeadingPositionCalculation() {
        trimmerView.setup(config: config, player: nil)

        let leadingPosition = trimmerView.getLeadingPositionForTime(time: 15.0)
        let expectedPosition = trimmerView.viewTotalWidth / CGFloat(config.duration) * 15.0
        XCTAssertEqual(leadingPosition, expectedPosition, accuracy: 0.1)
    }

    func testTrailingPositionCalculation() {
        trimmerView.setup(config: config, player: nil)

        let trailingPosition = trimmerView.getTrailingPositionForTime(time: 15.0)
        let totalWidth = trimmerView.viewTotalWidth
        let expectedPosition = totalWidth - (totalWidth / CGFloat(config.duration) * 15.0)
        XCTAssertEqual(trailingPosition, expectedPosition, accuracy: 0.1)
    }
    
    func testLeadingPanGesture5Seconds() {
        trimmerView.setup(config: config, player: nil)

        
        let distanceFor5Seconds = trimmerView.viewTotalWidth/CGFloat(trimmerView.getDuration()) * 5
        
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 5, accuracy: 0.1)
        
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 10, accuracy: 0.1)
        
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 15, accuracy: 0.1)
        
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 20, accuracy: 0.1)
        
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 25, accuracy: 0.1)
        
        //Minium Window width test
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 25, accuracy: 0.1)
        
    }
    
    func testTrailingPanGesture5Seconds() {
        trimmerView.setup(config: config, player: nil)

        
        let distanceFor5Seconds = trimmerView.viewTotalWidth/CGFloat(trimmerView.getDuration()) * 5
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 25, accuracy: 0.1)
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 20, accuracy: 0.1)
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 15, accuracy: 0.1)
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 10, accuracy: 0.1)
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 5, accuracy: 0.1)
        
        //Minium Window width test
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 5, accuracy: 0.1)
        
    
    }
    
    func testLeadingPanGesture() {
        trimmerView.setup(config: config, player: nil)

       
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: 20, y: 0))

        XCTAssertEqual(trimmerView.leadingTrimSpacerWidthConstraints.constant, 20, accuracy: 0.1)
    }
    
    
    func testAutoPanGesture5Seconds() {
        trimmerView.setup(config: config, player: nil)

        
        let distanceFor5Seconds = trimmerView.viewTotalWidth/CGFloat(trimmerView.getDuration()) * 5
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 35, accuracy: 0.1)
        XCTAssertEqual(trimmerView.startTrimTime, 5, accuracy: 0.1)
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime,  40, accuracy: 0.1)
        XCTAssertEqual(trimmerView.startTrimTime, 10, accuracy: 0.1)
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x:  distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 45, accuracy: 0.1)
        XCTAssertEqual(trimmerView.startTrimTime, 15, accuracy: 0.1)
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 50, accuracy: 0.1)
        XCTAssertEqual(trimmerView.startTrimTime, 20, accuracy: 0.1)
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 55, accuracy: 0.1)
        XCTAssertEqual(trimmerView.startTrimTime, 25, accuracy: 0.1)
        
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 60, accuracy: 0.1)
        XCTAssertEqual(trimmerView.startTrimTime, 30, accuracy: 0.1)
        
        //Check for on reach bounds stop
        trimmerView.handleTrailingPanGestureTranslation(translation: CGPoint(x: distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.endTrimTime, 60, accuracy: 0.1)
        XCTAssertEqual(trimmerView.startTrimTime, 30, accuracy: 0.1)
        
        //Leading Pan gesture test
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 25, accuracy: 0.1)
        XCTAssertEqual(trimmerView.endTrimTime, 55, accuracy: 0.1)
        
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 20, accuracy: 0.1)
        XCTAssertEqual(trimmerView.endTrimTime, 50, accuracy: 0.1)
        
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 15, accuracy: 0.1)
        XCTAssertEqual(trimmerView.endTrimTime, 45, accuracy: 0.1)
        
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 10, accuracy: 0.1)
        XCTAssertEqual(trimmerView.endTrimTime, 40, accuracy: 0.1)
        
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 5, accuracy: 0.1)
        XCTAssertEqual(trimmerView.endTrimTime, 35, accuracy: 0.1)
        
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 0, accuracy: 0.1)
        XCTAssertEqual(trimmerView.endTrimTime, 30, accuracy: 0.1)
        
        //Check for on reach bounds stop
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: -distanceFor5Seconds, y: 0))
        XCTAssertEqual(trimmerView.startTrimTime, 0, accuracy: 0.1)
        XCTAssertEqual(trimmerView.endTrimTime, 30, accuracy: 0.1)
      
    
    }
    
    // Test case for valid inputs
       func testUpdateMinMaxTrimWindowSizeWithValidInputs() {
           trimmerView.setup(config: minMaxTrimWidthConfig,  player: nil)
           
           // Given
           trimmerView.playerDuration = 60.0
           trimmerView.viewTotalWidth = 300.0

           // When
           trimmerView.updateMinMaxTrimWindowSize()

           // Then
           XCTAssertEqual(trimmerView.minTrimWindowWidth, 25.0, "Min trim window width should be calculated correctly.")
           XCTAssertEqual(trimmerView.maxTrimWindowWidth, 150.0, "Max trim window width should be calculated correctly.")
       }

       // Test case for zero duration
       func testUpdateMinMaxTrimWindowSizeWithZeroDuration() {
           trimmerView.setup(config: minMaxTrimWidthConfig, player: nil)
           
           // Given
           trimmerView.playerDuration = 0.0
           trimmerView.viewTotalWidth = 300.0

           // When
           trimmerView.updateMinMaxTrimWindowSize()

           // Then
           XCTAssertEqual(trimmerView.minTrimWindowWidth, 0.0, "Min trim window width should be 0 for zero duration.")
           XCTAssertEqual(trimmerView.maxTrimWindowWidth, 0.0, "Max trim window width should be 0 for zero duration.")
       }

       // Test case for zero total width
       func testUpdateMinMaxTrimWindowSizeWithZeroWidth() {
           trimmerView.setup(config: minMaxTrimWidthConfig,  player: nil)
           
           // Given
           trimmerView.playerDuration = 60.0
           trimmerView.viewTotalWidth = 0.0

           // When
           trimmerView.updateMinMaxTrimWindowSize()

           // Then
           XCTAssertEqual(trimmerView.minTrimWindowWidth, 0.0, "Min trim window width should be 0 for zero total width.")
           XCTAssertEqual(trimmerView.maxTrimWindowWidth, 0.0, "Max trim window width should be 0 for zero total width.")
       }

       // Test case for negative minTrimDuration
       func testUpdateMinMaxTrimWindowSizeWithNegativeMinDuration() {
           trimmerView.setup(config: minMaxTrimWidthConfig, player: nil)
           
           // Given
           trimmerView.config?.minTrimDuration = -10.0
           trimmerView.config?.maxTrimDuration = 30.0
           trimmerView.playerDuration = 60.0
           trimmerView.viewTotalWidth = 300.0
           
           // When
           trimmerView.config?.validate()
           trimmerView.updateMinMaxTrimWindowSize()

           // Then
           XCTAssertEqual(trimmerView.minTrimWindowWidth, 0.0, "Min trim window width should clamp to 0 for negative minTrimDuration.")
           XCTAssertEqual(trimmerView.maxTrimWindowWidth, 150.0, "Max trim window width should remain valid.")
       }

       // Test case for maxTrimDuration less than minTrimDuration
       func testUpdateMinMaxTrimWindowSizeWithInvalidMaxDuration() {
           trimmerView.setup(config: minMaxTrimWidthConfig,  player: nil)
           
           // Given
           trimmerView.config?.minTrimDuration = 20.0
           trimmerView.config?.maxTrimDuration = 10.0  // Invalid: max < min
           trimmerView.playerDuration = 60.0
           trimmerView.viewTotalWidth = 300.0

           // When
           trimmerView.config?.validate()
           trimmerView.updateMinMaxTrimWindowSize()

           // Then
           XCTAssertEqual(trimmerView.minTrimWindowWidth, 100.0, "Min trim window width should be calculated correctly.")
           XCTAssertEqual(trimmerView.maxTrimWindowWidth, 100.0, "Max trim window width should be adjusted to match minTrimDuration.")
       }

       // Test case for getDuration() returning 0.001 as fallback
       func testUpdateMinMaxTrimWindowSizeWithSmallFallbackDuration() {
           trimmerView.setup(config: minMaxTrimWidthConfig, player: nil)
           
           // Given
           trimmerView.playerDuration = 0.001
           trimmerView.viewTotalWidth = 300.0
           trimmerView.config?.minTrimDuration = 0.001
           trimmerView.config?.maxTrimDuration = 0.002

           // When
           trimmerView.config?.validate()
           trimmerView.updateMinMaxTrimWindowSize()

           // Then
           XCTAssertEqual(trimmerView.minTrimWindowWidth, 300.0, "Min trim window width should use fallback duration.")
           XCTAssertEqual(trimmerView.maxTrimWindowWidth, 600.0, "Max trim window width should use fallback duration.")
       }
   
}
