//
//  HabitCell.swift
//  Habits
//
//  Created by hoonsbrand on 2022/07/26.
//

import UIKit
import RealmSwift

// MARK: - 즐겨찾기 버튼 누를 때 Realm 데이터에 넣기위한 프로토콜
protocol BookmarkCellDelegate {
    func bookmarkButtonTappedDelegate(_ habitCell: HabitCell, didTapButton button: UIButton) -> Bool?
}

// MARK: - 즐겨찾기 버튼 누르면 다시 로드 요청 프로토콜
protocol RequestLoadList {
    func reloadWhenTapBookmark()
}

class HabitCell: UITableViewCell {
    
    @IBOutlet weak var habitListBubble: UIView!
    @IBOutlet weak var bookmarkOutlet: UIButton!
    
    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
    var delegate: BookmarkCellDelegate?
    var loadDelegate: RequestLoadList?
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        habitListBubble.layer.cornerRadius = habitListBubble.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - ReusableCell로 인한 즐겨찾기 버튼 오류 해결
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.bookmarkOutlet.setTitle("☆", for: .normal)
    }
    
    // MARK: - 버튼 눌렀을 때 델리게이트 메서드 호출 & 별 모양 바꾸기
    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
        
        if let result = self.delegate?.bookmarkButtonTappedDelegate(self, didTapButton: sender) {
            if result {
                bookmarkOutlet.setTitle("⭐", for: .normal)
            } else {
                bookmarkOutlet.setTitle("☆", for: .normal)
            }
            self.loadDelegate?.reloadWhenTapBookmark()
        }
    }
    // 전달 할 메서드...?
  
}

