//
//  RealmWriteLogic.swift
//  Have it
//
//  Created by hoonsbrand on 2022/08/30.
//

import Foundation
import RealmSwift

struct RealmLogic {
    
    private let realm = try! Realm()
    
    func changeRealmDataWhenPause(itemForPause: Habits) {
        do {
            try self.realm.write {
                itemForPause.isPausedHabit = true
            }
        } catch {
            print("Error pause item, \(error)")
        }
    }
    
    func restartHabit(itemForRestart: Habits, timeManager: TimeManager) {
        itemForRestart.isPausedHabit = false
        itemForRestart.createTime = Date()
        itemForRestart.dDay = timeManager.getDday(Date())
        itemForRestart.dayCount = 0
        itemForRestart.isBookmarked = false
    }
    
    func changeRealmDataWhenBookmark(listRealm: Results<Habits>?, indexPath: IndexPath) {
        if let bookmarkCheck = listRealm?[indexPath.row].isBookmarked {
            try! realm.write {
                listRealm?[indexPath.row].isBookmarked = !bookmarkCheck
            }
        }
    }
    
    func loadHabitListFromRealm() -> Results<Habits> {
        let listRealm = realm.objects(Habits.self).sorted(byKeyPath: KeyText.isBookmarked, ascending: false).filter(RealmQuery.notInHOF).filter(RealmQuery.notPausedHabit)
        
        return listRealm
    }
    
    func getCountFromListHome() -> Int {
        let listCount = realm.objects(Habits.self).filter(RealmQuery.notInHOF).filter(RealmQuery.notPausedHabit).count
        
        return listCount
    }
}
