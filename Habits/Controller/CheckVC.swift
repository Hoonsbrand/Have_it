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
    
    @IBOutlet weak var elevenCheckView: UIView!
    @IBOutlet weak var sixBadge: UIView!
    
    
    @IBOutlet weak var circleProgressView: CircleProgress!
    
    @IBOutlet weak var successButton: UIButton!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    
    
    @IBOutlet weak var dDayTitleLabel: UILabel!{
        didSet{
            setDday()
        }
    }
    
    var btnArr : [UIButton] = []
    var habitTitle : String = "" // chekTitle 바꿀 데이터 전달 받을 변수
    var clickedTime : Date = Date() // 클릭한 시간
    // "D-Day" + \(dDayInt) 를 구성예정
    var dDayInt : Int = 0 // 남은 D- day 숫자
    
    var dDay : Date = Date() // Dday 시간.
    var dayCount : Int = Int() // 완료 횟수
    
    let realm = try! Realm()
    var resultRealm: Habits?
    
    var timeManager = TimeManager()
    
    //MARK: - overrideMethod viewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        getRealmData() // realm데이터 받아오기
        makeButton() // 버튼배열 만들기
        makeButtonLayout(btnArr) // 버튼레이어 표시
        successCount() // 완료한 숫자 표시
        setButtonImage(self.dayCount) // 이전에 완료한 습관 표시
        setHabitTitle() // 맨위에 제목표시
        dDaytext() // dday 날짜 전체표시
    
        
        
    }
    
    
    
    // MARK: - makeAlert (  알람메세지 )
    func makeAlert(_ count : Int){
        let completeAlert = UIAlertController(title: "습관 완료", message: "\(count + 1)일째 완료하셨습니다.", preferredStyle: .alert) // 완료 alert
        // 확인이 눌려야 실행
        let completeAlertAction = UIAlertAction(title: "완료", style: .default){
            (action) in
            self.changeElevenButtonImage(count)
            self.dayCount += 1
            self.resetSuccessButton()
            self.setRealmDate()
            let elevenDayCount = self.dayCount % 11
            self.circleProgressView.filleProgress(CGFloat(elevenDayCount))
            
        }
        // 습관을 완료하지 못했을 때
        let completeAlertCancel = UIAlertAction(title: "취소", style: .destructive,handler:nil)
        
        let finishAlert = UIAlertController(title: "  성공  ", message: "\(count + 1)일 달성 완료", preferredStyle: .alert)
        let finishAlertAction = UIAlertAction(title: "확인", style: .default){
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
            changeElevenButtonImage(count)
            self.dayCount += 1
            
            try! realm.write {
                resultRealm?.isInHOF = true
            }
            
            present(finishAlert,animated: true, completion: nil)
        default:
            return self.present(completeAlert, animated: true, completion: nil)
        }
    }
    
    // MARK:  changeButtonImage (Button이미지 변경)
    func changeElevenButtonImage(_ dayCount : Int){
        let transEleven = dayCount % 10
        btnArr[transEleven].setImage(UIImage(systemName: "flame.fill"), for: .normal)
    }
    
// MARK: - @IBAction Method
    //MARK: clickSuccessButton ( 성공버튼 클릭 액션 )
    
    @IBAction func clickSuccessButton(_ sender: UIButton) {
        resetSuccessButton()
        // 버튼입력일자가 하루 지났을 떄.
        if (timeManager.compareDate(clickedTime) || self.dayCount == 0 || self.dayCount<65){
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
    func receiveItem(_ id : String) {
        guard let list = realm.objects(Habits.self).filter("habitID = %@", id).first else { return }
        self.resultRealm = list
        let title = list.title
        self.habitTitle = title
        self.dDay = list.dDay
        guard let time = list.clickedTime else { return }
        self.clickedTime = time
        self.dDayInt = timeManager.calDateDiffer(dDay, Date()) // 현재시간으로 계산
    }
}

//MARK: - RealmData 처리
extension CheckVC{
    //MARK: getRealmData() cell에 해당하는 realm데이터 받아옴
    func getRealmData() {
        
        guard let data = resultRealm else { return }
        guard let time = data.clickedTime else { return } // 옵셔널 바인딩
        let count = data.dayCount //
        self.dayCount = count // 성공횟수
        self.clickedTime = time
        
    }
    
    //MARK: setRealmData() -> 뷰 나갈떄 Realm데이터 세팅
    func setRealmDate(){
        print("setRealmDate()")
        if let data = resultRealm{
            try! realm.write{
                data.clickedTime = self.clickedTime
                data.dayCount = self.dayCount
            }
        }
        
    }
    
}




//MARK: - CheckVC UI설정
extension CheckVC {
    func setHabitTitle(){
        self.navigationItem.title = habitTitle
        
    }
    //Date형식을 string으로 변환
    func dDaytext(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dDayText = dateFormatter.string(from: dDay)
        dDayLabel.text = dDayText
    }
    func successCount(){
        successLabel.text = "\(dayCount)"
    }
    
    
    
    //MARK:  CheckVCTitle 설정
    func setDday(){
        
        dDayTitleLabel.text = "D - \(dDayInt) 남음"
        dDayTitleLabel.textColor = .white
        dDayTitleLabel.font = UIFont.boldSystemFont(ofSize: 55)
        // 라벨의 사이즈를 해당크기에 맞게 설정
        dDayTitleLabel.sizeThatFits(CGSize(width: dDayTitleLabel.frame.width, height: dDayTitleLabel.frame.height))
        // checkVCTitle.sizeToFit() -> 자동으로 라벨의 크기를 텍스트에 맞게 수정
        // 뷰에 오토레이아웃을 작용하기위해 / 뷰에따라 자동으로 제약을 변환하는 기능을 꺼야됨
        
        //autolayout설정으로 인한, 텍스트잘림현상 해결
        dDayTitleLabel.adjustsFontSizeToFitWidth = true // 라벨의 크기에 맞게 텍스트폰트변경
        dDayTitleLabel.minimumScaleFactor = 0.2 // 텍스트 간 최소간격
        dDayTitleLabel.numberOfLines = 1 // 텍스트라인의 수
    }
    
    func makeButton(){
        for num in 0...9{
            let btn = UIButton()
            btn.tag = num
            self.elevenCheckView.addSubview(btn)
            
            btn.setTitle("", for: .normal)
            btn.setImage(UIImage(systemName: "flame"), for: .normal)
            btnArr.append(btn)
        }
    }
    
    func makeButtonLayout(_ btnArray : [UIButton]){
        for btn in btnArray{
            let index = btn.tag
            
            let column = index % 5
            let row = index / 5
            
            let width = self.elevenCheckView.frame.size.width / 5
            let height = self.elevenCheckView.frame.size.height / 2
            
            btn.frame = CGRect(x: CGFloat(column) * width, y: CGFloat(row) * height, width: width, height: height)
            
            //            btn.backgroundColor = .link
            //            btn.layer.cornerRadius = btn.frame.size.width / 2
        }
    }
    
    //MARK: - 이전에 달성한 습관 횟수 버튼에 구현
    func setButtonImage(_ count : Int){
        for count in 0..<count{
            changeElevenButtonImage(count)
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


//MARK: - Progressbar 세팅
extension CheckVC {

    
    
}

