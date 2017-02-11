//
//  CardDeckTableViewCell.swift
//  PrashCard
//
//  Created by nekki t on 2016/05/27.
//  Copyright © 2016年 next3. All rights reserved.
//

import UIKit

protocol CardDeckTableViewCellDelegate {
    func cardDeckDeleted()
}
class CardDeckTableViewCell: UITableViewCell {

    var viewControllerDelegate: UIViewController?
    var cardDeckTableViewCellDelegate: CardDeckTableViewCellDelegate?
    
    var cardDeck: CardDeck! {
        didSet{
            subContainer.layer.borderColor = UIColor.lightGrayColor().CGColor
            subContainer.layer.borderWidth = 1.0
            subContainer.layer.shadowOffset = CGSizeMake(1, 1)
            subContainer.layer.shadowOpacity = 0.7;
            subContainer.layer.shadowRadius = 1;
            
            nameLabel.text = cardDeck.name
            
            cardCountLabel.text = String(cardDeck.cards!.count)
            challengedTimesLabel.text = String(cardDeck.challengedCount!)
            whiteCountLabel.text = String(cardDeck.whiteCount!)
            redCountLabel.text = String(cardDeck.redCount!)
            yellowCountLabel.text = String(cardDeck.yellowCount!)
            greenCountLabel.text = String(cardDeck.greenCount!)
            masteredRateLabel.text = String(self.cardDeck.getClearedPercentage())
            
            cardsImg.backgroundColor = Training.getColorByLevel(Int(cardDeck.currentLevel!))
            
        }
    }
    
    @IBOutlet weak var cardsImg: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subContainer: UIView!
    @IBOutlet weak var cardCountLabel: UILabel!
    @IBOutlet weak var challengedTimesLabel: UILabel!
    @IBOutlet weak var whiteCountLabel: UILabel!
    @IBOutlet weak var redCountLabel: UILabel!
    @IBOutlet weak var yellowCountLabel: UILabel!
    @IBOutlet weak var greenCountLabel: UILabel!
    @IBOutlet weak var masteredRateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }    
    
    
    @IBAction func deleteButtonTapped(sender: AnyObject) {
        let cancelAlert = UIAlertController(title: "Warning!!", message: "This card deck is completely deleted.\r\nAre you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        cancelAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            CoreDataStackManager.sharedInstance().managedObjectContext!.deleteObject(self.cardDeck)
            CoreDataStackManager.sharedInstance().saveContext()
            self.cardDeckTableViewCellDelegate?.cardDeckDeleted()
            return
        }))
        cancelAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        viewControllerDelegate?.presentViewController(cancelAlert, animated: true, completion: nil)
    }
}

