//
//  PausedHabitTableViewCell.swift
//  Habits
//
//  Created by hoonsbrand on 2022/08/18.
//

import UIKit
import SwipeCellKit

class PausedHabitTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var pausedHabitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
