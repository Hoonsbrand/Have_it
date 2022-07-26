//
//  Model.swift
//  Habits
//
//  Created by 안지훈 on 7/22/22.
//

import Foundation
import RealmSwift

class Habits: Object {
    @Persisted var title: String = ""                  // 습관 이름
    @Persisted var isBookmarked: Bool = false          // 습관 즐겨찾기 여부
    @Persisted var isCompleted: Bool = false           // 오늘 습관을 완료 했는지
    @Persisted var dayCount: Int = 0                   // 완료 한 날 카운트 -> 66일이 됐는지 나중에 알아야하니까
    @Persisted var createTime: Date?                   // 생성 시간 저장 -> 24시간 계산하기 위함
    
    convenience init(title: String, createTime: Date) {
        self.init()
        self.title = title
        self.createTime = createTime
    }
}
