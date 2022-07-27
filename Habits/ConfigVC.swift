//
//  ViewController.swift
//  Habits
//
//  Created by 안지훈 on 7/22/22.
//

import UIKit
import RealmSwift

class ConfigureVC: UIViewController, BookmarkCellDelegate {
    
    

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
    
//    //MARK: - prepareMethod / CheckVC에 데이터 전달
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "sgCheck"{
//            let cell = sender as! UITableViewCell
//            guard let indexPath = self.myTableView.indexPath(for: cell) else { return }
//            let checkView = segue.destination as! CheckVC
//
//            // 해당 셀 realm 옵셔널바인딩
//            guard let list = listRealm?[(indexPath.row)] else { return }
//            checkView.receiveItem(list.title)
//
//        }
//    }
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
        }
        return cell
    }
    
    func loadHabitList() {
        listRealm = realm.objects(Habits.self)
        myTableView.reloadData()
    }
    
    // MARK: BookmarkCellDelegate Method 구현
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
    
    func DateType2String() -> String{
        let current = Date()
        
        let formatter = DateFormatter()
        //한국 시간으로 표시
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        //형태 변환
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter.string(from: current)
    }
}
