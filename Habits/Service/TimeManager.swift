//
//  TimeManager.swift
//  Habits
//
//  Created by 안지훈 on 8/5/22.
//

import Foundation
import UIKit


class TimeManager {
    
    // MARK: D-day 계산 (66일)
    func getDday(_ creatTime : Date) -> Date{
        
        if let dDay = Calendar.current.date(byAdding: .day, value: 66, to: creatTime) {
            return dDay
        }
        return Date()
    }
    
    // 이전에 습관완료를 누른 날짜와 차이 계산. (date와 현재의 날짜 차이)
    func calDateDiffer(_ first : Date, _ second : Date) -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let firstTimeToString = dateFormatter.string(from: first)
        let secondTimeToString = dateFormatter.string(from: second)
        
        guard let firstTime = dateFormatter.date(from: firstTimeToString) else { return 0 }
        guard let secondeTime = dateFormatter.date(from: secondTimeToString ) else { return  0 }
        
        //현재날짜와 과거날짜의 차이를 구하고 / 86400초로 나눔
        let interval = firstTime.timeIntervalSince(secondeTime)
        let differenceDays =  Int(interval / 86400)
        
        print(" 날짜 차이 : \(differenceDays) ")
        return differenceDays
        
    }
    //MARK: - 현재 날짜(day)가 습관완료를 한 날짜보다 큰지 ( 다음 날인지 ) // 단순히 날짜만 비교
    func compareDate(_ date : Date) -> Bool {
        let currentTime = Calendar.current.dateComponents([.year , .month, .day], from: Date())
        let pastTime = Calendar.current.dateComponents([.year , .month, .day], from: date)
        
        if ( currentTime.year! > pastTime.year! || currentTime.month! > pastTime.month! ||  currentTime.day! > pastTime.day!){
            
            return true
        } else { return false }
    }
}
