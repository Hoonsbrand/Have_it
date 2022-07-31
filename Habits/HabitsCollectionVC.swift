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
    
    @IBOutlet weak var habitSegmentControl: UISegmentedControl!
    @IBOutlet weak var habitsCollectionView: UICollectionView!
    
    fileprivate let systemImage = "face.smiling"
    
    let realm = try! Realm()
    var listRealm: Results<Habits>?
    
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
        self.habitsCollectionView.collectionViewLayout = createCompositionalLayout()
    }
}

// MARK: - CollectionView 컴포지셔널 레이아웃 관련
extension HabitsCollectionVC {
    
    // 컴포지셔널 레이아웃 설정
    fileprivate func createCompositionalLayout() -> UICollectionViewLayout {
        // 컴포지셔널 레이아웃 생성
        let layout = UICollectionViewCompositionalLayout {
            // 만들게 되면 튜플 (키: 값, 키: 값) 의 묶음으로 들어옴, 반환 하는 것은 NSCollectionLayoutSection 컬렉션 레이아웃 섹션을 반환해야 함
            (sectionIndex: Int, layoutEnvrionment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            // 아이템에 대한 사이즈
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100 ))
            
            // 위에서 만든 아이템 사이즈로 아이템 만들기
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // 아이템 간의 간격 설정
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            // 그룹 사이즈
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/5))
            
            // 그룹 사이즈로 그룹 만들기
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
            // 그룹으로 섹션 만들기
            let section = NSCollectionLayoutSection(group: group)
            
            // 쎅션에 대한 간격 설정
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            
            return section
        }
        return layout
    }
}

// MARK: - 데이터 소스 설정 - 데이터와 관련된 것들
extension HabitsCollectionVC: UICollectionViewDataSource {
    
    // 각 섹션에 들어가는 아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listRealm = realm.objects(Habits.self).filter("dayCount = 66")
        return listRealm?.count ?? 0
    }
    
    // 각 CollectionView 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        let cellId = String(describing: HabitsCollectionViewCell.self)
        
        // cell의 인스턴스
        let cell = habitsCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HabitsCustomCollectionViewCell.self), for: indexPath) as! HabitsCustomCollectionViewCell
        
        // cell 이미지 설정
        cell.imageName = self.systemImage
        
        // label 설정
        if let list = listRealm?[indexPath.row] {
            cell.labelName = list.title
        }
        return cell
    }
}

// MARK: - CollectionView Delegate
extension HabitsCollectionVC: UICollectionViewDelegate {
    
}
