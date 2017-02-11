//
//  Training.swift
//  PrashCard
//
//  Created by nekki t on 2016/05/07.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import Foundation

// Values and Functions for PrashCard Training
public struct Training {
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Level Definition
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    public enum Level: Int {
        case White = 0
        case Red = 1
        case Yellow =  2
        case Green = 3
    }
        
    public enum LevelBorder: Double {
        case Beginner = 0.0
        case Intermediate = 0.4
        case AnotherIntermediate = 0.5
        case Master = 1.0
    }
    
    
    public static let UnselectedMenuItemRedColor: UIColor = UIColor.redColor().colorWithAlphaComponent(0.5)
    public static let UnselectedMenuItemYellowColor: UIColor = UIColor.yellowColor().colorWithAlphaComponent(0.5)
    public static let UnselectedMenuItemGreenColor: UIColor = UIColor.greenColor().colorWithAlphaComponent(0.5)
    
    public static let SelectedMenuItemRedColor: UIColor = UIColor.redColor()
    public static let SelectedMenuItemYellowColor: UIColor = UIColor.yellowColor()
    public static let SelectedMenuItemGreenColor: UIColor = UIColor.greenColor()
    
    static func getUnselectedMenuColors() -> [UIColor]{
        return [UIColor.lightGrayColor(), Training.UnselectedMenuItemRedColor, Training.UnselectedMenuItemYellowColor, Training.UnselectedMenuItemGreenColor]
    }
    static func getSelectedMenuColors() -> [UIColor]{
        return [UIColor.whiteColor(), Training.SelectedMenuItemRedColor, Training.SelectedMenuItemYellowColor, Training.SelectedMenuItemGreenColor]
    }
    
    
    static func getColorByLevel (level: Int) -> UIColor{
        switch level {
        case Level.White.rawValue:
            return UIColor.whiteColor()
        case Level.Red.rawValue:
            return UIColor.redColor()
        case Level.Yellow.rawValue:
            return UIColor.yellowColor()
        case Level.Green.rawValue:
            return UIColor.greenColor()
        default:
            return UIColor.whiteColor()
        }
    }
    
}
