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
    
    private lazy var tokenViews: [TokenView] = {
            let tokenLabels = ["1", "2", "3", "4", "5", "6̲", "7", "8", "9̲", "10", "11"]
            
            var tokens = [TokenView]()
            for labelString in tokenLabels {
                let tokenView = TokenView(label: labelString)
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
    
    func addInitialBehaviors() {
        for tokenView in self.tokenViews {
            self.animator.addBehavior(tokenView.dynamicBehavior)
        }
        self.animator.addBehavior(self.tokenCollisionBehavior)
    }
    
    func addCollectAtBottomBehaviors() {
        self.animator.addBehavior(self.gravityBehavior)
        println("+ Added Gravity Behavior")
        self.animator.addBehavior(self.fieldCollisionBehavior)
        println("+ Added Collision Behavior")
    }
    
    //MARK: - Debug
    
    func logTokenPositions() {
        for tokenView in self.tokenViews {
            println("LOCATION: \(tokenView.center)")
        }
    }
}
