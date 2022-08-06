//
//  CustomCellVC.swift
//  CompositionCollectionView
//
//  Created by 안지훈 on 8/6/22.
//

import Foundation
import UIKit

class CheckCustomCell : UICollectionViewCell{
    
    @IBOutlet weak var cellImage: UIImageView!
    
    var imgBackground = UIColor() {
        didSet{
            
            self.cellImage.backgroundColor = imgBackground
            //self.cellImage.tintColor = .white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderColor = UIColor.darkGray.cgColor
        self.contentView.layer.borderWidth = 0.5
        self.contentView.backgroundColor = .clear
        self.cellImage.layer.cornerRadius = 7

        
    }
    
    
}
