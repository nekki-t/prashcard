//
//  PrashCardNavigationBar.swift
//  PrashCard
//
//  Created by nekki t on 2016/08/23.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

class PrashCardNavigationBar: UINavigationBar {

    override func sizeThatFits(size: CGSize) -> CGSize {
        
        let oldSize:CGSize = super.sizeThatFits(size)
        let newSize:CGSize = CGSizeMake(oldSize.width, 80)
        return newSize
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view: UIView in self.subviews {
            if(NSStringFromClass(view.dynamicType) == "UIImageView") {
               
                view.frame.origin.y = 15
            }
        }
    }

}
