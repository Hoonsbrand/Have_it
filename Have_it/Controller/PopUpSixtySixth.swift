//
//  PopUpSixtySixth.swift
//  Habits
//
//  Created by 안지훈 on 8/22/22.
//

import UIKit

class PopUpSixtySixth: UIViewController {

    @IBOutlet weak var backGround: UIView!
    @IBOutlet weak var SStitle: UILabel!
    @IBOutlet weak var goToHonorButton: UIButton!
    @IBOutlet weak var SScontent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SStitle.font = UIFont(name: "IMHyemin-Bold", size: 20)
        SStitle.text = " 축하드려요! 🙌 \n 66일을 모두 해내셨어요!"
        SStitle.sizeToFit()
        
        SScontent.font = UIFont(name: "IM_Hyemin", size: 14)
        SScontent.text = "이 습관이 하루의 일과로 \n 자리 잡았기를 바라며 \n 완성한 습관은 습관의 전당에 전시됩니다."
        SScontent.textColor = UIColor(named: "textFontColor")
        
        
        goToHonorButton.layer.cornerRadius = 8
        goToHonorButton.titleLabel?.font = UIFont(name: "IMHyemin-Bold", size: 16)
        
        goToHonorButton.addTarget(self, action: #selector(goToHonor), for: .touchUpInside)
        backGround.layer.cornerRadius = 16
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notification.goToHoner), object: nil)
    }
    
    @objc fileprivate func goToHonor(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.goToHoner), object: nil)
        self.dismiss(animated: true,completion: nil)
    }
    

}
