//
//  SortSetting.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/22.
//  Copyright © 2016年 next3. All rights reserved.
//

import Foundation
struct TargetSetting {
    var idx: Int!
    var title: String!
    var selected: Bool
    static let settingWhite = "White"
    static let settingRed = "Red"
    static let settingYellow = "Yellow"
    static let setttingGreen = "Green"
    
    static func getTargets () -> [TargetSetting] {
        
        var targetItems:[String] = [
            TargetSetting.settingWhite,
            TargetSetting.settingRed,
            TargetSetting.settingYellow,
            TargetSetting.setttingGreen
        ]
        var results = [TargetSetting]()
        var target: TargetSetting
        for i in (0 ..< targetItems.count) {
            target = TargetSetting(idx: i, title: targetItems[i], selected: true)
            results.append(target)
        }
        
        return results
    }
    
    static func getTargetSetting (targets: [TargetSetting], levelString: String) -> TargetSetting {
        var targetSetting: TargetSetting!
        for target in targets {
            if target.title == levelString {
                targetSetting = target
            }
        }
        return targetSetting
    }
}
