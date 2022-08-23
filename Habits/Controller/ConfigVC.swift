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
import Lottie

class ConfigureVC: UIViewController {
   
    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
    var habitCell = HabitCell()
    var selectIndexPath = IndexPath()
    
    let emptyLabel = UILabel()
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var addHabitOutlet: UIButton!
    @IBOutlet weak var LottieDonguri: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.register(UINib(nibName: Cell.nibName, bundle: nil), forCellReuseIdentifier: Cell.customTableViewCell)
        self.view.backgroundColor = UIColor(named: "ViewBackground")
        
        loadHabitList()
        
        // 테이블 뷰 구분선 없애기
        self.myTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        addHabitOutlet.layer.cornerRadius = 16
        addHabitOutlet.layer.shadowColor = UIColor(red: 0.16, green: 0.21, blue: 0.14, alpha: 0.3).cgColor
        addHabitOutlet.layer.shadowOffset = CGSize(width: 0, height: 2)
        addHabitOutlet.layer.shadowOpacity = 1.0
        addHabitOutlet.layer.shadowRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadHabitList()
        dongruri()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 노치가 없으면 탭바의 크기를 바꿈
        if !UIDevice.current.hasNotch {
            print("don't have a notch")
            tabBarController?.tabBar.frame.size.height = 60
            tabBarController?.tabBar.frame.origin.y = view.frame.height - 60
            tabBarController?.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
//            UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        }
    }
    
    // MARK: - 리스트에 아무것도 없을 시 레이블 띄우기
    func loadEmptyLabel() {
        let listCount = realm.objects(Habits.self).filter("isInHOF = false").filter("isPausedHabit = false").count
        
        if listCount == 0 {
            emptyLabel.text = "하고 있는 습관이 아직 없어요 🥲\n습관을 만들어볼까요?"
            emptyLabel.font = UIFont(name: "IM_Hyemin", size: 16)
            emptyLabel.textColor = UIColor(red: 0.678, green: 0.698, blue: 0.725, alpha: 1)
            
            emptyLabel.numberOfLines = 0
            emptyLabel.textAlignment = .center
            
            let parent = self.view!
            
            parent.addSubview(emptyLabel)
            
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyLabel.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
            emptyLabel.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        } else {
            emptyLabel.removeFromSuperview()
        }
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
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        scrollMethod(scrollView)
//    }
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        scrollMethod(scrollView)
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        scrollMethod(scrollView)
//    }
//
//    func scrollMethod(_ scrollView: UIScrollView) {
//        let height = scrollView.frame.size.height
//        let contentYOffset = scrollView.contentOffset.y
//        let distanceFromBottom = scrollView.contentSize.height - contentYOffset
//
//        if distanceFromBottom <= height {
//            addHabitOutlet.isEnabled = false
//            addHabitOutlet.isHidden = true
//        } else {
//            addHabitOutlet.isEnabled = true
//            addHabitOutlet.isHidden = false
//        }
//
//        if scrollView.contentOffset.y <= 0 {
//            addHabitOutlet.isEnabled = true
//            addHabitOutlet.isHidden = false
//        }
//    }
    
    // MARK: - 리스트 로드
    func loadHabitList() {
        listRealm = realm.objects(Habits.self).sorted(byKeyPath: "isBookmarked", ascending: false).filter("isInHOF = false").filter("isPausedHabit = false")
        addHabitOutlet.isEnabled = true
        addHabitOutlet.isHidden = false
        UIView.transition(with: myTableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.myTableView.reloadData() })
        loadEmptyLabel()
    }
    
    // MARK: - RequestLoadListDelegate Method
    func reloadWhenTapBookmark() {
        loadHabitList()
    }
}

