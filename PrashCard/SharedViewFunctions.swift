//
//  SharedViewFunctions.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/23.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
import UIKit
class SharedViewFunctions {
    class func setShadow (layer: CALayer) {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 1.1, height: 1.1)
        layer.shadowOpacity = 1
    }
}
