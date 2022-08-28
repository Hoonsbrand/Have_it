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
    
    let emptyLabel = UILabel()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView Delegate
        pausedTableView.dataSource = self
        pausedTableView.delegate = self
        
        // cell 등록
        pausedTableView.register(UINib(nibName: Cell.pausedNibName, bundle: nil), forCellReuseIdentifier: Cell.pausedHabitCell)
        
        // tableView 구분선 없앰
        self.pausedTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        // 멈춘 습관 로드
        loadHabitList()
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        
        // viewWillAppear에서 로드를 해야 실시간으로 매번 업데이트가 됨
        loadHabitList()
    }
}



// MARK: - TableView DataSource, Delegate
extension PausedHabitTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let habitList = listRealm {
            self.pausedTableView.backgroundColor = UIColor(named: Color.backgroundColor)
            return habitList.count
            
        }
        return 0
    }
    
    // MARK: - 셀 추가
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pausedTableView.dequeueReusableCell(withIdentifier: Cell.pausedHabitCell, for: indexPath) as! PausedHabitTableViewCell
        
        cell.delegate = self
        
        if let list = listRealm?[indexPath.row] {
            
            // cell text = Realm 데이터 title
            cell.pausedHabitLabel.text = list.title
            
            // cell 백그라운드 색 clear
            cell.backgroundColor = .clear
        }
        
        // 선택된 cell의 색 지정
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 0.962, green: 0.962, blue: 0.831, alpha: 1)
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    // MARK: - 셀 눌렀을 때
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let itemForRestart = self.listRealm?[indexPath.row] {
            
            // 폰트 지정
            let titleFont = UIFont(name: CustomFont.hyemin_Bold, size: 16)
            let subTitleFont = UIFont(name: CustomFont.hyemin, size: 12)

            // 텍스트 지정
            let titleText = PausedHabitLabel.restartLabel
            let subTitleText = PausedHabitLabel.restartSubLabel
            
            // 특정 문자열로 지정
            let attributeTitleString = NSMutableAttributedString(string: titleText)
            let attributeSubTitleString = NSMutableAttributedString(string: subTitleText)
            
            // 위에서 지정한 특정 문자열에 폰트 지정
            attributeTitleString.addAttribute(.font, value: titleFont!, range: (titleText as NSString).range(of: "\(titleText)"))
            attributeSubTitleString.addAttribute(.font, value: subTitleFont!, range: (subTitleText as NSString).range(of: "\(subTitleText)"))
            
            // Alert title, message 지정
            let restartAlert = UIAlertController(title: titleText, message: subTitleText, preferredStyle: .alert)
            
            // 주어진 키 경로로 식별되는 속성 값을 주어진 값으로 설정
            restartAlert.setValue(attributeTitleString, forKey: KeyText.alertTitleKey)
            restartAlert.setValue(attributeSubTitleString, forKey: KeyText.alertSubTitleKey)
            
            // 다시 시작 action을 눌렀을 때
            let restartAlertAction = UIAlertAction(title: PausedHabitLabel.alertActionRestart, style: .default) { _ in
                
                // Realm 데이터 업데이트
                do {
                    try self.realm.write {
                        itemForRestart.isPausedHabit = false
                        itemForRestart.createTime = Date()
                        itemForRestart.dDay = self.timeManager.getDday(Date())
                        itemForRestart.dayCount = 0
                        itemForRestart.isBookmarked = false
                    }
                } catch {
                    print("Error restarting habit, \(error.localizedDescription)")
                }
                // 습관 리스트 리로드
                self.loadHabitList()

                UIView.transition(with: tableView,
                                  duration: 0.35,
                                  options: .transitionCrossDissolve,
                                  animations: { self.pausedTableView.reloadData() })
                self.showToast(message: ToastMessage.goodChoiceToast, font:  UIFont(name: CustomFont.hyemin_Bold, size: 14)!, ToastWidth: 240, ToasatHeight: 40)
            }
            
            // 취소 action을 눌렀을 때
            let cancelAlertAction = UIAlertAction(title: PausedHabitLabel.alertActionCancel, style: .default) { _ in
                // 습관 리스트 리로드
                self.loadHabitList()
            }
            
            // 다시 시작 action 색 지정
            restartAlertAction.setValue(UIColor(red: 0.078, green: 0.804, blue: 0.541, alpha: 1), forKey: KeyText.titleTextColor)
            
            // 취소 action 색 지정
            cancelAlertAction.setValue(UIColor(red: 0.697, green: 0.725, blue: 0.762, alpha: 1), forKey: KeyText.titleTextColor)
            
            // Alert에 action 추가
            restartAlert.addAction(cancelAlertAction)
            restartAlert.addAction(restartAlertAction)


            self.present(restartAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - 리스트 로드
    func loadHabitList() {
        // 멈춘 습관이 true인 데이터만 불러옴
        listRealm = realm.objects(Habits.self).filter(RealmQuery.pausedHabit)
        
        // tableView 리로드 애니메이션
        UIView.transition(with: pausedTableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.pausedTableView.reloadData() })
        
        loadEmptyLabel()
    }
}

