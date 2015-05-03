//
//  PItchViewController.swift
//  Fling Swift
//
//  Created by Chris Parrish on 5/2/15.
//  Copyright (c) 2015 Chris Parrish. All rights reserved.
//

import UIKit

class PItchViewController: UIViewController {

    private lazy var animator: UIDynamicAnimator = self.initAnimator()
    private lazy var gravityBehavior: UIGravityBehavior = self.initGravityBehavior()
    private lazy var fieldCollisionBehavior: UICollisionBehavior = self.initFieldCollisionBehavior()
    private lazy var tokenCollisionBehavior: UICollisionBehavior = self.initTokenCollisionBehavior()
    
    private var dragAttachmentBehavior: UIAttachmentBehavior? = nil
    private var dragStartingPoint: CGPoint = CGPointZero
    
    private lazy var tokenViews: [TokenView] = {
            let tokenLabels = ["1", "2", "3", "4", "5", "6̲", "7", "8", "9̲", "10", "11"]
            
            var tokens = [TokenView]()
            for labelString in tokenLabels {
                let tokenView = TokenView(label: labelString)
                
                let dragRecognizer = UIPanGestureRecognizer(target: self, action: "tokenDidPan:")
                tokenView.addGestureRecognizer(dragRecognizer)
                
                tokens.append(tokenView)
            }
            
            return tokens
        }()

    // lazy initialization for variables with with depenency on 'self'
    private func initAnimator() -> UIDynamicAnimator {
        return UIDynamicAnimator(referenceView:self.view)
    }
    
    private func initGravityBehavior() -> UIGravityBehavior {
        let gravityBehavior = UIGravityBehavior(items: self.tokenViews)
        gravityBehavior.magnitude = 10.0
        return gravityBehavior
    }
    
    private func initFieldCollisionBehavior() -> UICollisionBehavior {
        let fieldCollisionBehavior =  UICollisionBehavior(items: self.tokenViews)
        fieldCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
        fieldCollisionBehavior.collisionMode = UICollisionBehaviorMode.Boundaries
        return fieldCollisionBehavior
    }
    
    private func initTokenCollisionBehavior() -> UICollisionBehavior {
        let tokenCollisionBehavior = UICollisionBehavior(items: self.tokenViews)
        tokenCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
        tokenCollisionBehavior.collisionMode = UICollisionBehaviorMode.Items
        return tokenCollisionBehavior
    }
    
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDynamicTokensToView()
    }

    override func viewDidAppear(animated: Bool) {
        self.addInitialBehaviors()
        
        // When we first appear, use gravity to drop all the tokens
        // and a collision boundary to contain them at the bottom
        self.addCollectAtBottomBehaviors()
    }
    
    //MARK: - Tokens
    
    private func addDynamicTokensToView() {
     
        let minX = CGRectGetMinX(self.view.bounds) + 50.0
        let maxX = CGRectGetMaxX(self.view.bounds) - 50.0
        let xRange = maxX - minX
        let minY = CGRectGetMinY(self.view.bounds) + 50.0
        let maxY = CGRectGetMidY(self.view.bounds)
        let yRange = maxY - minY
        
        srand(UInt32(NSDate.timeIntervalSinceReferenceDate()));

        for tokenView in self.tokenViews {
            let x = minX + (xRange * CGFloat(rand()) / CGFloat(RAND_MAX))
            let y = minY + (yRange * CGFloat(rand()) / CGFloat(RAND_MAX))
            
            tokenView.center = CGPoint(x: x, y: y)
            self.view.addSubview(tokenView)
        }
    }
    
    //MARK: - Behaviors
    
    private func addInitialBehaviors() {
        for tokenView in self.tokenViews {
            self.animator.addBehavior(tokenView.dynamicBehavior)
        }
        self.animator.addBehavior(self.tokenCollisionBehavior)
    }
    
    private func addCollectAtBottomBehaviors() {
        self.animator.addBehavior(self.gravityBehavior)
        println("+ Added Gravity Behavior")
        self.animator.addBehavior(self.fieldCollisionBehavior)
        println("+ Added Collision Behavior")
    }
    
    func tokenDidPan(panRecognizer: UIPanGestureRecognizer)
    {
        // We'll only add the attachment for dragging, when a drag starts
        // otherwise the attachment will hold the item in place even
        // when we are not moving it.
        if panRecognizer.state == UIGestureRecognizerState.Began {
            
            let viewToDrag = panRecognizer.view as! TokenView

            // We'll add the attachment at the center of the view
            // and use the delta during each pan gesture update to adjust the attachment location
            // Using the center will keep the view from rotating around the touched point
            self.dragStartingPoint = viewToDrag.center
            self.dragAttachmentBehavior = UIAttachmentBehavior(item: viewToDrag, attachedToAnchor: viewToDrag.center)
            self.animator.addBehavior(self.dragAttachmentBehavior)
        }
        else if panRecognizer.state == UIGestureRecognizerState.Ended {
            self.dragStartingPoint = CGPointZero;
            self.animator.removeBehavior(self.dragAttachmentBehavior)
            self.dragAttachmentBehavior = nil
        }
        else if panRecognizer.state == UIGestureRecognizerState.Changed {
            // apply the change in the pan recognizer position (cumulative) to the
            // the starring part to move our token
            
            // NOTE: if we do the clever trick of reseting the pan recognizer's
            // translation to zero here, it will reset the velocity!
            let delta = panRecognizer.translationInView(self.view)
            let newPoint = CGPoint(x: self.dragStartingPoint.x + delta.x, y: self.dragStartingPoint.y + delta.y)
            if let dragAttachmentBehavior = self.dragAttachmentBehavior {
                dragAttachmentBehavior.anchorPoint = newPoint
            }
        }
    }
    
    //MARK: - Debug
    
    func logTokenPositions() {
        for tokenView in self.tokenViews {
            println("LOCATION: \(tokenView.center)")
        }
    }
}
