//
//  VideoThumbnail_CV.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 26/09/24.
//

import Foundation
import UIKit

public class VideoThumbnail_CV:BaseView
{
    public override var nibName: String
    {
        return "VideoThumbnail_CV"
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images:[UIImage]?
    var aspectRatio:CGFloat = 0
    
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
    
    func setupView(images:[UIImage],aspectRatio:CGFloat)
    {
        self.images = images
        self.aspectRatio = aspectRatio
        self.collectionView?.reloadData()
    }
    
}


extension VideoThumbnail_CV:UICollectionViewDataSource
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
           cell.setupCell(image: item)
           return cell
       }
}

extension VideoThumbnail_CV:UICollectionViewDelegateFlowLayout
{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.collectionView.frame.height/aspectRatio, height: self.collectionView.frame.height)
    }
}