// MARK: - SwipeTableViewCellDelegate
extension PausedHabitTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        // 오른쪽 스와이프만 허용
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            
            // 폰트 지정
            let titleFont = UIFont(name: CustomFont.hyemin, size: 16)
            
            // 텍스트 지정
            let titleText = PausedHabitLabel.wantToDelete
            
            // 특정 문자열로 지정
            let attributeTitleString = NSMutableAttributedString(string: titleText)
            
            // 위에서 지정한 특정 문자열에 폰트 지정
            attributeTitleString.addAttribute(.font, value: titleFont!, range: (titleText as NSString).range(of: "\(titleText)"))
            
            if let itemForDeletion = self.listRealm?[indexPath.row] {
                let deleteAlert = UIAlertController(title: titleText, message: nil, preferredStyle: .alert)
                
                // 주어진 키 경로로 식별되는 속성 값을 주어진 값으로 설정
                deleteAlert.setValue(attributeTitleString, forKey: KeyText.alertTitleKey)
                
                // 취소 action을 눌렀을 때
                let cancelAlertAction = UIAlertAction(title: PausedHabitLabel.alertActionCancel, style: .default) { _ in
                    
                    // tableView 리로드
                    UIView.transition(with: tableView,
                                      duration: 0.35,
                                      options: .transitionCrossDissolve,
                                      animations: { tableView.reloadData() })
                }
                
                // 삭제 action을 눌렀을 때
                let deleteHabitAlertAction = UIAlertAction(title: PausedHabitLabel.alertActionDelete, style: .default) { _ in
                    
                    // Realm 데이터에서 삭제
                    do {
                        try self.realm.write {
                            self.realm.delete(itemForDeletion)
                        }
                    } catch {
                        print("Error deleting item, \(error)")
                    }
                    
                    // tableView 리로드
                    self.loadHabitList()
                    
                    // 토스트 띄우기
                    self.showToast(message: ToastMessage.habitDeleteCompleteToast, font: UIFont.systemFont(ofSize: 12), ToastWidth: 180, ToasatHeight: 32, yPos: 1.2, backgroundColor: .black, textColor: .white)
                }
                
                // 취소 action 색 지정
                cancelAlertAction.setValue(UIColor.black, forKey: KeyText.titleTextColor)
                
                // 삭제 action 색 지정
                deleteHabitAlertAction.setValue(UIColor.red, forKey: KeyText.titleTextColor)
                
                // Alert에 action 추가
                deleteAlert.addAction(cancelAlertAction)
                deleteAlert.addAction(deleteHabitAlertAction)
                
                self.present(deleteAlert, animated: true, completion: nil)
            }
        }
        
        // 삭제 이미지 & 백그라운드 지정
        deleteAction.image = UIImage(named: ImageName.deleteButton)
        deleteAction.backgroundColor = UIColor(named: Color.backgroundColor)
        
        return [deleteAction]
    }
}

extension PausedHabitTableViewController {
    
    // 토스트 method
    func showToast(message : String, font: UIFont, ToastWidth: CGFloat, ToasatHeight: CGFloat, yPos: CGFloat = 2, backgroundColor: UIColor = UIColor(red: 0.993, green: 1, blue: 0.646, alpha: 1), textColor: UIColor = .black) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - (ToastWidth/2), y: self.view.frame.size.height/yPos, width: ToastWidth, height: ToasatHeight))
        toastLabel.backgroundColor = backgroundColor
        toastLabel.textColor = textColor
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
    
    // MARK: - 리스트에 아무것도 없을 시 레이블 띄우기
    func loadEmptyLabel() {
        let listCount = realm.objects(Habits.self).filter(RealmQuery.notInHOF).filter(RealmQuery
            .pausedHabit).count
        
        if listCount == 0 {
            
            // 레이블 세부사항 지정
            emptyLabel.text = PausedHabitLabel.nonePausedHabit
            emptyLabel.font = UIFont(name: CustomFont.hyemin, size: 16)
            emptyLabel.textColor = UIColor(red: 0.678, green: 0.698, blue: 0.725, alpha: 1)
            emptyLabel.numberOfLines = 0
            emptyLabel.textAlignment = .center
            
            // 레이블 오토레이아웃
            let parent = self.view!
            parent.addSubview(emptyLabel)
            
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyLabel.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
            emptyLabel.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        } else {
            // 리스트에 데이터가 있다면 레이블을 지움
            emptyLabel.removeFromSuperview()
        }
    }
}
