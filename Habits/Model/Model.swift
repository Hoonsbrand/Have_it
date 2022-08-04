//
//  Model.swift
//  Habits
//
//  Created by hoonsbrand on 7/22/22.
//

import Foundation
import RealmSwift
import SwiftUI

class Habits: Object {
    @Persisted var habitID = UUID().uuidString            // Primary Key
    @Persisted var title: String = ""                     // 습관 이름
    @Persisted var isBookmarked: Bool = false             // 습관 즐겨찾기 여부
    @Persisted var isCompleted: Bool = false              // 오늘 습관을 완료 했는지
    @Persisted var dayCount: Int = 0                      // 완료 한 날 카운트 -> 66일이 됐는지 나중에 알아야하니까
    @Persisted var createTime: Date?                      // 생성 시간 저장 -> 24시간 계산하기 위함
    @Persisted var isInHOF: Bool = false                  // 해당 습관이 명예의 전당에 있는지
    
    convenience init(title: String, createTime: Date) {
        self.init()
        self.title = title
        self.createTime = createTime
    }
    
    override static func primaryKey() -> String? {
        return "habitID"
    }
}
