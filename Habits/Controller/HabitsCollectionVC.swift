//
//  HabitsCollectionVC.swift
//  Habits
//
//  Created by hoonsbrand on 2022/07/31.
//

import Foundation
import UIKit
import RealmSwift

class HabitsCollectionVC: UIViewController {
    
    @IBOutlet weak var habitsCollectionView: UICollectionView!
    
    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
    let emptyLabel = UILabel()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CollectionView에 대한 설정
        habitsCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        habitsCollectionView.dataSource = self
        habitsCollectionView.delegate = self
        
        // 사용할 CollectionView cell을 등록
        
        // nib 파일 가져옴
        let habitsCustomCollectionViewCellNib = UINib(nibName: String(describing: HabitsCustomCollectionViewCell.self), bundle: nil)
        
        // 가져온 nib파일로 CollectionView에 cell로 등록
        self.habitsCollectionView.register(habitsCustomCollectionViewCellNib, forCellWithReuseIdentifier: String(describing: HabitsCustomCollectionViewCell.self))
        
        // CollectionView의 CollectionView 레이아웃 설정
//        self.habitsCollectionView.collectionViewLayout = createCompositionalLayout()
        
        // 명예의 전당에 아무것도 없을 때 레이블 설정
        loadHOF()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadHOF()
        self.habitsCollectionView.reloadData()
    }
    
    
    func loadHOF() {
        let listCount = realm.objects(Habits.self).filter("isInHOF = true").count

        if listCount == 0 {             
            emptyLabel.frame = CGRect(x: 86, y: 382, width: 171, height: 48)
            emptyLabel.numberOfLines = 0
            emptyLabel.textAlignment = .center
            emptyLabel.text = "66일 간의 여정을 완료해서\n습관의 전당을 채워보세요!"
            emptyLabel.font = UIFont(name: "IM_Hyemin", size: 16)
            emptyLabel.textColor = UIColor(red: 0.678, green: 0.698, blue: 0.725, alpha: 1)

            let parent = self.view!
            
            parent.addSubview(emptyLabel)
            
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyLabel.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
            emptyLabel.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        } else {
            emptyLabel.removeFromSuperview()

        }
    }
}

// MARK: - 데이터 소스 설정 - 데이터와 관련된 것들
extension HabitsCollectionVC: UICollectionViewDataSource {
    
   
    
    
    // 각 섹션에 들어가는 아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listRealm = realm.objects(Habits.self).filter("isInHOF = true")
        return listRealm?.count ?? 0
    }
    
    // 각 CollectionView 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        // cell의 인스턴스
        let cell = habitsCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HabitsCustomCollectionViewCell.self), for: indexPath) as! HabitsCustomCollectionViewCell
        
        // label 설정
        if let list = listRealm?[indexPath.row] {
            
            let myCal = Calendar.current
            
            let myDateCom = myCal.dateComponents([.year, .month, .day], from: list.createTime!)
            let myDateCom2 = myCal.dateComponents([.year, .month, .day], from: list.dDay)
            
//            cell.firstLabel.text = "\(list.createTime!) ~ \(list.dDay)"
            cell.firstLabel.text = "\(myDateCom.year!)년 \(myDateCom.month!)월 \(myDateCom.day!)일 ~ \(myDateCom2.year!)년 \(myDateCom2.month!)월 \(myDateCom2.day!)일"
            cell.firstLabel.font = UIFont(name: "IM_Hyemin", size: 12)
            
            cell.secondLabel.text = list.title
            cell.secondLabel.font = UIFont(name: "IMHyemin-Bold", size: 16)
            
        }
        return cell
    }
}

// MARK: - CollectionView Delegate
extension HabitsCollectionVC: UICollectionViewDelegate {
    
}
