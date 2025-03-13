//
//  VS_ImageCell.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 26/09/24.
//

import Foundation
import UIKit

public class VS_ImageCell:UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    public static let identifier = "VS_ImageCell"
    
    func setupCell(image:UIImage?,aspectRatio:Double,contentMode:UIView.ContentMode)
    {

        imageView?.image = nil
        imageView?.image = image
        imageView?.contentMode = contentMode
        imageView.clipsToBounds = true
    
    }
}
