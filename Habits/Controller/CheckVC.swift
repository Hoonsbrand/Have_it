import UIKit
import RealmSwift
import Toast_Swift

class CheckVC: UIViewController {
    
    
    @IBOutlet weak var myProgress: CircleProgress!
    @IBOutlet weak var successButton: UIButton!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var dDayTitleLabel: UILabel!{
        didSet{
            setDday()
        }
    }
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    
    var btnArr : [UIButton] = []
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
        getRealmData()
        makeButton()
        makeButtonLayout(btnArr)
        setButtonImage(self.dayCount)
        setHabitTitle()
        setDdayLabelSuccessLabel()
        filterCycle(dayCount: self.dayCount)
        setPercentageLabel(dayCount: self.dayCount)
        
        self.myProgress.layer.cornerRadius = 20
        self.myView.layer.cornerRadius = 20
        self.myProgress.backgroundColor = .lightGray
        
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
        let completeAlertAction = UIAlertAction(title: "완료", style: .default){
            (action) in
            self.changeButtonImage(count)
            self.dayCount += 1
            self.resetSuccessButton()
            self.setRealmDate()
            let elevenDayCount = count % 11
            self.myProgress.filleProgress(fromValue: CGFloat(elevenDayCount) - 1.0 , toValue: CGFloat(elevenDayCount))
            self.setDdayLabelSuccessLabel()
            self.filterCycle(dayCount: self.dayCount)
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
        let filterCycle = dayCount % 11
        let count = filterCycle % 10
        btnArr[count].setImage(UIImage(systemName: "flame.fill"), for: .normal)
    }
    
// MARK: - @IBAction Method
    //MARK: clickSuccessButton ( 성공버튼 클릭 액션 )
    
    @IBAction func clickSuccessButton(_ sender: UIButton) {
        resetSuccessButton()
        filterCycle(dayCount: self.dayCount)
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
//        self.navigationItem.title = habitTitle
        
    }
    
    
    //MARK:  CheckVCTitle 설정
    func setDday(){
        
        dDayTitleLabel.text = resultRealm?.title
        dDayTitleLabel.textColor = UIColor(named: "textFontColor")
        dDayTitleLabel.font = UIFont(name: "LeeSeoyun", size: 30)
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
            self.myView.addSubview(btn)
            btn.setImage(UIImage(systemName: "flame"), for: .normal)
            btn.setTitle("", for: .normal)
            
            btnArr.append(btn)
            
        }
    }
    
    func makeButtonLayout(_ btnArray : [UIButton]){
        for btn in btnArray{
            let index = btn.tag
            
            let column = index % 5
            let row = index / 5
            
            let width = self.myView.frame.size.width / 5
            let height = self.myView.frame.size.height / 2
            
            
            btn.frame = CGRect(x: CGFloat(column) * width, y: CGFloat(row) * height, width: width, height: height)
            
        }
    }
    
    //MARK: - 이전에 달성한 습관 횟수 버튼에 구현
    func setButtonImage(_ count : Int){
        let filterCylce = count % 11
        let tenCount = filterCylce % 10
        for tenCount in 0..<tenCount{
            // 10 개의 배열일 경우로 초기화
            changeButtonImage(tenCount)
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
    //MARK: 디데이,성공횟수 라벨 설정
    func setDdayLabelSuccessLabel(){
        self.dDayLabel.text = "D - \(dDayInt)"
        dDayLabel.textColor = UIColor(named: "textFontColor")
        dDayLabel.font = UIFont(name: "LeeSeoyun", size: 30)
        self.successLabel.text = "\(dayCount) 회"
        successLabel.textColor = UIColor(named: "textFontColor")
        successLabel.font = UIFont(name: "LeeSeoyun", size: 30)
    }
    //MARK: 11일로 도는 사이클의 percentage Label
    func setPercentageLabel(dayCount : Int){
        let hundred = dayCount / 11
        let percent = dayCount % 11
       print(hundred)
        let initPercent : Float = Float(dayCount) / 11.0
        let multiPercent = initPercent * 100
        let percent1 = Int(multiPercent) % 100
        let result = floor(Double(percent1))
   
        
        if hundred > 0, percent == 0 {
            self.percentLabel.text = " 100 % "
        }
        else{
            self.percentLabel.text = "\(Int(result))% "
        }
    }
    
    func filterCycle(dayCount : Int){
        let result = dayCount / 11
        switch result {
        case 0 :
            self.myProgress.trackColor = MyColor.pink
            self.myProgress.progressColor = MyColor.pink.withAlphaComponent(0.3)
            
        case 1:
            self.myProgress.trackColor = MyColor.orange
            self.myProgress.progressColor = MyColor.orange.withAlphaComponent(0.3)
        case 2:
            self.myProgress.trackColor = MyColor.yellow
            self.myProgress.progressColor = MyColor.yellow.withAlphaComponent(0.3)
        case 3:
            self.myProgress.trackColor = MyColor.green
            self.myProgress.progressColor = MyColor.green.withAlphaComponent(0.3)
        case 4:
            self.myProgress.trackColor = MyColor.sky
            self.myProgress.progressColor = MyColor.sky.withAlphaComponent(0.3)
        case 5:
            self.myProgress.trackColor = MyColor.blue
            self.myProgress.progressColor = MyColor.blue.withAlphaComponent(0.3)
        case 6:
            self.myProgress.trackColor = MyColor.puple
            self.myProgress.progressColor = MyColor.puple.withAlphaComponent(0.3)
        default :
            self.myProgress.trackColor = MyColor.pink
            self.myProgress.progressColor = MyColor.pink.withAlphaComponent(0.3)
        }
    }
    
}
