//
//  HabitCell.swift
//  Habits
//
//  Created by hoonsbrand on 2022/07/26.
//

import UIKit
import RealmSwift
import SwipeCellKit

// MARK: - 즐겨찾기 버튼 누를 때 Realm 데이터에 넣기위한 프로토콜
protocol BookmarkCellDelegate {
    func bookmarkButtonTappedDelegate(_ habitCell: HabitCell, didTapButton button: UIButton) -> Bool?
}

// MARK: - 즐겨찾기 버튼 누르면 다시 로드 요청 프로토콜
protocol RequestLoadList {
    func reloadWhenTapBookmark()
}

class HabitCell: SwipeTableViewCell {
    
    @IBOutlet weak var habitTitle: UILabel!
    @IBOutlet weak var bookmarkBtnOutlet: UIButton!
    
    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
    var bookmarkDelegate: BookmarkCellDelegate?
    var loadDelegate: RequestLoadList?
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bookmarkBtnOutlet.isEnabled = false
        self.backgroundColor = UIColor(named: "ViewBackground")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func bookmarkBtnPressed(_ sender: UIButton) {
        if let _ = self.bookmarkDelegate?.bookmarkButtonTappedDelegate(self, didTapButton: sender) {
            self.bookmarkBtnOutlet.isEnabled = false
            self.bookmarkBtnOutlet.setBackgroundImage(nil, for: .normal)
            self.loadDelegate?.reloadWhenTapBookmark()
        }
    }
    
    // MARK: - ReusableCell로 인한 즐겨찾기 버튼 오류 해결
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookmarkBtnOutlet.isEnabled = false
        self.bookmarkBtnOutlet.setBackgroundImage(nil, for: .normal)
    }
}
