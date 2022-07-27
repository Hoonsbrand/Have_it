//
//  CheckVC.swift
//  Habits
//
//  Created by 안지훈 on 7/23/22.


import UIKit
import RealmSwift

class CheckVC: UIViewController {
    
    @IBOutlet weak var checkOne: UIButton! // 첫번째 버튼
    @IBOutlet weak var checkTwo: UIButton! // 두번쨰 버튼
    @IBOutlet weak var checkThree: UIButton! // 세번째 버튼
  
    
    @IBOutlet weak var checkVCTitle: UILabel! // 제목
    
    
    // Model.daycount 활용
    // createTime -> pastTime으로 넘겨서 현재시간이랑 비교를 해야겠네
    // Date
    var initCheckVCTitle : String = "" // chekTitle 바꿀 데이터 전달 받을 변수
    var currentTime : String = "" // 그냥 처음에
    var pastTime : Date?
    var dayCount : Int?
    
    //MARK: - overrideMethod
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setTitle()
        
    }
    
   
    
    // MARK: - makeAlert (  알람메세지 )
    func makeAlert(_ count : Int){
        
        let completeAlert = UIAlertController(title: "완료",message: "\(count)일째 반복", preferredStyle: UIAlertController.Style.alert) // 완료 alert
        let completeAlertAction = UIAlertAction(title: "완료 하였습니다.", style: .default)// 완료 alert 확인버튼
        let finishAlert = UIAlertController(title: " 목표 완료 ", message: "작심삼일 성공.", preferredStyle: .alert)
        let finishAlertAction = UIAlertAction(title: "확인.", style: .default)
        
        completeAlert.addAction(completeAlertAction)
        finishAlert.addAction(finishAlertAction)
        if( count <= 3) {
            present(completeAlert, animated: true, completion: nil)
            print(count)
            
        }
        if ( count > 3 ) {
            present(finishAlert,animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigationController?.popToRootViewController(animated: true)
            }// 1 초뒤 팝뷰 , 메인쓰레드에서만 동장해야됨.-> 공부필요
        }
    }
    
  
    
    
    
    // MARK : - changeButtonImage (Button이미지 변경)
    func changButtonImage(_ btnCount : Int){
        switch btnCount{
        case 0:
            self.btnCount += 1
            checkOne.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal) //첫번째아이콘
        case 1:
            self.btnCount += 1
            checkTwo.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal) // 두번째아이콘
            print(self.btnCount)
        case 2:
            self.btnCount += 1
            checkThree.setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal) // 세번째 아이콘
      
        default:
            return
        }
    }
    // MARK: - IBAction Method
    
    // MARK: clickSuccessButton ( 성공버튼 클릭 액션 )
    @IBAction func clickSuccessButton(_ sender: UIButton) {
        if btnCount == 3 {
            btnCount += 1 // 완료되었을 때
            changButtonImage(btnCount)
        }else {
            changButtonImage(btnCount)
        }
        makeAlert(btnCount) // 알람
    }
    
}


// MARK: - setDataMethod


extension CheckVC {
    
    // MARK: configVC - prepared() 에서 데이터 전달 받는 데이터 변경 / title이 키 값
    func receiveItem(_ title : String) {
        print("CheckVC - receiveItem called() item : \(title)")
        self.initCheckVCTitle = title
    }
    
    
    
    //MARK: - CheckVCTitle 설정
    func setTitle(){
        checkVCTitle.text = initCheckVCTitle // 텍스트 할당
        // 라벨의 사이즈를 해당크기에 맞게 설정
        checkVCTitle.sizeThatFits(CGSize(width: checkVCTitle.frame.width, height: checkVCTitle.frame.height))
        // checkVCTitle.sizeToFit() -> 자동으로 라벨의 크기를 텍스트에 맞게 수정
        
        //autolayout설정으로 인한, 텍스트잘림현상 해결
        checkVCTitle.adjustsFontSizeToFitWidth = true // 라벨의 크기에 맞게 텍스트폰트변경
        checkVCTitle.minimumScaleFactor = 0.2 // 텍스트 간 최소간격
        checkVCTitle.numberOfLines = 1 // 텍스트라인의 수
    }
    //MARK - RealmData 처리
    
    //MARK:  cell에 해당하는 realm데이터 받아오기
    func setRealmData() ->  Habits{
        let realm = try! Realm()
        let data = realm.objects(Habits.self).filter(NSPredicate(format: "title = %@", initCheckVCTitle ?? "")).first
        pastTime = data?.createTime
        dayCount = data?.dayCount
        
    }
    
    
}
