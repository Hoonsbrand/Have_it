//
//  PausedHabitTableViewController.swift
//  Habits
//
//  Created by hoonsbrand on 2022/08/11.
//

import UIKit
import RealmSwift
import SwipeCellKit

class PausedHabitTableViewController: UIViewController {

    @IBOutlet weak var pausedTableView: UITableView!
    
    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
    let timeManager = TimeManager()
    
    var habitCell = HabitCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pausedTableView.dataSource = self
        pausedTableView.delegate = self
        pausedTableView.register(UINib(nibName: Cell.nibName, bundle: nil), forCellReuseIdentifier: Cell.customTableViewCell)
        
        loadHabitList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadHabitList()
    }
}



// MARK: - TableView DataSource, Delegate
extension PausedHabitTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let habitList = listRealm {
            return habitList.count
        }
        return 0
    }
    
    // MARK: - 셀 추가
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pausedTableView.dequeueReusableCell(withIdentifier: Cell.customTableViewCell, for: indexPath) as! HabitCell
        
        cell.delegate = self
        
        if let list = listRealm?[indexPath.row] {
            cell.habitTitle.text = list.title
            
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    // MARK: - 리스트 로드
    func loadHabitList() {
        listRealm = realm.objects(Habits.self).filter("isPausedHabit = true")
        
        UIView.transition(with: pausedTableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.pausedTableView.reloadData() })
    }
}

extension PausedHabitTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let restartAction = SwipeAction(style: .default, title: "다시 시작!") { action, indexPath in
            
            if let itemForRestart = self.listRealm?[indexPath.row] {
                let restartAlert = UIAlertController(title: "습관을 다시 시작하시겠어요?", message: "1일차부터 다시 시작합니다!", preferredStyle: .alert)
                
                let yesAlertAction = UIAlertAction(title: "네, 다시할래요!", style: .destructive) { _ in
                    do {
                        try self.realm.write {
                            itemForRestart.isPausedHabit = false
                            itemForRestart.createTime = Date()
                            itemForRestart.dDay = self.timeManager.getDday(Date())
                            itemForRestart.dayCount = 0
                            
                            
                        }
                    } catch {
                        print("Error restarting habit, \(error.localizedDescription)")
                    }
                    self.loadHabitList()
                }
                let noAlertAction = UIAlertAction(title: "아니요, 좀 더 쉴래요.", style: .cancel) { _ in
                   
                    UIView.transition(with: tableView,
                                      duration: 0.35,
                                      options: .transitionFlipFromTop,
                                      animations: { self.pausedTableView.reloadData() })
                    self.view.makeToast("👍 조금만 쉬고 다시 해봐요! 👍", duration: 1.5, position: .center, title: nil, image: nil, completion: nil)
                }
                
                restartAlert.addAction(yesAlertAction)
                restartAlert.addAction(noAlertAction)
                
                self.present(restartAlert, animated: true, completion: nil)
            }
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "삭제") { action, indexPath in
            
            if let itemForDeletion = self.listRealm?[indexPath.row] {
                let deleteAlert = UIAlertController(title: "🚨\n습관을 정말 삭제하시겠어요?", message: "\n삭제한 습관은 다시 복구가 불가능합니다. 😢", preferredStyle: .alert)
                
                let keepInPauseAlertAction = UIAlertAction(title: "아니요, 그냥 냅둘래요.", style: .cancel) { _ in
                    
                    UIView.transition(with: tableView,
                                      duration: 0.35,
                                      options: .transitionFlipFromTop,
                                      animations: { self.pausedTableView.reloadData() })
                }
                let deleteHabitAlertAction = UIAlertAction(title: "네, 삭제할래요.", style: .destructive) { _ in
                    do {
                        try self.realm.write {
                            self.realm.delete(itemForDeletion)
                        }
                    } catch {
                        print("Error deleting item, \(error)")
                    }
                    
                    UIView.transition(with: tableView,
                                      duration: 0.35,
                                      options: .transitionCrossDissolve,
                                      animations: { self.pausedTableView.reloadData() })
                }
                deleteAlert.addAction(keepInPauseAlertAction)
                deleteAlert.addAction(deleteHabitAlertAction)
                
                self.present(deleteAlert, animated: true, completion: nil)
            }
        }
        
        restartAction.image = UIImage(systemName: "gobackward")
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction, restartAction]
    }
    
    
}
