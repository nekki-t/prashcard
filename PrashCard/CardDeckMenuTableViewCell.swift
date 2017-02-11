//
//  CardDeckMenuTableViewCell.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/22.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

class CardDeckMenuTableViewCell: UITableViewCell {
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Variables
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    var checked = false
    var targetSetting: TargetSetting?  {
        didSet {
            title.text = targetSetting?.title
            if let setting = targetSetting {
                if setting.selected {
                    checkMark.image = UIImage(named: "checkOn")
                } else {
                    checkMark.image = UIImage(named: "checkOff")
                }
            }
        }
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBOutlets
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var checkMark: UIImageView!
    

    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Functions called externally
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    func hideCheckMark () {
        checkMark.hidden = true
    }
}
