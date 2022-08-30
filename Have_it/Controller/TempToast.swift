//
//  TempToast.swift
//  Have it
//
//  Created by hoonsbrand on 2022/08/30.
//

import Foundation
import Toast_Swift

struct TempToast {
    func showToast(view: UIView, message : String, font: UIFont, ToastWidth: CGFloat, ToasatHeight: CGFloat, yPos: CGFloat = 2, backgroundColor: UIColor = UIColor(red: 0.993, green: 1, blue: 0.646, alpha: 1), textColor: UIColor = .black) {
        
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - (ToastWidth/2), y: view.frame.size.height/yPos, width: ToastWidth, height: ToasatHeight))
        toastLabel.backgroundColor = backgroundColor
        toastLabel.textColor = textColor
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.5 , delay: 1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
