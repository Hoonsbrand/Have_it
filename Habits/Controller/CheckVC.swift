import UIKit
import RealmSwift
import Toast_Swift

class CheckVC: UIViewController {
    
    
    @IBOutlet weak var myProgress: CircleProgress! // 프로그래스바
    @IBOutlet weak var successButton: UIButton!
    @IBOutlet weak var titleSVTopView: UIView! // 타이틀 스택뷰 탑뷰
    @IBOutlet weak var titleStackView: UIStackView! // 타이틀스택뷰
    @IBOutlet weak var titleSVTop: UIStackView!
    @IBOutlet weak var stampView: UIView!
    
    @IBOutlet var stampArray: [UIButton]!
    @IBOutlet weak var checkVCTitle: UILabel!{ // 제목
        didSet{
            setTitle()
        }
    }
    @IBOutlet weak var percentLabel: UILabel! // N %
    @IBOutlet weak var dDayLabel: UILabel! // D+N
    @IBOutlet weak var successLabel: UILabel!// 성공횟수
    
    @IBOutlet weak var habitComplete: UILabel!
    @IBOutlet weak var goToSuccess: UILabel!
    @IBOutlet weak var successText: UILabel!
    
    
    
    
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
        
        getRealmData() // 데이터베이스 받아옴
        initStamp() // 스탬프 이미지 설정
        setButtonImage(self.dayCount) // 성공횟수에따른 스탬프 수 설정
        setHabitTitle() // 타이틀 설정
        setDdayLabelSuccessLabel() // 디데이,성공횟수, 성공문구 설정
        setPercentageLabel(dayCount: self.dayCount) // 퍼센트라벨 설정
        setStackViewColor() // 테두리 색 설정
        tenCycle(dayCount: self.dayCount) // 10회를 기준으로 초기화
        
        successUI() // 성공버튼 UI 설정
        // 성공횟수 라벨 (변동x)
        habitComplete.textColor = UIColor(named: "textFontColor")
        habitComplete.font = UIFont(name: "IM_Hyemin", size: 16)
        
        // 프로그래스바 설정
        self.myProgress.layer.cornerRadius = 20
        self.myProgress.backgroundColor = .clear
        
