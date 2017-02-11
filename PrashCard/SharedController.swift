//
//  SharedController.swift
//  PrashCard
//
//  Created by nekki t on 2016/05/09.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit
import CoreData

class SharedController {
    // MARK: Common Alert
    class func showAlert(title: String?, message: String?, targetViewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let actionOK = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(actionOK)
        targetViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func showAlert(title: String?, message: String?, targetViewController: UIViewController, completionHandler: () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let actionOK = UIAlertAction(title: "OK", style: .Default, handler:{
            (action: UIAlertAction!) -> Void in
            completionHandler()
        })
        alert.addAction(actionOK)
        targetViewController.presentViewController(alert, animated: true, completion: nil)
    }

    class func saveCSV(csvString: String, exportFileName: String) -> Bool{
        var writeResult = false
        if let dir : NSString = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true ).first {
            
            let pathFileName = dir.stringByAppendingPathComponent(exportFileName)
            
            do {
                try csvString.writeToFile(pathFileName, atomically: false, encoding: NSUTF8StringEncoding)
                writeResult = true
            } catch let err as NSError {
                print(err)
                writeResult = false
            }
        }
        return writeResult
    }
    
    class func loadCSV (fileName: String!) -> [[String]] {
        var result:[[String]] = []
        var failedToOpen = false
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true ).first {
            
            let pathFileName = dir.stringByAppendingPathComponent(fileName)
            var csvArray = []
            
            do {
                let csvData = try String(contentsOfFile: pathFileName, encoding: NSUTF8StringEncoding)
              
                let lineChange = csvData.stringByReplacingOccurrencesOfString("\r", withString: "\n")
                csvArray = lineChange.componentsSeparatedByString("\n")
            } catch {
                failedToOpen = true
            }
            if failedToOpen {
                return result
            }
            
            var idx = 0
            for row in csvArray {
                
                print(idx)
                idx += 1
                
                var arr = row.componentsSeparatedByString("\",\"")
                if arr.count < 1 {
                    break
                } else if arr.count == 1 {
                    if arr[0] == "" {
                        break
                    }
                    result.append([arr[0].chopPrefix(), ""])
                } else {
                    if arr[0] == "" {
                        break
                    }
                    result.append([arr[0].chopPrefix(), arr[1].chopSuffix()])
                }
            }
        }
        return result
    }
    
}

extension String {
    func chopPrefix(count: Int = 1) -> String {
        if self == "" {
            return ""
        } else {
            return self.substringFromIndex(self.startIndex.advancedBy(count))
        }
    }
    
    func chopSuffix(count: Int = 1) -> String {
        if self == "" {
            return ""
        } else {
            return self.substringToIndex(self.endIndex.advancedBy(-count))
        }
    }
}

