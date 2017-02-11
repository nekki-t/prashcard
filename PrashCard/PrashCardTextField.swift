//
//  PrashCardTextField.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/23.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

class PrashCardTextField : UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