extension ConfigureVC: SwipeTableViewCellDelegate {
    
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        switch orientation {
        case .right:
            let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
                
                if let itemForPause = self.listRealm?[indexPath.row] {
                    
                    let titleFont = UIFont(name: "IMHyemin-Bold", size: 16) 
                    let subTitleFont = UIFont(name: "IM_Hyemin", size: 12)
                    
                    let titleText = "✋습관을 잠깐 멈추시겠어요?"
                    let subTitleText = "\n멈춘 습관은 '잠시 멈춤'에 보관되며\n언제든지 다시 시작하실 수 있습니다.\n다만, 다시 시작하실 때는 1일차로 돌아갑니다.😢"
                    
                    let attributeTitleString = NSMutableAttributedString(string: titleText)
                    let attributeSubTitleString = NSMutableAttributedString(string: subTitleText)
                    
                    let deleteAlert = UIAlertController(title: titleText, message: subTitleText, preferredStyle: .alert)
                    attributeTitleString.addAttribute(.font, value: titleFont!, range: (titleText as NSString).range(of: "\(titleText)"))
                    attributeSubTitleString.addAttribute(.font, value: subTitleFont!, range: (subTitleText as NSString).range(of: "\(subTitleText)"))
                    deleteAlert.setValue(attributeTitleString, forKey: "attributedTitle")
                    deleteAlert.setValue(attributeSubTitleString, forKey: "attributedMessage")
                    
                    let keepChallengeAlertAction = UIAlertAction(title: "계속 도전", style: .default) { _ in
                        
                        // 계속 도전을 누르면 swipe 숨기는 기능 필요
                        UIView.transition(with: tableView,
                                          duration: 0.35,
                                          options: .transitionCrossDissolve,
                                          animations: { tableView.reloadData() })
                        self.showToast(message: "잘 선택 하셨어요! 끝까지 화이팅! 👍", font:  UIFont(name: "IMHyemin-Bold", size: 14)!, ToastWidth: 240, ToasatHeight: 40)
                    }
                    let pauseChallengeAlertAction = UIAlertAction(title: "멈추기", style: .default) { _ in
                        do {
                            try self.realm.write {
                                itemForPause.isPausedHabit = true
                            }
                        } catch {
                            print("Error pause item, \(error)")
                        }
                        
                        self.loadHabitList()
                        
                        self.showToast(message: "다시 시작하실 그 날을 기약하며 \n습관이 ‘잠시 멈춤’에 보관되었습니다. 👋", font: UIFont(name: "IM_Hyemin", size: 14)!, ToastWidth: 266, ToasatHeight: 64)
                    }
                    
                    keepChallengeAlertAction.setValue(UIColor(red: 0.078, green: 0.804, blue: 0.541, alpha: 1), forKey: "titleTextColor")
                    pauseChallengeAlertAction.setValue(UIColor(red: 0.697, green: 0.725, blue: 0.762, alpha: 1), forKey: "titleTextColor")
                    
                    deleteAlert.addAction(pauseChallengeAlertAction)
                    deleteAlert.addAction(keepChallengeAlertAction)

                    
                    self.present(deleteAlert, animated: true, completion: nil)
                }
            }
            
            deleteAction.image = UIImage(named: "ic-pause")
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

extension ConfigureVC {
    
    fileprivate func dongruri(){
        
        let customAnimationView = AnimationView(name: "Launch")
        
        //Do your configurations
        customAnimationView.contentMode = .scaleAspectFit
        customAnimationView.loopMode = .loop
        customAnimationView.backgroundBehavior = .pauseAndRestore
        //And play
        customAnimationView.play()
        customAnimationView.translatesAutoresizingMaskIntoConstraints = false
        self.LottieDonguri.addSubview(customAnimationView)
        
        
        NSLayoutConstraint.activate([
            customAnimationView.trailingAnchor.constraint(equalTo: LottieDonguri.trailingAnchor),
            customAnimationView.bottomAnchor.constraint(equalTo: LottieDonguri.bottomAnchor),
            customAnimationView.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            customAnimationView.heightAnchor.constraint(lessThanOrEqualToConstant: 100)
            
        ])
        
    }
    
}

// 노치가 있는지 없는지
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
