//
//  PItchViewController.swift
//  Fling Swift
//
//  Created by Chris Parrish on 5/2/15.
//  Copyright (c) 2015 Chris Parrish. All rights reserved.
//

import UIKit

class PItchViewController: UIViewController, UIDynamicAnimatorDelegate {

    private lazy var animator: UIDynamicAnimator = self.initAnimator()
    private lazy var gravityBehavior: UIGravityBehavior = self.initGravityBehavior()
    private lazy var fieldCollisionBehavior: UICollisionBehavior = self.initFieldCollisionBehavior()
    private lazy var tokenCollisionBehavior: UICollisionBehavior = self.initTokenCollisionBehavior()
    
    private var dragAttachmentBehavior: UIAttachmentBehavior? = nil
    private var dragStartingPoint: CGPoint = CGPointZero
    
    private var transientBehaviors = [UIDynamicBehavior()]
    
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
        let animator = UIDynamicAnimator(referenceView:self.view)
        animator.delegate = self
        return animator
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

        // Gesture recognizer so we can reset the tokens
        
        let fieldTapRecognizer = UITapGestureRecognizer(target: self, action: "fieldTapped:")
        fieldTapRecognizer.numberOfTapsRequired = 2
        fieldTapRecognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(fieldTapRecognizer)
        
        // Gesture recognizer to snap the tokens into a formation
        
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: "fieldLongTapped:")
        longTapRecognizer.numberOfTouchesRequired = 1
        longTapRecognizer.numberOfTapsRequired = 0
        self.view .addGestureRecognizer(longTapRecognizer)

        fieldTapRecognizer.requireGestureRecognizerToFail(longTapRecognizer)
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
    
    // MARK: - UIDynamicAnimatorDelegate
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {

        println("Animator has paused")
    
        // When the animator comes to a rest, we may need
        // to remove transient behaviors

        self.removeTransientBehaviors()
    }
    
    //MARK: - Behaviors
    
    private func addInitialBehaviors() {
        for tokenView in self.tokenViews {
            self.animator.addBehavior(tokenView.dynamicBehavior)
            // Add a behavior to detect when an item leaves the field to bring it back
            var snapToPoint = tokenView.center
            snapToPoint.y = CGRectGetMaxY(self.view.bounds) - CGRectGetMidY(tokenView.bounds) - 4.0;
            let returnBehavior = ReturnToFieldBehavior(token: tokenView, snapToPoint: snapToPoint)
            self.animator.addBehavior(returnBehavior)
        }
        self.animator.addBehavior(self.tokenCollisionBehavior)
    }
    
    private func addCollectAtBottomBehaviors() {
        self.animator.addBehavior(self.gravityBehavior)
        self.transientBehaviors.append(self.gravityBehavior)
        println("+ Added Gravity Behavior")
        
        self.animator.addBehavior(self.fieldCollisionBehavior)
        self.transientBehaviors.append(self.fieldCollisionBehavior)
        println("+ Added Collision Behavior")
    }
    
    func removeTransientBehaviors() {

        if self.transientBehaviors.count == 0 { return }
        
        println("Removing Transient Behaviors")
        
        for behavior in self.transientBehaviors {
            self.animator.removeBehavior(behavior)
        }
        
        self.transientBehaviors.removeAll(keepCapacity: true)
        
        // Re-add the token collisions if we turned them off for a transient behavior
        if self.tokenCollisionBehavior.dynamicAnimator == nil {
            self.animator .addBehavior(self.tokenCollisionBehavior)
        }
    }
    
    //MARK: - Actions
    
    private func snapTokensToFormation(formation: TokenFormation) {
        println("MOVING INTO FORMATION")
        
        var index = 0
        for tokenView in self.tokenViews {
            let snapBehavior = UISnapBehavior(item: tokenView, snapToPoint: formation.locationForTokenAtIndex(index))
            let damping = 0.5 + CGFloat(rand()) / CGFloat( Double(RAND_MAX) / (1.0 - 0.5) )
            snapBehavior.damping = damping
            
            let maxVelocity = 1000.0
            let xVelocity = -maxVelocity + ( Double(rand()) / (Double(RAND_MAX) / 2.0 * maxVelocity) )
            let yVelocity = -maxVelocity + ( Double(rand()) / (Double(RAND_MAX) / 2.0 * maxVelocity) )

            tokenView.dynamicBehavior.addLinearVelocity(CGPoint(x: xVelocity, y: yVelocity), forItem: tokenView)
            
            //GOTCHA: adding a snap behavior won't necessarily restart a paused animator.
            // adding a little velocity does though!
            
            let angularVelocity = -100.0 + ( Double(rand()) / ( Double(RAND_MAX) / (100.0 - -100.0) ) )
            tokenView.dynamicBehavior.addAngularVelocity(CGFloat(angularVelocity), forItem: tokenView)
            
            self.animator.addBehavior(snapBehavior)
            self.transientBehaviors.append(snapBehavior)
            
            // Remove the token collisions behavior so they don't interfere with each other
            self.animator.removeBehavior(self.tokenCollisionBehavior)
            
            index++
        }
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
            
            self.removeTransientBehaviors()
           
            // apply the velocity of the pan so we can 'fling' the item
            // NOTE:
            //    velocity of the pan isn't always exactly zero when we
            //    might expect it to be. To work around that we'll only
            //    add the velocity if it's magnitude was large enough
            
            let tokenBeingDragged = panRecognizer.view as! TokenView
            let velocity = panRecognizer.velocityInView(self.view)
            
            let magnitude = sqrt( (velocity.x * velocity.x) + (velocity.y * velocity.y) );
            println("Pan ended with velocity: \(velocity)  magnitdue: \(magnitude)")
            
            if magnitude > 100.0 {
                tokenBeingDragged.dynamicBehavior.addLinearVelocity(velocity, forItem:tokenBeingDragged)
            }
            
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
    
    
    func fieldTapped(recognizer: UITapGestureRecognizer) {
        // Resest the tokens to the bottom
        self.addCollectAtBottomBehaviors()
    }
    
    func fieldLongTapped(recognizer: UIGestureRecognizer) {

        if recognizer.state == UIGestureRecognizerState.Began {
            // put everyting in a 4 4 2 formation
            let formation = TokenFormation.formationWithFourFourTwo()
            self.snapTokensToFormation(formation)
        }
    }
    
    //MARK: - Debug
    
    func logTokenPositions() {
        for tokenView in self.tokenViews {
            println("LOCATION: \(tokenView.center)")
        }
    }
}
