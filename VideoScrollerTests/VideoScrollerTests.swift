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
@testable import VideoScroller

class VSTrimmerViewTests: XCTestCase {
    var trimmerView: VSTrimmerView!
    var config: VSTrimmerViewConfig!
   

    override func setUp() {
        super.setUp()
        trimmerView = VSTrimmerView(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        config = VSTrimmerViewConfig(
            maxTrimDuration: 30.0,
            minTrimDuration: 5.0,
            startTrimTime: 0.0,
            endTrimTime: 30.0,
            duration: 60.0,
            spacerViewColor: .gray,
            trimViewColor: .red,
            trimWindowSelectedStateColor: .blue,
            trimWindowNormalStateColor: .green,
            trimLabelFont: UIFont.systemFont(ofSize: 12),
            trimLabelFontColor: .black,
            trimLabelBackgroundColor: .white,
            trimLabelBorderRadius: 5.0
        )
        
    }

    override func tearDown() {
        trimmerView = nil
        config = nil
        super.tearDown()
    }

    func testLeadingPositionCalculation() {
        trimmerView.setup(config: config, sliderConfig: VSSliderViewConfig(
            color: .red,
            cornerRadius: 5.0,
            borderWidth: 1.0,
            borderColor: .black,
            sliderWidth: 10.0
        ), player: nil)

        let leadingPosition = trimmerView.getLeadingPositionForTime(time: 15.0)
        let expectedPosition = trimmerView.viewTotalWidth / CGFloat(config.duration) * 15.0
        XCTAssertEqual(leadingPosition, expectedPosition, accuracy: 0.1)
    }

    func testTrailingPositionCalculation() {
        trimmerView.setup(config: config, sliderConfig: VSSliderViewConfig(
            color: .red,
            cornerRadius: 5.0,
            borderWidth: 1.0,
            borderColor: .black,
            sliderWidth: 10.0
        ), player: nil)

        let trailingPosition = trimmerView.getTrailingPositionForTime(time: 15.0)
        let totalWidth = trimmerView.viewTotalWidth
        let expectedPosition = totalWidth - (totalWidth / CGFloat(config.duration) * 15.0)
        XCTAssertEqual(trailingPosition, expectedPosition, accuracy: 0.1)
    }
    
    func testLeadingPanGesture5Seconds() {
        trimmerView.setup(config: config, sliderConfig: VSSliderViewConfig(
            color: .red,
            cornerRadius: 5.0,
            borderWidth: 1.0,
            borderColor: .black,
            sliderWidth: 10.0
        ), player: nil)

        
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
        trimmerView.setup(config: config, sliderConfig: VSSliderViewConfig(
            color: .red,
            cornerRadius: 5.0,
            borderWidth: 1.0,
            borderColor: .black,
            sliderWidth: 10.0
        ), player: nil)

        
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
        trimmerView.setup(config: config, sliderConfig: VSSliderViewConfig(
            color: .red,
            cornerRadius: 5.0,
            borderWidth: 1.0,
            borderColor: .black,
            sliderWidth: 10.0
        ), player: nil)

       
        trimmerView.handleLeadingPanGestureTranslation(translation: CGPoint(x: 20, y: 0))

        XCTAssertEqual(trimmerView.leadingTrimSpacerWidthConstraints.constant, 20, accuracy: 0.1)
    }
    
    
    func testAutoPanGesture5Seconds() {
        trimmerView.setup(config: config, sliderConfig: VSSliderViewConfig(
            color: .red,
            cornerRadius: 5.0,
            borderWidth: 1.0,
            borderColor: .black,
            sliderWidth: 10.0
        ), player: nil)

        
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
   
}
