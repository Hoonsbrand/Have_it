//
//  addLIstVC.swift
//  Habits
//
//  Created by hoonsbrand on 7/22/22.
//

import UIKit
import RealmSwift
import Toast_Swift

class AddLIstVC: UIViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    // D_day 시간계산을 위해
    let timeManager = TimeManager()
    
    let configVC = ConfigureVC()
    
    @IBOutlet weak var inputHabitTextField: UITextField!
    @IBOutlet weak var addButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputHabitTextField.delegate = self
        inputHabitTextField.becomeFirstResponder()
//        self.navigationItem.setHidesBackButton(false, animated: true)
        
        // addButton 모양, 섀도우
        addButtonOutlet.layer.cornerRadius = 16
        addButtonOutlet.layer.shadowColor = UIColor(red: 0.16, green: 0.21, blue: 0.14, alpha: 0.3).cgColor
        addButtonOutlet.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButtonOutlet.layer.shadowOpacity = 1.0
        addButtonOutlet.layer.shadowRadius = 10
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "IMHyemin-Bold", size: 24)!]
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.topItem?.title = ""
    }

    // MARK: textField Delegate Method
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text else { return false }
        
        // textField에 있는 문자들과 사용자가 입력한 문자의 합 개수
        let count = textFieldText.count + string.count
        
        // count가 15가 넘으면 Toast 팝업, 백스페이스(지우기)를 누를 땐 글자수가 15자라도 토스트 팝업 x
        if count >= 15 && !string.isEmpty {
            self.view.makeToast("15자 내로 작성해주세요.", duration: 1.5, position: .center, title: nil, image: nil, style: .init(), completion: nil)
        }
        
        // count가 15보다 크다면 false이므로 더 이상 글자 추가 불가
        return count <= 15
    }
    
    // MARK: backToView
    @IBAction func backToView(_ sender: UIButton) {
        
        if let habitTitle = inputHabitTextField.text {
            if habitTitle == "" {
                // 습관 이름을 안쓰고 등록을 누르면 Toast 팝업
                self.view.makeToast("습관을 입력해주세요!", duration: 1.5, position: .center, title: nil, image: nil, completion: nil)
                return
            }
            
            // 명예의 전당에 있지 않은 습관들 목록을 가져옴
            let list = realm.objects(Habits.self).filter("isInHOF = false")
            
            // 그 목록들 중에서 이미 있는 습관 제목이면 등록을 막음
            for elements in list {
                if elements.title == inputHabitTextField.text {
                    self.view.makeToast("이미 있는 습관입니다!", duration: 1.5, position: .center, title: nil, image: nil, completion: nil)
                    return
                }
            }
            let newHabit = Habits(title: habitTitle, createTime: Date())
            // ==========================
            guard let creatTime = newHabit.createTime else { return }
            // dDay계산
            newHabit.dDay = timeManager.getDday(creatTime)
            print(creatTime)
            print(newHabit.dDay)
            try! realm.write {
                realm.add(newHabit)
            }
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: 다른 곳 탭 했을 때 키보드가 사라지는 메서드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


