//
//  CardPreviewTableViewCell.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/23.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

class CardPreviewTableViewCell: UITableViewCell {
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - Variables
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    var card: Card! {
        didSet {
            frontTextLabel.text = card.frontText
            backTextLabel.text = card.backText
        }
    }
    
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // MARK: - IBOutlets
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    @IBOutlet weak var frontTextLabel: UILabel!
    @IBOutlet weak var backTextLabel: UILabel!
}
