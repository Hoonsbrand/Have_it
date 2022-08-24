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
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView Delegate
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.register(UINib(nibName: Cell.nibName, bundle: nil), forCellReuseIdentifier: Cell.customTableViewCell)
        
        // 화면 배경색 지정
        self.view.backgroundColor = UIColor(named: "ViewBackground")
        
        // 습관 추가 버튼 Radius & Shadow
        addHabitOutlet.layer.cornerRadius = 16
        addHabitOutlet.layer.shadowColor = UIColor(red: 0.16, green: 0.21, blue: 0.14, alpha: 0.3).cgColor
        addHabitOutlet.layer.shadowOffset = CGSize(width: 0, height: 2)
        addHabitOutlet.layer.shadowOpacity = 1.0
        addHabitOutlet.layer.shadowRadius = 10
        
        // 리스트 로드
        loadHabitList()
        
        // 테이블 뷰 구분선 없애기
        self.myTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
    }
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // 뷰가 나타날 때 메인화면에서는 네비게이션 바 숨김
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadHabitList()
        dongruri()
    }
    
    // MARK: - viewDidLayoutSubviews: view가 subview의 배치를 다했다는 소식을 viewController에게 알림
    // view가 subview들의 배치를 조정한 직후에 하고 싶은 작업이 있다면 override를 하면 됨
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 노치가 없으면 탭바의 크기를 바꿈
        if !UIDevice.current.hasNotch {
            tabBarController?.tabBar.frame.size.height = 60
            tabBarController?.tabBar.frame.origin.y = view.frame.height - 60
            tabBarController?.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        }
    }
    
    // MARK: - 리스트에 아무것도 없을 시 레이블 띄우기
    func loadEmptyLabel() {
        let listCount = realm.objects(Habits.self).filter("isInHOF = false").filter("isPausedHabit = false").count
        
        if listCount == 0 {
            
            // 레이블 세부사항 지정
            emptyLabel.text = "하고 있는 습관이 아직 없어요 🥲\n습관을 만들어볼까요?"
            emptyLabel.font = UIFont(name: "IM_Hyemin", size: 16)
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
    
    
    // MARK: - SegueToAddView
    @IBAction func showAddView(_ sender: UIButton) {
        if let numberOfList = listRealm?.count {
            
            // 습관 최대 추가 개수 20개 제한
            if numberOfList >= 20 {
                self.view.makeToast("최대 추가 개수는 20개 입니다.", duration: 1.5, position: .center, title: nil, image: nil, completion: nil)
            } else {
                // 20개 미만이라면 추가 가능
                performSegue(withIdentifier: Segue.goToAddView, sender: sender)
            }
        }
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
            
            // cell 타이틀 = Realm 데이터의 title
            cell.habitTitle.text = list.title
            
            // 즐겨찾기가 되어있다면 cell에 표시
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
    
    // MARK: - 리스트 로드
    func loadHabitList() {
        
        // 즐겨찾기를 기준으로 정렬 & 습관의 전당에 있다면 표시x & 멈춰있는 습관이라면 표시x
        listRealm = realm.objects(Habits.self).sorted(byKeyPath: "isBookmarked", ascending: false).filter("isInHOF = false").filter("isPausedHabit = false")
        
        // 테이블 뷰 새로고침 애니메이션
        UIView.transition(with: myTableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.myTableView.reloadData() })
        
        // 데이터의 유무에 따른 레이블 호출
        loadEmptyLabel()
    }
    
    // MARK: - RequestLoadListDelegate Method
    func reloadWhenTapBookmark() {
        // 즐겨찾기를 누를 때 마다 리스트 새로고침
        loadHabitList()
    }
}

extension ConfigureVC: SwipeTableViewCellDelegate {
    
    // MARK: - 토스트 method
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
    
    // MARK: - Cell Swipe 구성
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        switch orientation {
            
        // 오른쪽 스와이프 시
        case .right:
            let pauseAction = SwipeAction(style: .default, title: nil) { action, indexPath in
                
                if let itemForPause = self.listRealm?[indexPath.row] {
                    
                    // 폰트 지정
                    let titleFont = UIFont(name: "IMHyemin-Bold", size: 16) 
                    let subTitleFont = UIFont(name: "IM_Hyemin", size: 12)
                    
                    // 텍스트 지정
                    let titleText = "✋습관을 잠깐 멈추시겠어요?"
                    let subTitleText = "\n멈춘 습관은 '잠시 멈춤'에 보관되며\n언제든지 다시 시작하실 수 있습니다.\n다만, 다시 시작하실 때는 1일차로 돌아갑니다.😢"
                    
                    // 특정 문자열로 지정
                    let attributeTitleString = NSMutableAttributedString(string: titleText)
                    let attributeSubTitleString = NSMutableAttributedString(string: subTitleText)
                    
                    // 위에서 지정한 특정 문자열에 폰트 지정
                    attributeTitleString.addAttribute(.font, value: titleFont!, range: (titleText as NSString).range(of: "\(titleText)"))
                    attributeSubTitleString.addAttribute(.font, value: subTitleFont!, range: (subTitleText as NSString).range(of: "\(subTitleText)"))
                    
                    // Alert title, message 지정
                    let deleteAlert = UIAlertController(title: titleText, message: subTitleText, preferredStyle: .alert)
                    
                    // 주어진 키 경로로 식별되는 속성 값을 주어진 값으로 설정
                    deleteAlert.setValue(attributeTitleString, forKey: "attributedTitle")
                    deleteAlert.setValue(attributeSubTitleString, forKey: "attributedMessage")
                    
                    // 계속 도전 action을 눌렀을 때
                    let keepChallengeAlertAction = UIAlertAction(title: "계속 도전", style: .default) { _ in
                        
                        // 계속 도전 action을 누르면 swipe 숨기는 기능 필요
                        UIView.transition(with: tableView,
                                          duration: 0.35,
                                          options: .transitionCrossDissolve,
                                          animations: { tableView.reloadData() })
                        self.showToast(message: "잘 선택 하셨어요! 끝까지 화이팅! 👍", font:  UIFont(name: "IMHyemin-Bold", size: 14)!, ToastWidth: 240, ToasatHeight: 40)
                    }
                    
                    // 멈추기 action을 눌렀을 때
                    let pauseChallengeAlertAction = UIAlertAction(title: "멈추기", style: .default) { _ in
                        
                        // Realm 데이터 업데이트
                        do {
                            try self.realm.write {
                                itemForPause.isPausedHabit = true
                            }
                        } catch {
                            print("Error pause item, \(error)")
                        }
                        
                        // 리스트 새로고침
                        self.loadHabitList()
                        
                        self.showToast(message: "다시 시작하실 그 날을 기약하며 \n습관이 ‘잠시 멈춤’에 보관되었습니다. 👋", font: UIFont(name: "IM_Hyemin", size: 14)!, ToastWidth: 266, ToasatHeight: 64)
                    }
                    
                    // 계속 도전 action 색 지정
                    keepChallengeAlertAction.setValue(UIColor(red: 0.078, green: 0.804, blue: 0.541, alpha: 1), forKey: "titleTextColor")
                    
                    // 멈추기 action 색 지정
                    pauseChallengeAlertAction.setValue(UIColor(red: 0.697, green: 0.725, blue: 0.762, alpha: 1), forKey: "titleTextColor")
                    
                    // Alert에 action 추가
                    deleteAlert.addAction(pauseChallengeAlertAction)
                    deleteAlert.addAction(keepChallengeAlertAction)

                    self.present(deleteAlert, animated: true, completion: nil)
                }
            }
            
            // 삭제 이미지 & 백그라운드 지정
            pauseAction.image = UIImage(named: "ic-pause")
            pauseAction.backgroundColor = UIColor(named: "ViewBackground")
            
            return [pauseAction]
        
        // 왼쪽 스와이프 시
        case .left:
            let bookmarkAction = SwipeAction(style: .default, title: nil) { [self] action, indexPath in
                
                // 즐겨찾기 버튼 클릭 시 Realm 데이터 변경
                if let bookmarkCheck = listRealm?[indexPath.row].isBookmarked {
                    try! realm.write {
                        listRealm?[indexPath.row].isBookmarked = !bookmarkCheck
                    }
                }
                // 즐겨찾기 버튼 클릭 시 리스트 리로드
                reloadWhenTapBookmark()
            }
            
            // 즐겨찾기 버튼 이미지 & 백그라운드 지정
            bookmarkAction.image = UIImage(named: "swipeBookmark")
            bookmarkAction.backgroundColor = UIColor(named: "ViewBackground")
            

            return [bookmarkAction]
        }
    }
}

// MARK: - BookmarkCellDelegate Method
extension ConfigureVC: BookmarkCellDelegate {
    
    // bookmarkButtonTappedDelegate 구현
    func bookmarkButtonTappedDelegate(_ habitCell: HabitCell, didTapButton button: UIButton) -> Bool? {
        guard let row = myTableView.indexPath(for: habitCell)?.row else { return nil }
        
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
}

// MARK: - 동그리 로티
extension ConfigureVC {
    
    fileprivate func dongruri(){
        
        let customAnimationView = AnimationView(name: "Dongri")
        
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
            customAnimationView.widthAnchor.constraint(lessThanOrEqualToConstant: 86),
            customAnimationView.heightAnchor.constraint(lessThanOrEqualToConstant: 86)
            
        ])
    }
}

// MARK: - 노치가 있는지 없는지 탐색
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
