//
//  AppDelegate.swift
//  PrashCard
//
//  Created by nekki t on 2016/05/05.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        UINavigationBar.appearance().barTintColor = UIColor(red: 58.0/255.0, green: 13.0/255.0, blue: 136.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        return true;
    }
}

