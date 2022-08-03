//
//  CheckVC.swift
//  Habits
//
//  Created by 안지훈 on 7/23/22.

// Model CreatedTime -> 이름변경 요망.
// ViewController 파일 여러개 만들고 그룹화
// Beta때는 Realm으로 하는게 좋을 듯 ?? ImageVIew LayOut을 snapkit으로


import UIKit
import RealmSwift
import Toast_Swift

class CheckVC: UIViewController {
    
    
    @IBOutlet weak var successButton: UIButton!
    @IBOutlet weak var myView: UIView!
    var btnArr : [UIButton] = []
    
    
    @IBOutlet weak var checkVCTitle: UILabel!{
        didSet{
            setTitle()
        }
    }
    
    
    // Model.daycount 활용
    // createTime -> pastTime으로 넘겨서 현재시간이랑 비교를 해야겠네
    // Date
    var initCheckVCTitle : String = "" // chekTitle 바꿀 데이터 전달 받을 변수
    var clickedTime : Date = Date()
    
    var dateStr : Date = {
        let date = "2022-06-30 16:30"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let dataResult = dateFormatter.date(from: date) else { return Date() }
        return dataResult
    }()
    var dayCount : Int = Int()
    
    //MARK: - overrideMethod viewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        getRealmData()
        makeButton()
        makeButtonLayout(btnArr)
        setButtonImage(self.dayCount)
 

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        setRealmDate()
    }
    
    // MARK: - makeAlert (  알람메세지 )
    func makeAlert(_ count : Int){
        
        let completeAlert = UIAlertController(title: "습관 완료", message: "\(count + 1)일째 완료하셨습니다.", preferredStyle: .alert) // 완료 alert
        // 확인이 눌려야 실행
        let completeAlertAction = UIAlertAction(title: "완료", style: .default){
            (action) in
            self.changeButtonImage(count)
            self.dayCount += 1
            self.resetSuccessButton()
            
        }
        // 습관을 완료하지 못했을 때
        let completeAlertCancel = UIAlertAction(title: "취소", style: .destructive,handler:nil)
        
        
        let finishAlert = UIAlertController(title: "  성공  ", message: "\(count + 1)일 달성 완료", preferredStyle: .alert)
        let finishAlertAction = UIAlertAction(title: "확인.", style: .default){
            _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.navigationController?.popToRootViewController(animated: true)
            }  // 1 초뒤 팝뷰 , 메인쓰레드에서만 동장해야됨.
        }
        
        // 알림창 설정
        completeAlert.addAction(completeAlertCancel)
        completeAlert.addAction(completeAlertAction)
        
        finishAlert.addAction(finishAlertAction)
        switch count {
        case 65:
            changeButtonImage(count)
            self.dayCount += 1
            present(finishAlert,animated: true, completion: nil)
        default:
            return self.present(completeAlert, animated: true, completion: nil)
              }
          }
    
    // MARK:  changeButtonImage (Button이미지 변경)
    func changeButtonImage(_ dayCount : Int){
       
        btnArr[dayCount].setImage(UIImage(systemName: "checkmark.seal.fill"), for: .normal)
     
    }
    
    
    // MARK: - @IBAction Method
    //MARK: clickSuccessButton ( 성공버튼 클릭 액션 )
    
    @IBAction func clickSuccessButton(_ sender: UIButton) {
        resetSuccessButton()
        // 버튼입력일자가 하루 지났을 떄.
        if (compareDate(clickedTime) || self.dayCount == 0 || self.dayCount == 65){
            makeAlert(dayCount) // 완료했을 때 취소 했을 때 나눔
            self.clickedTime = Date() // 버튼 누른 시간을 기억
        } else {
            var toastStyle = ToastStyle()
            toastStyle.titleFont = .boldSystemFont(ofSize: 20)
            toastStyle.titleAlignment = .center
            toastStyle.messageAlignment = .center
            self.view.makeToast(" 아직 하루가 지나지 않았습니다. ", duration: 1.0, position: .center, title: " ❌ 실패 ❌", image: nil, style: toastStyle, completion: nil)
            
        }
    }
    
}


// MARK: - setData Method ( ConfigVC prepare()로 받아온 데이터 )
extension CheckVC {
    
