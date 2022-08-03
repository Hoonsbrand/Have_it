//
//  ViewController.swift
//  Habits
//
//  Created by hoonsbrand on 7/22/22.
//

import UIKit
import RealmSwift
import Toast_Swift

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
        
        let image = UIImage(named: "backgroundImg")
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
                self.view.makeToast("최대 추가 개수는 20개 입니다.", duration: 1.5, point: CGPoint(x: 187, y: 200), title: nil, image: nil, completion: nil)
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
            
            // 해당 셀 realm 옵셔널바인딩
            guard let list = listRealm?[(selectIndexPath.row)] else { return }
            checkView.receiveItem(list.title)
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
        cell.delegate = self
        cell.loadDelegate = self
        
        if let list = listRealm?[indexPath.row] {
            cell.textLabel?.text = list.title
            
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
        listRealm = realm.objects(Habits.self).sorted(byKeyPath: "isBookmarked", ascending: false).filter("dayCount != 66")
        myTableView.reloadData()
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

