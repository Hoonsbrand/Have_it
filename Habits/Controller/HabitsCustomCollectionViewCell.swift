//
//  HabitsCustomCollectionViewCell.swift
//  Habits
//
//  Created by hoonsbrand on 2022/07/31.
//

import Foundation
import UIKit

class HabitsCustomCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var habitImg: UIImageView!
    @IBOutlet weak var habitLabel: UILabel!
    
    var imageName: String = "" {
        didSet {
            // cell UI 설정
            self.habitImg.image = UIImage(systemName: imageName)
        }
    }
    
    var labelName: String = "" {
        didSet {
            // cell label 설정
            self.habitLabel.text = labelName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 4
        contentView.layer.borderColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
    }
}
