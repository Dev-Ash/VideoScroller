//
//  VideoThumbnail_CV.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 26/09/24.
//

import Foundation
import UIKit
import AVFoundation

public struct VSVideoThumbnail_CVConfig
{
    var interItemSpacing:CGFloat
    var imageScaling:UIView.ContentMode
    var miniumCellWidth:CGFloat
    
    
    mutating func validate()
    {
        if interItemSpacing < 0 {
            interItemSpacing = 0
        }
        
        if miniumCellWidth <= 0 {
            miniumCellWidth = 50
        }
    }
    
    public init(interItemSpacing: CGFloat, imageScaling: UIView.ContentMode, miniumCellWidth: CGFloat) {
        self.interItemSpacing = interItemSpacing
        self.imageScaling = imageScaling
        self.miniumCellWidth = miniumCellWidth
        
        validate()
    }
}

public class VSVideoThumbnail_CV:BaseView
{
    public override var nibName: String
    {
        return "VSVideoThumbnail_CV"
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var videoThumbnails:[UIImage] = []
    var images:[UIImage]?
    var aspectRatio:CGFloat = 0
    
    var interItemSpacing:CGFloat = 0
    var videoDuration:Double = 0
    
    var config:VSVideoThumbnail_CVConfig?
    
    var partialImage:Double = 0
    
    var miniumCellWidth:CGFloat = 50
    
    public override func xibSetup() {
        super.xibSetup()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // Horizontal scrolling
        // layout.itemSize = CGSize(width: 200, height: 200) // Define item size
        layout.minimumLineSpacing = 2 // Spacing between items
        
        self.collectionView?.collectionViewLayout = layout
        self.collectionView?.isScrollEnabled = false
        
        // Register the custom cell
        self.collectionView?.register(UINib(nibName: VS_ImageCell.identifier, bundle: Bundle(for: VS_ImageCell.classForCoder())), forCellWithReuseIdentifier: VS_ImageCell.identifier)
        
        // Set the data source and delegate
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupView()
    {
        
        if videoThumbnails.count == 0 {return}
        
        // let thumbnailWidth =  self.collectionView.frame.height / aspectRatio
        //let noOfThumbnails = Double(self.collectionView.frame.width/(thumbnailWidth+interItemSpacing))
        
        let collectionHeight = self.collectionView.frame.height
        let baseThumbnailWidth = collectionHeight / aspectRatio
        let availableWidth = self.collectionView.frame.width
        let minThumbnailWidth: CGFloat = miniumCellWidth  // Ensure thumbnails are not too small
        
        // Calculate total spacing based on estimated number of thumbnails
        let estimatedThumbnails = availableWidth / baseThumbnailWidth
        let totalSpacing = interItemSpacing * (estimatedThumbnails - 1) // Adjust spacing dynamically
        
        // Adjust available width to account for spacing
        let adjustedAvailableWidth = availableWidth - totalSpacing
        
        // Ensure noOfThumbnails respects available space
        let maxThumbnails = adjustedAvailableWidth / max(baseThumbnailWidth, minThumbnailWidth)
        let noOfThumbnails = min(maxThumbnails, Double(videoThumbnails.count))  // Limit to available images
        
        if Int(noOfThumbnails) == videoThumbnails.count
        {
            self.images = videoThumbnails
        }
        else if Int(noOfThumbnails) < videoThumbnails.count
        {
            self.images = createNewArrayWithLessImages(images:videoThumbnails,targetCount: noOfThumbnails)
        }
        else
        {
            self.images = createNewArrayWithMoreImages(images:videoThumbnails, targetCount: noOfThumbnails)
        }
        
        
        self.collectionView?.reloadData()
    }
    
    func createNewArrayWithLessImages(images: [UIImage], targetCount: Double) -> [UIImage] {
        guard targetCount > 0, !images.isEmpty else { return [] }
        
        let totalImages = images.count
        if Int(targetCount) >= totalImages { return images } // No need to reduce if target count is greater
        
        let step = Double(totalImages) / targetCount
        var newImages: [UIImage] = []
        
        for i in 0..<Int(targetCount) {
            let index = Int(round(Double(i) * step))
            newImages.append(images[min(index, totalImages - 1)])
        }
        
        //Add partial image if present
        if let partialImage = createPartialImage(images: newImages, targetCount: targetCount)
        {
            newImages.append(partialImage)
        }
        
        return newImages
    }
    
    func createNewArrayWithMoreImages(images: [UIImage], targetCount: Double) -> [UIImage] {
        let totalImages = images.count
        guard totalImages > 0 else { return [] }
        
        var newImages: [UIImage] = []
        
        for i in 0..<Int(targetCount) {
            let factor = Double(i) / Double(targetCount - 1) * Double(totalImages - 1)
            let lowerIndex = Int(floor(factor))
            let upperIndex = min(lowerIndex + 1, totalImages - 1)
            let ratio = factor - Double(lowerIndex)
            
            let newImage = blendImages(image1: images[lowerIndex], image2: images[upperIndex], ratio: ratio)
            newImages.append(newImage)
        }
        
        //Add partial image if present
        if let partialImage = createPartialImage(images: newImages, targetCount: targetCount)
        {
            newImages.append(partialImage)
        }
        
        
        return newImages
    }
    
    func createPartialImage(images:[UIImage],targetCount:Double) -> UIImage?
    {
        let partialCount = targetCount - Double(images.count)
        
        //Check if targetCount has no partial image
        if partialCount == 0 {return nil }
        
        // Add the last image again as a partial image
        if let lastImage = images.last {
            let fadedLastImage = blendImages(image1: lastImage, image2: UIImage(), ratio: 0.5) // 50% transparent
            return fadedLastImage
        }
        
        return nil
    }
    
    // Helper function to blend two images
    func blendImages(image1: UIImage, image2: UIImage, ratio: CGFloat) -> UIImage {
        let size = image1.size
        UIGraphicsBeginImageContext(size)
        image1.draw(at: .zero, blendMode: .normal, alpha: 1.0 - ratio)
        image2.draw(at: .zero, blendMode: .normal, alpha: ratio)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image1
    }
    
    func setup(config:VSVideoThumbnail_CVConfig,asset:AVAsset) async
    {
        self.config = config
        self.interItemSpacing = config.interItemSpacing
        self.miniumCellWidth = config.miniumCellWidth
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // Horizontal scrolling
        layout.minimumLineSpacing = config.interItemSpacing // Spacing between items
        
        self.collectionView?.collectionViewLayout = layout
        
        guard let videoURL = Bundle.main.url(forResource: "vert2", withExtension: "mp4")
        else {
            print("Video file not found")
            return
        }
        
        // scrollView?.bounces = false
        
        let thumbnailExtractor = VideoThumbnailExtractor(asset: asset)
        let videoSize = VideoThumbnailExtractor.getVideoSize(url: videoURL)
        self.aspectRatio = max(16/9, videoSize.height/videoSize.width)
        
        self.videoDuration = VideoThumbnailExtractor.getvideoDuration(videoURL: videoURL)
        
        
        
        
        let intervalBetweenThumbnails = 1.0
        
        
        await thumbnailExtractor.generateThumbnails(every: intervalBetweenThumbnails) {[weak self] thumbnails in
            
            guard let strongSelf = self else {return}
            
            strongSelf.videoThumbnails = thumbnails
            
            strongSelf.setupView()
            
            // strongSelf.holderViewWidthConstraint.constant = CGFloat((90 * 360)/640 + strongSelf.InterItemSpacing) * CGFloat(thumbnails.count) + 2 * strongSelf.SpacerViewWidth
        }
    }
    
}


extension VSVideoThumbnail_CV:UICollectionViewDataSource
{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0 // Number of items
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let item = images?[indexPath.row] else
        {
            return UICollectionViewCell()
        }
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VS_ImageCell.identifier, for: indexPath) as? VS_ImageCell else {
            return UICollectionViewCell()
        }
        cell.setupCell(image: item,
                       aspectRatio: aspectRatio,
                       contentMode: config?.imageScaling ?? UIView.ContentMode.scaleAspectFit)
        return cell
    }
}

extension VSVideoThumbnail_CV:UICollectionViewDelegateFlowLayout
{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let minThumbnailWidth: CGFloat = miniumCellWidth
        let cellWidth = max(self.collectionView.frame.height / aspectRatio, minThumbnailWidth)
        
        return CGSize(width: cellWidth, height: self.collectionView.frame.height)
        
        // return CGSize(width: self.collectionView.frame.height/aspectRatio, height: self.collectionView.frame.height)
    }
    
    
}
