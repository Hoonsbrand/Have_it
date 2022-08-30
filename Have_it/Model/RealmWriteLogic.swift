//
//  RealmWriteLogic.swift
//  Have it
//
//  Created by hoonsbrand on 2022/08/30.
//

import Foundation

struct RealmWriteLogic {
    
    func restartHabit(itemForRestart: Habits, timeManager: TimeManager) {
        itemForRestart.isPausedHabit = false
        itemForRestart.createTime = Date()
        itemForRestart.dDay = timeManager.getDday(Date())
        itemForRestart.dayCount = 0
        itemForRestart.isBookmarked = false
    }
}
