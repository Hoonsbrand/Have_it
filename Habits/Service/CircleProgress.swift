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
    
    var progressColor = MyColor.pink {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    var trackColor = MyColor.pink.withAlphaComponent(0.5) {
        didSet {
            trackLayer.strokeColor = trackColor.withAlphaComponent(0.3).cgColor
        }
    }
    
    
    
    
    //MARK: - 프로그래스바 설정 색 and 초기 설정
    fileprivate func setProgress(){
        
        print("createProgress")
        
        let center = self.center
        let radius = self.frame.size.width * 0.5 - 8
        let circularPath = UIBezierPath(arcCenter: center , radius: radius, startAngle: -CGFloat.pi * 0.5, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 17
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        self.layer.addSublayer(trackLayer)
        
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 17
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        
        progressLayer.strokeEnd = 0.01
        
        self.layer.addSublayer(progressLayer)
        
        
    }
    
    // 프로그래스바 색칠하기
    
    func filleProgress(fromValue : CGFloat, toValue : CGFloat){
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.5
        animation.fromValue = fromValue * 0.1
        animation.toValue = toValue * 0.1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = toValue * 0.1
        progressLayer.add(animation, forKey: "animateprogress")
        
    }
    
    
}

