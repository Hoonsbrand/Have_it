
//
//  Launch.swift
//  Habits
//
//  Created by 안지훈 on 8/18/22.
//

import UIKit
import Lottie

class Launch : UIViewController{
    
    @IBOutlet weak var lottieView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Launch called ")
        

            //Do your configuration
        
        
        let customAnimationView = AnimationView(name: "Launch")
      
       
        customAnimationView.contentMode = .scaleAspectFit
        customAnimationView.loopMode = .loop
        customAnimationView.backgroundBehavior = .pauseAndRestore
        customAnimationView.animationSpeed = 0.6
        customAnimationView.play()
            
         
    
        customAnimationView.translatesAutoresizingMaskIntoConstraints = false
        self.lottieView.addSubview(customAnimationView)

       
        NSLayoutConstraint.activate([
                    customAnimationView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                    customAnimationView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                    customAnimationView.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 50),
                    customAnimationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
        print(self.lottieView.topAnchor)
        print(view.topAnchor)
    }
    
}
