//
//  CustomCell.swift
//  SwappingCollectionView
//
//  Created by Admin on 03.08.2017.
//  Copyright © 2017 Paweł Łopusiński. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.borderWidth = 0.3
        imageView.layer.borderColor = UIColor.white.cgColor
        
        
        
        
    }
    
}
