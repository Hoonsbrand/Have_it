//
//  ViewController.swift
//  Habits
//
//  Created by hoonsbrand on 7/22/22.
//

import UIKit
import RealmSwift
import Toast_Swift
import SwipeCellKit

class ConfigureVC: UIViewController, BookmarkCellDelegate {
   
    
    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
    var habitCell = HabitCell()
    var selectIndexPath = IndexPath()
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.register(UINib(nibName: Cell.nibName, bundle: nil), forCellReuseIdentifier: Cell.customTableViewCell)
        
        let image = UIImage(named: "sparkle")
        let imgView = UIImageView(image: image)
        self.myTableView.backgroundView = imgView
        let tableBackGround = self.myTableView.backgroundView
        
        tableBackGround?.translatesAutoresizingMaskIntoConstraints = false
        tableBackGround?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        tableBackGround?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        tableBackGround?.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        tableBackGround?.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        
        loadHabitList()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.myTableView.reloadData()
        loadHabitList()
    }
    
    // MARK: - SegueToAddView
    @IBAction func showAddView(_ sender: UIBarButtonItem) {
        if let numberOfList = listRealm?.count {
            if numberOfList >= 20 {
                self.view.makeToast("최대 추가 개수는 20개 입니다.", duration: 1.5, position: .center, title: nil, image: nil, completion: nil)
            } else {
                performSegue(withIdentifier: Segue.goToAddView, sender: sender)
            }
        }
    }
    
    @IBAction func showCollectionView(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segue.goToCollectionView, sender: sender)
    }
    
    
    //MARK: - prepareMethod / CheckVC에 데이터 전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.goToCheckVC {
            let checkView = segue.destination as! CheckVC
            
            guard let list = listRealm?[selectIndexPath.row] else { return }
            // 해당 셀의 id를 받아와 그 id의 title을 추출해서 넘겨줌
            guard let getObject = realm.objects(Habits.self).filter("habitID = %@", list.habitID).first?.habitID else { return }
            checkView.receiveItem(getObject)
        }
    }
}

    // MARK: - TableView DataSource, Delegate
extension ConfigureVC : UITableViewDataSource, UITableViewDelegate, RequestLoadList {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let habitList = listRealm {
            return habitList.count
        }
        return 0
    }
    
    // MARK: - 셀 추가
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: Cell.customTableViewCell, for: indexPath) as! HabitCell
        cell.bookmarkDelegate = self
        cell.loadDelegate = self
        cell.delegate = self
        
        if let list = listRealm?[indexPath.row] {
            cell.habitTitle.text = list.title

            if list.isBookmarked {
                cell.bookmarkOutlet.setTitle("⭐", for: .normal)
            }
            
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    // MARK: - 뷰 전환
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
        self.selectIndexPath = indexPath
        
        performSegue(withIdentifier: Segue.goToCheckVC, sender: nil)
    }
    
    // MARK: - 리스트 로드
    func loadHabitList() {
        listRealm = realm.objects(Habits.self).sorted(byKeyPath: "isBookmarked", ascending: false).filter("isInHOF = false")

        UIView.transition(with: myTableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.myTableView.reloadData() })
    }
    
    // MARK: - BookmarkCellDelegate Method
    func bookmarkButtonTappedDelegate(_ habitCell: HabitCell, didTapButton button: UIButton) -> Bool? {
        guard let row = myTableView.indexPath(for: habitCell)?.row else { return nil }
        
        if let bookmarkCheck = listRealm?[row].isBookmarked {
            try! realm.write {
                listRealm?[row].isBookmarked = !bookmarkCheck
            }
            return !bookmarkCheck
        }
        return nil
    }
    
    // MARK: - RequestLoadListDelegate Method
    func reloadWhenTapBookmark() {
        loadHabitList()
    }
}

extension ConfigureVC: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        switch orientation {
        case .right:
            let deleteAction = SwipeAction(style: .destructive, title: "삭제") { action, indexPath in
                
                if let itemForDeletetion = self.listRealm?[indexPath.row] {
                    
                    let deleteAlert = UIAlertController(title: "습관 삭제", message: "정말 포기하시겠습니까?", preferredStyle: .alert)
                    
                    let keepChallengeAlertAction = UIAlertAction(title: "계속 도전", style: .cancel) { _ in
                        // 계속 도전을 누르면 swipe 숨기는 기능 필요
                        UIView.transition(with: tableView,
                                          duration: 0.35,
                                          options: .transitionFlipFromTop,
                                          animations: { self.myTableView.reloadData() })
                        self.view.makeToast("👍 잘 선택 하셨어요! 끝까지 화이팅! 👍", duration: 1.5, position: .center, title: nil, image: nil, completion: nil)
                    }
                    let giveUpChallengeAlertAction = UIAlertAction(title: "포기하기", style: .destructive) { _ in
                        do {
                            try self.realm.write {
                                self.realm.delete(itemForDeletetion)
                            }
                        } catch {
                            print("Error deleting item, \(error)")
                        }

                        UIView.transition(with: tableView,
                                          duration: 0.35,
                                          options: .transitionCrossDissolve,
                                          animations: { self.myTableView.reloadData() })
                    }
                    deleteAlert.addAction(keepChallengeAlertAction)
                    deleteAlert.addAction(giveUpChallengeAlertAction)
                    
                    self.present(deleteAlert, animated: true, completion: nil)
                }
            }
            
            deleteAction.image = UIImage(named: "delete-icon")
            
            return [deleteAction]
            
        case .left:
            let bookmarkAction = SwipeAction(style: .default, title: nil) { [self] action, indexPath in
                
                if let bookmarkCheck = listRealm?[indexPath.row].isBookmarked {
                    try! realm.write {
                        listRealm?[indexPath.row].isBookmarked = !bookmarkCheck
                    }
                }
                reloadWhenTapBookmark()
            }
            
            bookmarkAction.image = UIImage(systemName: "star.fill")
            bookmarkAction.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
            
            return [bookmarkAction]
        }
    }
}