    // MARK: configVC - prepared() 에서 데이터 전달 받는 데이터 변경 / title이 키 값
    func receiveItem(_ title : String) {
        self.initCheckVCTitle = title
    }
    
}
//MARK: - RealmData 처리
extension CheckVC{
    //MARK: getRealmData() cell에 해당하는 realm데이터 받아옴
    func getRealmData() {
        let realm = try! Realm()
        
        guard let data = realm.objects(Habits.self).filter(NSPredicate(format: "title = %@", initCheckVCTitle )).first else { return }
        guard let time = data.createTime else { return } // 옵셔널 바인딩
        let count = data.dayCount //
        self.dayCount = count // 성공횟수
        self.clickedTime = time
    }
    
    
    //MARK: setRealmData() -> 뷰 나갈떄 Realm데이터 세팅
    func setRealmDate(){
        let realm = try! Realm()
        
        if let data = realm.objects(Habits.self).filter(NSPredicate(format: "title = %@", initCheckVCTitle )).first{
            try! realm.write{
                data.createTime = self.clickedTime
                data.dayCount = self.dayCount
                
            }
        }
        
    }
}

//MARK: - 시간 처리
extension CheckVC {
    func compareDate(_ date : Date) -> Bool {
        let currentTime = Calendar.current.dateComponents([.year , .month, .day], from: Date())
        let pastTime = Calendar.current.dateComponents([.year , .month, .day], from: date)
        
        if ( currentTime.year! > pastTime.year! || currentTime.month! > pastTime.month! ||  currentTime.day! > pastTime.day!){
            
            return true
        }
        else { return false }
        
    }
    
}



//MARK: - CheckVC UI설정
extension CheckVC {
    
    //MARK:  CheckVCTitle 설정
    func setTitle(){
        checkVCTitle.text = initCheckVCTitle // 텍스트 할당3
        // 라벨의 사이즈를 해당크기에 맞게 설정
        checkVCTitle.sizeThatFits(CGSize(width: checkVCTitle.frame.width, height: checkVCTitle.frame.height))
        // checkVCTitle.sizeToFit() -> 자동으로 라벨의 크기를 텍스트에 맞게 수정
        // 뷰에 오토레이아웃을 작용하기위해 / 뷰에따라 자동으로 제약을 변환하는 기능을 꺼야됨
        
        //autolayout설정으로 인한, 텍스트잘림현상 해결
        checkVCTitle.adjustsFontSizeToFitWidth = true // 라벨의 크기에 맞게 텍스트폰트변경
        checkVCTitle.minimumScaleFactor = 0.2 // 텍스트 간 최소간격
        checkVCTitle.numberOfLines = 1 // 텍스트라인의 수
    }
    
    
   
    func makeButton(){
        for num in 0...65{
            let btn = UIButton()
            btn.tag = num
            self.myView.addSubview(btn)
            btn.setImage(UIImage(systemName: "checkmark.seal"), for: .normal)
            btn.setTitle("", for: .normal)
//            btn.backgroundColor = .green.withAlphaComponent(0.3)
//            btn.layer.borderColor = UIColor.black.cgColor
//            btn.layer.borderWidth = 1
            btnArr.append(btn)
            
        }
    }
    
    func makeButtonLayout(_ btnArray : [UIButton]){
        
        
        for btn in btnArray{
            let index = btn.tag
            
            let column = index % 6
            let row = index / 6
            
            let width = self.myView.frame.size.width / 6
            let height = self.myView.frame.size.height / 11
          
            
            btn.frame = CGRect(x: CGFloat(column) * width, y: CGFloat(row) * height, width: width, height: height)
           
        }
        
        
    }
    
    
    //MARK: - 이전에 달성한 습관 횟수 버튼에 구현
    func setButtonImage(_ count : Int){
        for count in 0..<count{
            changeButtonImage(count)
        }
    }
    
    //MARK: 버튼이 눌리는동안 색 변환
    @objc func changeColorSuccessBtn(){
        successButton.backgroundColor = .link
        successButton.layer.cornerRadius = 5
        successButton.setTitleColor(.white, for: .normal)
    }
    
    //MARK: 다시 초기 버튼모양
    func resetSuccessButton(){
        successButton.setTitle("성공", for: .normal)
        successButton.setTitleColor(.link, for: .normal)
        successButton.backgroundColor = .clear
    }
    
    
    
}
