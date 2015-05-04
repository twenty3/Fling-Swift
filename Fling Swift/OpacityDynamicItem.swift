//
//  OpacityDynamicItem.swift
//  Fling Swift
//
//  Created by Chris Parrish on 5/3/15.
//  Copyright (c) 2015 Chris Parrish. All rights reserved.
//

import UIKit

class OpacityDynamicItem: NSObject, UIDynamicItem {

    weak var view: UIView?
    lazy var dynamicItemBehavior: UIDynamicItemBehavior = self.initDynamicItemBehavior()

    init(view: UIView) {
        
        self.view = view
        super.init()
    }
    
    //MARK: - Private 
    
    func initDynamicItemBehavior() -> UIDynamicItemBehavior {
        let dynamicItemBehavior = UIDynamicItemBehavior(items: [self])
        dynamicItemBehavior.resistance = 1.0
        dynamicItemBehavior.density = 10000.0
        return dynamicItemBehavior
    }
    
    var bounds: CGRect {
        return CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
    }
    
    var center: CGPoint {
        get {
            if let view = self.view {
                return CGPoint(x: view.alpha, y: view.alpha)
            }
            return CGPointZero
        }
        set(center) {
            if let view = self.view {
                view.alpha = center.x
            }
        }
    }
    
    var transform: CGAffineTransform {
        get {
            return CGAffineTransformIdentity
        }
        set {
            
        }
    }
    
}



