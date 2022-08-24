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
    
    // MARK: - viewDidLoad
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
        
        // 명예의 전당에 아무것도 없을 때 레이블 설정
        loadHOF()
        
        // 노치가 없으면 탭바의 크기를 바꿈
        if !UIDevice.current.hasNotch {
            tabBarController?.tabBar.frame.size.height = 60
            tabBarController?.tabBar.frame.origin.y = view.frame.height - 60
            tabBarController?.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        }
    }
    
    // MARK: - 습관의 전당 로드
    func loadHOF() {
        let listCount = realm.objects(Habits.self).filter("isInHOF = true").count
        
        // 습관의 전당에 데이터가 없다면 레이블 생성
        if listCount == 0 {             
            emptyLabel.frame = CGRect(x: 86, y: 382, width: 171, height: 48)
            emptyLabel.numberOfLines = 0
            emptyLabel.textAlignment = .center
            emptyLabel.text = "66일 간의 여정을 완료해서\n습관의 전당을 채워보세요!"
            emptyLabel.font = UIFont(name: "IM_Hyemin", size: 16)
            emptyLabel.textColor = UIColor(red: 0.678, green: 0.698, blue: 0.725, alpha: 1)

            // 레이블 오토레이아웃
            let parent = self.view!
            
            parent.addSubview(emptyLabel)
            
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyLabel.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
            emptyLabel.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        } else {
            // 습관의 전당에 데이터가 있다면 레이블 삭제
            emptyLabel.removeFromSuperview()
        }
    }
}

// MARK: - 데이터 소스 설정 - 데이터와 관련된 것들
extension HabitsCollectionVC: UICollectionViewDataSource {
    
    // 각 섹션에 들어가는 아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // 습관의 전당이 true인 데이터만 return
        listRealm = realm.objects(Habits.self).filter("isInHOF = true")
        return listRealm?.count ?? 0
    }
    
    // 각 CollectionView 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        // cell의 인스턴스
        let cell = habitsCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HabitsCustomCollectionViewCell.self), for: indexPath) as! HabitsCustomCollectionViewCell
        
        // label 설정
        if let list = listRealm?[indexPath.row] {
            
            // Calendar 인스턴스 생성
            let myCal = Calendar.current
            
            // Calendar로 표시할 포맷 지정
            let startDate = myCal.dateComponents([.year, .month, .day], from: list.createTime!)
            let endDate = myCal.dateComponents([.year, .month, .day], from: list.dDay)
            
            // Calendar의 포맷에 따라 cell text 지정
            cell.firstLabel.text = "\(startDate.year!)년 \(startDate.month!)월 \(startDate.day!)일 ~ \(endDate.year!)년 \(endDate.month!)월 \(endDate.day!)일"
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
