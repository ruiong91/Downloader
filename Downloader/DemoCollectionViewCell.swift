//
//  TestCollectionViewCell.swift
//  ImageLoadTest
//
//  Created by Rui Ong on 15/04/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit

class DemoCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "testCell"
        
    @IBOutlet weak var imageView: UIImageView!{
        didSet{
            imageView.layer.cornerRadius = imageView.frame.size.height/10
            imageView.clipsToBounds = true
        }
    }
    
//    override func prepareForReuse() {
//        imageView.image = nil
//        
//        super.prepareForReuse()
//    }
    
    @IBOutlet weak var noOfItemLabel: UILabel!
    
}