        // 데이터에따른 초기 프로그래스바 상태 설정
        self.myProgress.filleProgress(fromValue: dayCount - 1, toValue: dayCount)
    }
    
    // CheckVC에서만 네비게이션 바 보이게 하기 ( Navigation 설정 )
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // navigation back button 설정
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "IMHyemin-Bold", size: 24)!]
        let backBarBtnItem = UIBarButtonItem()
        backBarBtnItem.title = ""
        backBarBtnItem.tintColor = .black
        navigationController?.navigationBar.backItem?.backBarButtonItem = backBarBtnItem
        
        
    }
    
    
    
    // MARK: - makeAlert (  알람메세지 )
    func makeAlert(_ count : Int){
        
        let titleFont = [NSAttributedString.Key.font: UIFont(name: "IM_Hyemin", size: 20)]
        let titleAttrString = NSMutableAttributedString(string: "오늘도 내가 해냄! 😎", attributes: titleFont as [NSAttributedString.Key : Any])
        
        
        
        let completeAlert = UIAlertController(title: nil, message: nil, preferredStyle: .alert) // 완료 alert
        completeAlert.setValue(titleAttrString, forKey:"attributedTitle")
        // 확인이 눌려야 실행
        let completeAlertAction = UIAlertAction(title: "완료", style: .default){ [weak self]
            (action) in
            guard let self = self else { return }
            self.changeButtonImage(count) // 스탬프 색칠
            self.dayCount += 1 // 횟수증가
            self.setRealmDate() // 데이터베이스에 데이터전달
            self.myProgress.filleProgress(fromValue: count - 1 , toValue: count) // 프로그래스바 애니메이션
            self.setDdayLabelSuccessLabel() // 성공횟수,d day 설정
            self.setPercentageLabel(dayCount: self.dayCount) // 퍼센트라벨 설정
            self.tenCycle(dayCount: self.dayCount) // 10 번째인지 확인
            self.onceClickedDay()
            
        }
        completeAlertAction.setValue(UIColor(named: "StampColor"), forKey: "titleTextColor")
        // 습관을 완료하지 못했을 때
        let completeAlertCancel = UIAlertAction(title: "취소", style: .cancel,handler:nil)
        completeAlertCancel.setValue(UIColor.lightGray, forKey: "titleTextColor")
        
        // 알림창 설정
        completeAlert.addAction(completeAlertCancel)
        completeAlert.addAction(completeAlertAction)
        
        
        switch count {
        case 65:
            changeButtonImage(count)
            self.dayCount += 1
            
            
            try! realm.write {
                resultRealm?.isInHOF = true
            }
            let storyBoard = UIStoryboard.init(name: "PopUpSixtySixth", bundle: nil)
            // storyBoard를 ViewController로가져오기
            let popUpView = storyBoard.instantiateViewController(withIdentifier: "PopUpSixtySixth")
            // 뷰가 보여질 떄 스타일
            popUpView.modalPresentationStyle = .overCurrentContext
            // 뷰가 사라질 떄 스타일
            popUpView.modalTransitionStyle = .crossDissolve
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.present(popUpView, animated: true, completion: nil)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(showHonor), name: NSNotification.Name(rawValue: Notification.goToHoner), object: nil)
            
            
        default:
            return self.present(completeAlert, animated: true, completion: nil)
        }
    }
    
    //MARK: - goToHonor 명예의 전당으로 가는 Notification
    @objc func showHonor(){
        
        let Storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let HonorVC = Storyboard.instantiateViewController(identifier: "Main") as? UITabBarController else { return }
        HonorVC.modalPresentationStyle = .fullScreen
        HonorVC.selectedIndex = 1
        DispatchQueue.main.async {
            self.present(HonorVC,animated: true,completion: nil)
        }
        
        
        
    }
    //MARK: - ButtonAction Method
    
    func onceClickedDay(){
        successButton.backgroundColor = UIColor(red: 208/255, green: 214/255, blue: 221/255, alpha: 1)
        successButton.setTitle("습관 실행 완료!", for: .normal)
        successButton.setTitleColor(UIColor(red: 178/255, green: 185/255, blue: 194/255, alpha: 1), for: .normal)
    }
    
    // MARK:  changeButtonImage (Button이미지 변경)
    func changeButtonImage(_ dayCount : Int){
        
        let stampCount = dayCount % 10
        
        stampArray[stampCount].tintColor = UIColor(named: "StampColor")
        stampArray[stampCount].setImage(UIImage(named: "stamp.active")?.withRenderingMode(.automatic), for: .normal)
        
        
    }
    
    // MARK: - @IBAction Method
    //MARK: clickSuccessButton ( 성공버튼 클릭 액션 )
    
    @IBAction func clickSuccessButton(_ sender: UIButton) {
        
        // 버튼입력일자가 하루 지났을 떄.
        if (timeManager.compareDate(clickedTime) || self.dayCount == 0  ){
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
    
    
    func initStamp(){
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
        checkVCTitle.font = UIFont(name: "IMHyemin-Bold", size: 20)
        
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
    
    //MARK: 디데이,성공횟수, 확인문구 설정
    func setDdayLabelSuccessLabel(){
        
        // D-Day
        dDayLabel.text = "D-\(dDayInt)"
        dDayLabel.textColor = UIColor(named: "textFontColor")
        dDayLabel.layer.cornerRadius =  dDayLabel.frame.size.height / 2
        dDayLabel.clipsToBounds = true
        dDayLabel.font = UIFont(name: "Baloo", size: 16)
        
        
        //성공횟수
        successLabel.text = "\(dayCount) 회"
        successLabel.textColor = UIColor(named: "textFontColor")
        successLabel.font = UIFont(name: "IM_Hyemin", size: 17)
        
        
        // 확인문구
        
        successText.text = "\(dayCount)일째에요. \n 오늘 하루 습관을 실행하셨다면 아래 버튼을 눌러주세요!"
        successText.font = UIFont(name: "IM_Hyemin", size: 14)
        successText.textColor = UIColor(named: "textFontColor")
        
        let attributtedString = NSMutableAttributedString(string: successText.text!)
        attributtedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "StampColor")!, range: (successText.text! as NSString).range(of:"\(dayCount)"))
        attributtedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name:"IMHyemin-Bold",size: 15)!, range: (successText.text! as NSString).range(of:"\(dayCount)"))
        
        successText.attributedText = attributtedString
        // 크기가 변경 될 수 도 있으니까
        successText.adjustsFontSizeToFitWidth = true
        
    }
    
    
    //MARK: 10일간격으로 초기화
    func tenCycle(dayCount : Int){
        let goToSuccessInt = dayCount / 10 + 1// 0,1,2,3,4,5,6
        goToSuccess.textColor = UIColor(named: "textFontColor")
        goToSuccess.font = UIFont(name: "IMHyemin-Bold", size: 18)
        
        if goToSuccessInt < 7{
            goToSuccess.text = "\(goToSuccessInt)0일을 향해 !"
        }
        //60일 이후엔 66일을향해
        else{
            goToSuccess.text = "\(goToSuccessInt-1)6일을 향해 !"
        }
        
        if dayCount % 10 == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.initStamp()
            }
        }
    }
    
    //MARK: 66일로 도는 사이클의 percentage Label
    func setPercentageLabel(dayCount : Int){
        let percent = dayCount % 66
        let initPercent : Float = Float(dayCount) / 66.0
        let multiPercent = initPercent * 100
        let percent1 = Int(multiPercent) % 100
        let result = floor(Double(percent1))
        percentLabel.font = UIFont(name: "Baloo", size: 20)
        
        
        if percent == 0, dayCount != 0 {
            self.percentLabel.text = " 100 % "
        }
        else{
            percentLabel.textColor = UIColor(named: "StampColor")
            self.percentLabel.text = "\(Int(result))% "
        }
    }
    
    
    //MARK: success버튼 설정
    func successUI(){
        successButton.titleLabel?.font = UIFont(name: "IMHyemin-Bold", size: 18)
        successButton.layer.cornerRadius = 16
        successButton.layer.shadowColor = UIColor(red: 188/255, green: 188/255, blue: 34/255, alpha: 0.4).cgColor
        successButton.layer.shadowOpacity = 1.0
        successButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        successButton.layer.shadowRadius = 10
        
        // CompareDate(클릭했던 시간을 넘겨줘야됨)
        if timeManager.compareDate(clickedTime) || self.dayCount == 0  {
            successButton.backgroundColor = UIColor(named: "ButtonColor")
            successButton.setTitle("내가 해냄! 😎", for: .normal)
            successButton.setTitleColor(UIColor.black, for: .normal)
        }
        else {
            print("successUI - onceClickedDay() called")
            onceClickedDay()
        }
    }
    // 상당과 하단 UI 설정 ( 테두리 )
    func setStackViewColor(){
        
        
        titleSVTopView.backgroundColor = UIColor(named: "ButtonColor")
        titleSVTopView.trailingAnchor.constraint(equalTo: titleSVTop.trailingAnchor).isActive = true
        titleSVTopView.translatesAutoresizingMaskIntoConstraints = false
        
        titleStackView.layer.cornerRadius = 16
        titleStackView.layer.borderWidth = 2
        titleStackView.layer.borderColor = UIColor(named: "ButtonColor")?.cgColor
        
        //titleView 위부분 색 넣기
        titleSVTop.backgroundColor = UIColor(named: "ButtonColor")
        titleSVTop.clipsToBounds = true
        titleSVTop.layer.cornerRadius = 16
        titleSVTop.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        
        
        // stampCheckView설정
        stampView.layer.cornerRadius = 16
        stampView.layer.borderWidth = 2
        stampView.layer.borderColor = UIColor(named: "ButtonColor")?.cgColor
    }
}



