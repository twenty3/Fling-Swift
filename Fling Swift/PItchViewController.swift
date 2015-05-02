//
//  PItchViewController.swift
//  Fling Swift
//
//  Created by Chris Parrish on 5/2/15.
//  Copyright (c) 2015 Chris Parrish. All rights reserved.
//

import UIKit

class PItchViewController: UIViewController {

    private lazy var tokenViews: [UIView] = {
            let tokenLabels = ["1", "2", "3", "4", "5", "6̲", "7", "8", "9̲", "10", "11"]
            
            var tokens = [UIView]()
            for labelString in tokenLabels {
                let tokenView = TokenView(label: labelString)
                tokens.append(tokenView)
            }
            
            return tokens
        }()
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDynamicTokensToView()
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
    
    //MARK: - Debug
    
    func logTokenPositions() {
        for tokenView in self.tokenViews {
            println("LOCATION: \(tokenView.center)")
        }
    }
}
