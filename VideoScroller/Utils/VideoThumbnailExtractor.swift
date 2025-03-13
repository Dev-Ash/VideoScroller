//
//  VideoThumbnailExtractor.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 26/09/24.
//

import Foundation
import AVFoundation
import UIKit

class VideoThumbnailExtractor {
    
    private var asset: AVAsset
    private var generator: AVAssetImageGenerator
    
    init(asset: AVAsset) {
        self.asset = asset
        self.generator = AVAssetImageGenerator(asset: asset)
        self.generator.appliesPreferredTrackTransform = true
        self.generator.maximumSize = CGSize(width: 200, height: 200)
        self.generator.requestedTimeToleranceBefore = CMTime.zero
        self.generator.requestedTimeToleranceAfter = CMTime.zero
    }
    
    func generateThumbnails(every second: Double, completion: @escaping ([UIImage]) -> Void) async {
        do
        {
            let duration = try await asset.load(.duration)
            let totalSeconds = CMTimeGetSeconds(duration)
            
            var times = [NSValue]()
            
            for currentSecond in stride(from: 0.0, to: totalSeconds, by: second) {
                let time = CMTimeMakeWithSeconds(currentSecond, preferredTimescale: 600)
                times.append(NSValue(time: time))
            }
            
            var thumbnails = [UIImage]()
            
            let group = DispatchGroup() // To handle async completion
            
            for time in times {
                group.enter()
                generator.generateCGImagesAsynchronously(forTimes: [time]) { _, image, _, _, error in
                    if let cgImage = image, error == nil {
                        
                        let thumbnail = UIImage(cgImage: cgImage)
                        thumbnails.append(thumbnail)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(thumbnails)
            }
        }
        catch
        {
            print("Failed to get Images")
        }
    }
    
    
    
    class func getVideoSize(url: URL) -> CGSize {
        // Create an AVAsset instance with the video URL
        let asset = AVAsset(url: url)
        
        let defaultSize = CGSize(width: 400, height: 400)
        
        // Get the first video track from the asset
        guard let track = asset.tracks(withMediaType: .video).first else {
            return defaultSize
        }
        
        // Return the natural size of the video track
        print("Video Size \(track.naturalSize)")
        return getCorrectVideoSize(for: track)
    }
    
    class func getCorrectVideoSize(for assetTrack: AVAssetTrack) -> CGSize {
        let size = assetTrack.naturalSize
        let transform = assetTrack.preferredTransform
        
        // Determine the correct orientation and adjust the size accordingly
        let videoAngleInDegree = atan2(transform.b, transform.a) * 180 / .pi
        var correctedSize = size
        
        if videoAngleInDegree == 90 || videoAngleInDegree == -90 {
            // Swap width and height if the video is rotated by 90 degrees
            correctedSize = CGSize(width: size.height, height: size.width)
        }
        
        return correctedSize
    }
    
    public class func getvideoDuration(videoURL:URL) -> Float64
    {
        let asset = AVAsset(url: videoURL)
        let duration = CMTimeGetSeconds(asset.duration)
        
        return duration
    }

}
