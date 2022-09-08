//
//  ListHomeLogic.swift
//  Have it
//
//  Created by hoonsbrand on 2022/09/08.
//

import UIKit

struct ListHomeLogic {
    
    var titleFont: UIFont?
    var subTitleFont: UIFont?
    var titleText: String?
    var subTitleText: String?
    
    var attributeTitleString: NSMutableAttributedString?
    var attributeSubTitleString: NSMutableAttributedString?
    
    mutating func setAlertFont() {
        // 폰트 지정
        titleFont = UIFont(name: CustomFont.hyemin_Bold, size: 16)
        subTitleFont = UIFont(name: CustomFont.hyemin, size: 12)
        
        // 텍스트 지정
        titleText = ListHomeLabel.wantToPauseLabel
        subTitleText = ListHomeLabel.wantToPauseSubLabel
        
        // 특정 문자열로 지정
        attributeTitleString = NSMutableAttributedString(string: titleText!)
        attributeSubTitleString = NSMutableAttributedString(string: subTitleText!)
        
        // 위에서 지정한 특정 문자열에 폰트 지정
        attributeTitleString!.addAttribute(.font, value: titleFont!, range: (titleText! as NSString).range(of: "\(titleText!)"))
        attributeSubTitleString!.addAttribute(.font, value: subTitleFont!, range: (subTitleText! as NSString).range(of: "\(subTitleText!)"))
    }
    
    func getTitleFont() -> UIFont? {
        return titleFont
    }
    
    func getSubTitleFont() -> UIFont? {
        return subTitleFont
    }
    
    func getTitleText() -> String? {
        return titleText
    }
    
    func getSubTitleText() -> String? {
        return subTitleText
    }
    
    func getAttributeTitleString() -> NSMutableAttributedString? {
        return attributeTitleString
    }
    
    func getAttributeSubTitleString() -> NSMutableAttributedString? {
        return attributeSubTitleString
    }
}
