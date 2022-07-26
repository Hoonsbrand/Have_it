//
//  ViewController.swift
//  Habits
//
//  Created by 안지훈 on 7/22/22.
//

import UIKit
import RealmSwift

class ConfigureVC: UIViewController, BookmarkCellDelegate {
    
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

    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
    var habitCell = HabitCell()
    
    @IBOutlet weak var myTableView: UITableView!
            
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.dataSource = self
        myTableView.register(UINib(nibName: "HabitCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        loadHabitList()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.myTableView.reloadData()
        loadHabitList()
    }
    
    //MARK: - prepareMethod / CheckVC에 데이터 전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "sgCheck"{
            let cell = sender as! UITableViewCell
            guard let indexPath = self.myTableView.indexPath(for: cell) else { return }
//            let checkView = segue.destination as! CheckVC         에러
            
//            if let list = listRealm?[indexPath.row] {
//                var content = cell.defaultContentConfiguration()
//                content.text = list.title
//                cell.contentConfiguration = content
//            }
            // 해당 셀 realm 옵셔널바인딩
            guard let list = listRealm?[(indexPath.row)] else { return }
//            checkView.receiveItem(list.title)                     에러
            
           
        }
        
    }
    
}
}

// MARK : - TableView DataSource
extension ConfigureVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let habitList = listRealm {
            return habitList.count
        }
        return 0
    }
    
    // 셀 추가
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! HabitCell
        cell.delegate = self
        
        
        if let list = listRealm?[indexPath.row] {
            cell.textLabel?.text = list.title
            
            if list.isBookmarked {
                cell.bookmarkOutlet.setTitle("⭐", for: .normal)
            }
//            var content = cell.defaultContentConfiguration()
//            content.text = list.title
//            cell.contentConfiguration = content
        }
        return cell
    }
    
    func loadHabitList() {
        listRealm = realm.objects(Habits.self)
        myTableView.reloadData()
    }
}
