//
//  HabitCell.swift
//  Habits
//
//  Created by hoonsbrand on 2022/07/26.
//

import UIKit
import RealmSwift
import SwipeCellKit

// MARK: - 즐겨찾기 버튼 누르면 다시 로드 요청 프로토콜
protocol RequestLoadList {
    func reloadWhenTapBookmark()
}

class HabitCell: SwipeTableViewCell {
    
    @IBOutlet weak var bookmarkImage: UIImageView!
    @IBOutlet weak var habitTitle: UILabel!
    
    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
    var loadDelegate: RequestLoadList?
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(named: "ViewBackground")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    // MARK: - ReusableCell로 인한 즐겨찾기 버튼 오류 해결
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookmarkImage.image = .none
    }
}
