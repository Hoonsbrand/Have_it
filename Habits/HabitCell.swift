//
//  HabitCell.swift
//  Habits
//
//  Created by hoonsbrand on 2022/07/26.
//

import UIKit
import RealmSwift

protocol BookmarkCellDelegate {
    func bookmarkButtonTappedDelegate(_ habitCell: HabitCell, didTapButton button: UIButton) -> Bool?
}

class HabitCell: UITableViewCell {
    
    @IBOutlet weak var habitListBubble: UIView!
    @IBOutlet weak var bookmarkOutlet: UIButton!
    
    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
    var delegate: BookmarkCellDelegate?
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        habitListBubble.layer.cornerRadius = habitListBubble.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
        
        if let result = self.delegate?.bookmarkButtonTappedDelegate(self, didTapButton: sender) {
            if result {
                bookmarkOutlet.setTitle("⭐", for: .normal)
            } else {
                bookmarkOutlet.setTitle("☆", for: .normal)
            }
        }
    }
}

