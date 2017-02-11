//
//  DropBehavior.swift
//  PrashCard
//
//  Created by nekki t on 2016/09/30.
//  Copyright © 2016年 next3. All rights reserved.
//
import UIKit
class DropBehavior: UIDynamicBehavior
{
    let gravity = UIGravityBehavior()
    lazy var dropBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedDropBehavior = UIDynamicItemBehavior()
        lazilyCreatedDropBehavior.allowsRotation = true
        lazilyCreatedDropBehavior.elasticity = 0.75
        return lazilyCreatedDropBehavior
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(dropBehavior)
    }
    
    func addDrop(drop: UIView) {
        dynamicAnimator?.referenceView?.addSubview(drop)
        gravity.addItem(drop)
        dropBehavior.addItem(drop)
    }
    
    func removeDrop(drop: UIView) {
        gravity.removeItem(drop)
        dropBehavior.removeItem(drop)
        drop.removeFromSuperview()
    }
}
