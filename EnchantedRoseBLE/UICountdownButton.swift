//
//  UICountdownButton.swift
//  EnchantedRoseBLE
//
//  Created by Steve Murch on 3/8/18.
//  Copyright © 2018 Steve Murch. All rights reserved.
//

import UIKit

class UICountdownButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        
       let originalText = self.title(for: .normal)
        
        
        
        //sleep(1000)
        self.setTitle("Dropping...", for:.normal)
        //sleep(1000)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
            self.setTitle("working...", for:.normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
                self.setTitle("complete!", for:.normal)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
                   
                    self.setTitle(originalText, for:.normal)
                    
                    
                    
                    
                }
                
            }
            
        }
        
        
    }

}
