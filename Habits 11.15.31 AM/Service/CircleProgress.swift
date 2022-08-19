//
//  CircleProgress.swift
//  Habits
//
//  Created by 안지훈 on 8/9/22.
//


import UIKit

class CircleProgress : UIView {
    
    fileprivate let progressLayer = CAShapeLayer()
    fileprivate let trackLayer = CAShapeLayer()
    
    
    override init(frame : CGRect){
        super.init(frame: frame)
        print("init")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // IBoutlet으로 Init? 선언
        self.frame.origin.x = 0
        self.frame.origin.y = 0
        setProgress()
        
    }
    
    
    
    var progressColor =  UIColor(named: "ProgressBackgroundColor") {
        didSet {
            progressLayer.strokeColor = progressColor?.cgColor
        }
    }
    var trackColor = UIColor(named: "ProgressBackgroundColor") {
        didSet {
            trackLayer.strokeColor = trackColor?.cgColor
        }
    }
    
    
    
    
    //MARK: - 프로그래스바 설정 색 and 초기 설정
    fileprivate func setProgress(){
        
        print("createProgress")
        
        let center = self.center
        let radius = (min(self.frame.size.width, self.frame.size.height) - 10) / 2
        let circularPath = UIBezierPath(arcCenter: center , radius: radius, startAngle: -CGFloat.pi * 0.5, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = trackColor?.cgColor
        trackLayer.lineWidth = 8
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        self.layer.addSublayer(trackLayer)
        
        
        progressLayer.path = circularPath.cgPath
        
        progressLayer.strokeColor = progressColor?.cgColor
        progressLayer.lineWidth = 8
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        
        progressLayer.strokeEnd = 0.01
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        
        gradientLayer.colors = [UIColor(named: "PgStartColor")?.cgColor ?? UIColor.red.cgColor,UIColor(named: "PgEndColor")?.cgColor ?? UIColor.systemPink.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.mask = progressLayer
        
        layer.addSublayer(gradientLayer)
        //        self.layer.addSublayer(progressLayer)
        
        
    }
    
    // 프로그래스바 동작
    
    func filleProgress(fromValue : Int, toValue : Int){
        
        let pgFromValue = CGFloat(fromValue) / 66
        let pgToValue = CGFloat(toValue) / 66
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.5
        animation.fromValue = pgFromValue
        animation.toValue = pgToValue
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = pgToValue
        progressLayer.add(animation, forKey: "animateprogress")
        
    }
    
    
}

