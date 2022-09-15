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
    @IBOutlet weak var descriptionTextTopAnchor: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    
    func configureUI() {
        
        haveItTopAnchor.constant = 260
        
        UIView.animate(withDuration: 2.0, animations: {
            self.view.layoutIfNeeded()
            self.haveItView.alpha = 0.0
            
        }, completion: { _ in
            self.descriptionTextTopAnchor.constant = 112
            
            UIView.animate(withDuration: 2.0, animations: {
                self.view.layoutIfNeeded()
            })
        })
    }
    
    
    
}
