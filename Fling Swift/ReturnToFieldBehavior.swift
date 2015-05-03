//
//  ReturnToFieldBehavior.swift
//  Fling Swift
//
//  Created by Chris Parrish on 5/2/15.
//  Copyright (c) 2015 Chris Parrish. All rights reserved.
//

import UIKit


class ReturnToFieldBehavior: UIDynamicBehavior {
   
    let token: TokenView
    
    private let snapToPoint: CGPoint
    private var snapToBottomBehavior: UISnapBehavior? = nil
    
    init(token: TokenView, snapToPoint: CGPoint) {
        self.token = token
        self.snapToPoint = snapToPoint
        
        super.init()
        
        self.action = {
            // did our item move out of bounds of the reference view?
            let referenceView = self.dynamicAnimator!.referenceView!
            let referenceViewBounds = CGRectInset(referenceView.bounds, 10.0, 10.0)
            // we'll inset the reference bounds just a bit so things aren't impossibly close
            // to the edge to manipulate
            var tokenFrame = self.token.frame
            tokenFrame = referenceView.convertRect(tokenFrame, fromView:self.token.superview)
            
            let isContained = CGRectContainsRect(referenceViewBounds, tokenFrame)
            let doesIntersect = CGRectIntersectsRect(referenceViewBounds, tokenFrame)
            
            if self.snapToBottomBehavior == nil && !isContained && !doesIntersect {
                // the item might have some velocity we need to negate
                // (alternatively the item can be removed from all behaviors
                //  and then re-added)
                
                let itemVelocity = self.token.dynamicBehavior.linearVelocityForItem(self.token)
                
                var counterVelocity = itemVelocity
                counterVelocity.x = -counterVelocity.x
                counterVelocity.y = -counterVelocity.y
                
                self.token.dynamicBehavior.addLinearVelocity(counterVelocity, forItem:self.token)
                
                // Move the token off below the bottom
                
                self.token.center = CGPoint(x: CGRectGetMidX(referenceViewBounds), y: CGRectGetMaxY(referenceViewBounds) + 300.0)
                self.dynamicAnimator!.updateItemUsingCurrentState(self.token)
                
                let snapToBottomBehavior = UISnapBehavior(item: self.token, snapToPoint: self.snapToPoint)
                snapToBottomBehavior.damping = 0.9
                self.addChildBehavior(snapToBottomBehavior)
                self.snapToBottomBehavior = snapToBottomBehavior
            }
            else if let snapToBottomBehavior = self.snapToBottomBehavior {
                let itemVelocity = self.token.dynamicBehavior.linearVelocityForItem(self.token)
                let magnitude = sqrt( (itemVelocity.x * itemVelocity.x) + (itemVelocity.y * itemVelocity.y) );
                
                if magnitude < 0.01 {
                    self.removeChildBehavior(snapToBottomBehavior)
                    self.snapToBottomBehavior = nil
                }
            }
        }
    }
}

