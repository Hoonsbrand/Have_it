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
    
    func changeBookmarkDataWhenSwipe(listRealm: Results<Habits>?, indexPath: IndexPath) {
        if let bookmarkCheck = listRealm?[indexPath.row].isBookmarked {
            try! realm.write {
                listRealm?[indexPath.row].isBookmarked = !bookmarkCheck
            }
        }
    }
    
    func changeBookmarkDataWhenTapped(tableView: UITableView, cell: HabitCell, listRealm: Results<Habits>?) -> Bool? {
        guard let row = tableView.indexPath(for: cell)?.row else { return nil }
        
        if let bookmarkCheck = listRealm?[row].isBookmarked {
            
            // 즐겨찾기 버튼 클릭 시 Realm 데이터 업데이트
            try! realm.write {
                listRealm?[row].isBookmarked = !bookmarkCheck
            }
            
            // 처음 받아온 bookmarkCheck는 변경전의 내용이므로 반환할 때는 변화 한 후 즉, 반대의 경우를 반환
            return !bookmarkCheck
        }
        return nil
    }
    
    func loadHabitListFromRealm() -> Results<Habits> {
        let listRealm = realm.objects(Habits.self).sorted(byKeyPath: KeyText.isBookmarked, ascending: false).filter(RealmQuery.notInHOF).filter(RealmQuery.notPausedHabit)
        
        return listRealm
    }
    
    func addHabit(newHabit: Habits, timeManager: TimeManager) {
        guard let creatTime = newHabit.createTime else { return }
        // dDay계산
        newHabit.dDay = timeManager.getDday(creatTime)
        try! realm.write {
            realm.add(newHabit)
        }
    }
    
    func getCountFromListHome() -> Int {
        let listCount = realm.objects(Habits.self).filter(RealmQuery.notInHOF).filter(RealmQuery.notPausedHabit).count
        
        return listCount
    }
}
