//
//  TutorialViewController.swift
//  Have it
//
//  Created by hoonsbrand on 2022/09/15.
//

import UIKit

class TutorialViewController: UIViewController {


    @IBOutlet weak var haveItView: UIView!
    @IBOutlet weak var haveItTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var haveItLabel: UILabel!
    @IBOutlet weak var haveItLabelTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var exampleScrollView: UIScrollView!
    
    // MARK: - label 코드로 설정
    private lazy var exampleLabel: UILabel = {
        let label = UILabel()
        label.text = "아래 예시 중에서\n시작하고 싶은 습관이 있으시다면 선택해주세요.\n나중에 수정 가능하니 비슷한 느낌의 습관을\n선택하셔도 무방해요."
        label.font = UIFont(name: CustomFont.hyemin_Bold, size: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.63
        label.attributedText = NSMutableAttributedString(string: "아래 예시 중에서\n시작하고 싶은 습관이 있으시다면 선택해주세요.\n나중에 수정 가능하니 비슷한 느낌의 습관을\n선택하셔도 무방해요.", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
        label.textAlignment = .center
        label.alpha = 0
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    
    // MARK: - UI구성
    func configureUI() {
        exampleScrollView.alpha = 0
        exampleScrollView.isHidden = true
        haveItTopAnchor.constant = 297
        
        UIView.animate(withDuration: 1, animations: {
            self.haveItView.alpha = 1
            self.view.layoutIfNeeded()
            
        }, completion: { [weak self] _ in
            guard let self = self else { return }
                    
            UIView.animate(withDuration: 1, animations: {
                self.haveItLabel.alpha = 1
                
            }, completion: { _ in
                self.haveItTopAnchor.constant = 0
                self.haveItLabelTopAnchor.constant = 112
                
                UIView.animate(withDuration: 1, animations: {
                    self.haveItView.alpha = 0
                    self.view.layoutIfNeeded()
                    
                }, completion: { _ in
                    let label = self.exampleLabel
                    
                    self.view.addSubview(label)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.widthAnchor.constraint(equalToConstant: 318).isActive = true
                    label.heightAnchor.constraint(equalToConstant: 128).isActive = true
                    label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                    label.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 216).isActive = true
                    
                    UIView.animate(withDuration: 1, animations: {
                        label.alpha = 1
                        
                    }, completion: { _ in
                        self.exampleScrollView.isHidden = false
                        
                        UIView.animate(withDuration: 1, animations: {
                            self.exampleScrollView.alpha = 1
                        })
                    })
                })
            })
        })
    }
    
    // MARK: - 각 버튼 클릭 시 toggle()을 이용해 버튼의 상태를 selected로 변경 -> 이미지도 자동으로 변경 됨.
    @IBAction func firstBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func secondBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func thirdBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func fourthBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @IBAction func lastBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
}
