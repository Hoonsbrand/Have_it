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

class ConfigureVC: UIViewController {
   
    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
    var habitCell = HabitCell()
    var selectIndexPath = IndexPath()
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var addHabitOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.register(UINib(nibName: Cell.nibName, bundle: nil), forCellReuseIdentifier: Cell.customTableViewCell)
        self.view.backgroundColor = UIColor(named: "ViewBackground")
        
        loadHabitList()
        
        // 테이블 뷰 구분선 없애기
        self.myTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadHabitList()
    }
    
    // MARK: - SegueToAddView
    @IBAction func showAddView(_ sender: UIButton) {
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
            self.myTableView.backgroundColor = UIColor(named: "ViewBackground")
            return habitList.count
        }
        return 0
    }
    
    // MARK: - 셀 추가
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: Cell.customTableViewCell, for: indexPath) as! HabitCell
        
        cell.loadDelegate = self
        cell.delegate = self
        cell.bookmarkDelegate = self

        if let list = listRealm?[indexPath.row] {
            cell.habitTitle.text = list.title
            
            if list.isBookmarked {
                cell.bookmarkBtnOutlet.isEnabled = true
                cell.bookmarkBtnOutlet.setBackgroundImage(UIImage(named: "bookmarkImage"), for: .normal)
            }
            
            cell.backgroundColor = UIColor(named: "ViewBackground")
        }
        return cell
    }
    
    // MARK: - 뷰 전환
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
        self.selectIndexPath = indexPath
        
        performSegue(withIdentifier: Segue.goToCheckVC, sender: nil)
    }
    
    
// MARK: - 스크롤을 감지해서 맨 밑에 있을 때 버튼을 숨김
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollMethod(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollMethod(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollMethod(scrollView)
    }
    
    func scrollMethod(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset
        
        if distanceFromBottom <= height {
            addHabitOutlet.isEnabled = false
            addHabitOutlet.isHidden = true
        } else {
            addHabitOutlet.isEnabled = true
            addHabitOutlet.isHidden = false
        }
        
        if scrollView.contentOffset.y <= 0 {
            addHabitOutlet.isEnabled = true
            addHabitOutlet.isHidden = false
        }
    }
    
    // MARK: - 리스트 로드
    func loadHabitList() {
        listRealm = realm.objects(Habits.self).sorted(byKeyPath: "isBookmarked", ascending: false).filter("isInHOF = false").filter("isPausedHabit = false")
        addHabitOutlet.isEnabled = true
        addHabitOutlet.isHidden = false
        UIView.transition(with: myTableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.myTableView.reloadData() })
//        myTableView.alwaysBounceVertical = false // 스크롤 뷰 block
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
            let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
                
                if let itemForPause = self.listRealm?[indexPath.row] {
                    
                    let deleteAlert = UIAlertController(title: "✋\n습관을 잠깐 멈추시겠어요?", message: "\n멈춘 습관은 '잠시 멈춤'에 보관되며\n언제든지 다시 시작하실 수 있습니다.\n다만, 다시 시작하실 때는 1일차로 돌아갑니다.😢", preferredStyle: .alert)
                    
                    let keepChallengeAlertAction = UIAlertAction(title: "계속 도전", style: .cancel) { _ in
                        // 계속 도전을 누르면 swipe 숨기는 기능 필요
                        UIView.transition(with: tableView,
                                          duration: 0.35,
                                          options: .transitionFlipFromTop,
                                          animations: { self.myTableView.reloadData() })
                        self.view.makeToast("👍 잘 선택 하셨어요! 끝까지 화이팅! 👍", duration: 1.5, position: .center, title: nil, image: nil, completion: nil)
                    }
                    let pauseChallengeAlertAction = UIAlertAction(title: "멈추기", style: .destructive) { _ in
                        do {
                            try self.realm.write {
                                itemForPause.isPausedHabit = true
                            }
                        } catch {
                            print("Error pause item, \(error)")
                        }
                        
                        self.loadHabitList()
                    }
                    deleteAlert.addAction(keepChallengeAlertAction)
                    deleteAlert.addAction(pauseChallengeAlertAction)
                    
                    self.present(deleteAlert, animated: true, completion: nil)
                }
            }
            
            deleteAction.image = UIImage(named: "pauseImage")
            deleteAction.backgroundColor = UIColor(named: "ViewBackground")
            
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
            
            bookmarkAction.image = UIImage(named: "swipeBookmark")
            bookmarkAction.backgroundColor = UIColor(named: "ViewBackground")
            

            return [bookmarkAction]
        }
    }
}

// MARK: - BookmarkCellDelegate Method
extension ConfigureVC: BookmarkCellDelegate {    
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
}
