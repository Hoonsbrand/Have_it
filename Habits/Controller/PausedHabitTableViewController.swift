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
        
        pausedTableView.register(UINib(nibName: Cell.pausedNibName, bundle: nil), forCellReuseIdentifier: Cell.pausedHabitCell)
        
        self.pausedTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
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
            self.pausedTableView.backgroundColor = UIColor(named: "ViewBackground")
            return habitList.count
            
        }
        return 0
    }
    
    // MARK: - 셀 추가
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pausedTableView.dequeueReusableCell(withIdentifier: Cell.pausedHabitCell, for: indexPath) as! PausedHabitTableViewCell
        
        if let list = listRealm?[indexPath.row] {
            cell.pausedHabitLabel.text = list.title
            
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    // MARK: - 셀 눌렀을 때
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let itemForRestart = self.listRealm?[indexPath.row] {
            
            let titleFont = UIFont(name: "IMHyemin-Bold", size: 16)
            let subTitleFont = UIFont(name: "IM_Hyemin", size: 12)
            
            let titleText = "🏃\n습관을 다시 시작할까요?"
            let subTitleText = "1일차부터 차근차근 힘내봐요!"
            
            let attributeTitleString = NSMutableAttributedString(string: titleText)
            let attributeSubTitleString = NSMutableAttributedString(string: subTitleText)
            
            let restartAlert = UIAlertController(title: titleText, message: subTitleText, preferredStyle: .alert)
            attributeTitleString.addAttribute(.font, value: titleFont!, range: (titleText as NSString).range(of: "\(titleText)"))
            attributeSubTitleString.addAttribute(.font, value: subTitleFont!, range: (subTitleText as NSString).range(of: "\(subTitleText)"))
            restartAlert.setValue(attributeTitleString, forKey: "attributedTitle")
            restartAlert.setValue(attributeSubTitleString, forKey: "attributedMessage")
            
            let restartAlertAction = UIAlertAction(title: "다시 시작", style: .default) { _ in
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
                
                UIView.transition(with: tableView,
                                  duration: 0.35,
                                  options: .transitionCrossDissolve,
                                  animations: { self.pausedTableView.reloadData() })
                self.showToast(message: "잘 선택 하셨어요! 끝까지 화이팅! 👍", font:  UIFont(name: "IMHyemin-Bold", size: 14)!, ToastWidth: 240, ToasatHeight: 40)
            }
            let cancelAlertAction = UIAlertAction(title: "취소", style: .default) { _ in
                self.loadHabitList()
            }
            
            restartAlertAction.setValue(UIColor(red: 0.078, green: 0.804, blue: 0.541, alpha: 1), forKey: "titleTextColor")
            cancelAlertAction.setValue(UIColor(red: 0.697, green: 0.725, blue: 0.762, alpha: 1), forKey: "titleTextColor")
            
            restartAlert.addAction(cancelAlertAction)
            restartAlert.addAction(restartAlertAction)

            
            self.present(restartAlert, animated: true, completion: nil)
        }
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
        
        let deleteAction = SwipeAction(style: .destructive, title: "삭제") { action, indexPath in
            
            let titleFont = UIFont(name: "IM_Hyemin", size: 16)
            
            let titleText = "습관을 삭제할까요?"
            
            let attributeTitleString = NSMutableAttributedString(string: titleText)
            
            let restartAlert = UIAlertController(title: titleText, message: nil, preferredStyle: .alert)
            attributeTitleString.addAttribute(.font, value: titleFont!, range: (titleText as NSString).range(of: "\(titleText)"))
            restartAlert.setValue(attributeTitleString, forKey: "attributedTitle")
            
            if let itemForDeletion = self.listRealm?[indexPath.row] {
                let deleteAlert = UIAlertController(title: titleText, message: nil, preferredStyle: .alert)
                
                let cancelAlertAction = UIAlertAction(title: "취소", style: .default) { _ in
                    
                    UIView.transition(with: tableView,
                                      duration: 0.35,
                                      options: .transitionFlipFromTop,
                                      animations: { self.pausedTableView.reloadData() })
                }
                let deleteHabitAlertAction = UIAlertAction(title: "삭제", style: .default) { _ in
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
                    
                    self.showToast(message: "습관이 삭제되었습니다.", font: UIFont.systemFont(ofSize: 12), ToastWidth: 180, ToasatHeight: 32)
                }
                deleteAlert.addAction(cancelAlertAction)
                deleteAlert.addAction(deleteHabitAlertAction)
                
                self.present(deleteAlert, animated: true, completion: nil)
            }
        }
        
        deleteAction.image = UIImage(named: "deleteButton")
        deleteAction.backgroundColor = UIColor(named: "ViewBackground")
        
        return [deleteAction]
    }
}

extension PausedHabitTableViewController {
    func showToast(message : String, font: UIFont, ToastWidth: CGFloat, ToasatHeight: CGFloat) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - (ToastWidth/2), y: self.view.frame.size.height/2, width: ToastWidth, height: ToasatHeight))
        toastLabel.backgroundColor = UIColor(red: 0.993, green: 1, blue: 0.646, alpha: 1)
        toastLabel.textColor = UIColor.black
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.5 , delay: 1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
