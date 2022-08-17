import UIKit
import RealmSwift
import Toast_Swift

class CheckVC: UIViewController {
    
    
    @IBOutlet weak var myProgress: CircleProgress! // 프로그래스바
    @IBOutlet weak var successButton: UIButton!
 
    @IBOutlet weak var titleSVTopView: UIView! // 타이틀 스택뷰 탑뷰
    @IBOutlet weak var titleStackView: UIStackView! // 타이틀스택뷰

    
    
    @IBOutlet weak var stampCheckView: UIStackView!
    @IBOutlet var stampArray: [UIButton]!
    @IBOutlet weak var checkVCTitle: UILabel!{ // 제목
        didSet{
            setTitle()
        }
    }
    @IBOutlet weak var percentLabel: UILabel! // N %
    @IBOutlet weak var dDayLabel: UILabel! // D+N
    @IBOutlet weak var successLabel: UILabel!// 성공횟수
    
    var habitTitle : String = "" // chekTitle 바꿀 데이터 전달 받을 변수
    var clickedTime : Date = Date() // 클릭한 시간
    // "D-Day" + \(dDayInt) 를 구성예정
    
    var dDayInt : Int = 0 // 남은 D- day 숫자
    var dDay : Date = Date() // Dday 날짜
    var dayCount : Int = Int() // 완료 횟수
    
    
    
    let realm = try! Realm()
    var resultRealm: Habits?
    
    var timeManager = TimeManager()
    
    //MARK: - overrideMethod viewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        setButton()
        getRealmData()
        setButtonImage(self.dayCount)
        setHabitTitle()
        setDdayLabelSuccessLabel()
        setPercentageLabel(dayCount: self.dayCount)
        setStackViewColor()
        
        self.myProgress.layer.cornerRadius = 20
        self.myProgress.backgroundColor = .clear
        
        let elevenDayCount = dayCount % 11
        self.myProgress.filleProgress(fromValue: CGFloat(elevenDayCount) - 1.0 , toValue: CGFloat(elevenDayCount))
    }
    
    // CheckVC에서만 네비게이션 바 보이게 하기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    
    // MARK: - makeAlert (  알람메세지 )
    func makeAlert(_ count : Int){
        let completeAlert = UIAlertController(title: "습관 완료", message: "\(count + 1)일째 완료하셨습니다.", preferredStyle: .alert) // 완료 alert
        // 확인이 눌려야 실행
        let completeAlertAction = UIAlertAction(title: "완료", style: .default){ [weak self]
            (action) in
            guard let self = self else { return }
            self.changeButtonImage(count)
            self.dayCount += 1
            self.setRealmDate()
            let elevenDayCount = count % 11
            self.myProgress.filleProgress(fromValue: CGFloat(elevenDayCount) - 1.0 , toValue: CGFloat(elevenDayCount))
            self.setDdayLabelSuccessLabel()
            self.setPercentageLabel(dayCount: self.dayCount)
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
            changeButtonImage(count)
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
    func changeButtonImage(_ dayCount : Int){
       
        let stampCount = dayCount % 10
        print("changeButton called() - count : \(stampCount)")
        
        stampArray[stampCount].tintColor = UIColor(named: "ButtonColor")
        stampArray[stampCount].setImage(UIImage(named: "stamp.active")?.withRenderingMode(.automatic), for: .normal)
        
        
    }
    
// MARK: - @IBAction Method
    //MARK: clickSuccessButton ( 성공버튼 클릭 액션 )
    
    @IBAction func clickSuccessButton(_ sender: UIButton) {
       
        // 버튼입력일자가 하루 지났을 떄.
        if (timeManager.compareDate(clickedTime) || self.dayCount == 0 || self.dayCount < 66){
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
        resultRealm = list
        let title = list.title
        habitTitle = title
        dDay = list.dDay
        guard let time = list.clickedTime else { return }
        clickedTime = time
        dDayInt = timeManager.calDateDiffer(dDay, Date()) // 현재시간으로 계산
        // 11로 나눈 숫자를 사용하기위해
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
        self.navigationItem.title = " 습관상세 "
        
        
    }
    
    
    func setButton(){
        print("초기버튼이미지 셋팅")
        for btn in stampArray{
            btn.setImage(UIImage(named: "stamp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        }
    }
    
    //MARK:  CheckVCTitle 설정
    func setTitle(){
        
        checkVCTitle.text = resultRealm?.title
        checkVCTitle.textColor = UIColor(named: "textFontColor")
        checkVCTitle.sizeThatFits(CGSize(width: checkVCTitle.frame.width, height: checkVCTitle.frame.height))
        checkVCTitle.font = UIFont(name: "IM_Hyemin", size: 20)
        // 라벨의 사이즈를 해당크기에 맞게 설정
        
        // checkVCTitle.sizeToFit() -> 자동으로 라벨의 크기를 텍스트에 맞게 수정
        // 뷰에 오토레이아웃을 작용하기위해 / 뷰에따라 자동으로 제약을 변환하는 기능을 꺼야됨
        
        //autolayout설정으로 인한, 텍스트잘림현상 해결
        checkVCTitle.adjustsFontSizeToFitWidth = true // 라벨의 크기에 맞게 텍스트폰트변경
        checkVCTitle.minimumScaleFactor = 0.2 // 텍스트 간 최소간격
        checkVCTitle.numberOfLines = 1 // 텍스트라인의 수
    }
    
    
    
    //MARK: - 이전에 달성한 습관 횟수 버튼에 구현
    func setButtonImage(_ count : Int){
        
        let tenCount = count % 10
        
        print("초기버튼세팅 dayCount = \(count)")
        for tenCount in 0..<tenCount{
            // 10 개의 배열일 경우로 초기화
            changeButtonImage(tenCount)
        }
    }
    
    //MARK: 디데이,성공횟수 라벨 설정
    func setDdayLabelSuccessLabel(){
        
        self.dDayLabel.text = "D - \(dDayInt)"
        dDayLabel.textColor = UIColor(named: "textFontColor")
        dDayLabel.layer.cornerRadius =  dDayLabel.frame.size.height / 2
        dDayLabel.clipsToBounds = true
        dDayLabel.font = UIFont(name: "IM_Hyemin", size: 13)
        dDayLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.successLabel.text = "\(dayCount) 회"
        successLabel.textColor = UIColor(named: "textFontColor")
        successLabel.font = UIFont(name: "IM_Hyemin", size: 17)
    }
    //MARK: 11일로 도는 사이클의 percentage Label
    func setPercentageLabel(dayCount : Int){
        let percent = dayCount % 66
        let initPercent : Float = Float(dayCount) / 66.0
        let multiPercent = initPercent * 100
        let percent1 = Int(multiPercent) % 100
        let result = floor(Double(percent1))
   
        
        if percent == 0 {
            self.percentLabel.text = " 100 % "
        }
        else{
            self.percentLabel.text = "\(Int(result))% "
        }
    }
    
    func setStackViewColor(){
        
        titleSVTopView.backgroundColor = UIColor(named: "ButtonColor")
        titleSVTopView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        
        titleStackView.layer.cornerRadius = 15
        titleStackView.layer.borderWidth = 2
        titleStackView.layer.borderColor = UIColor(named: "ButtonColor")?.cgColor
        //titleView 위부분 색 넣기
        
        
        // stampCheckView설정
        stampCheckView.layer.cornerRadius = 15
        stampCheckView.layer.borderWidth = 2
        stampCheckView.layer.borderColor = UIColor(named: "ButtonColor")?.cgColor
    }
    
}
extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
