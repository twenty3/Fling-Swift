//
//  TokenFormation.swift
//  Fling Swift
//
//  Created by Chris Parrish on 5/3/15.
//  Copyright (c) 2015 Chris Parrish. All rights reserved.
//

import UIKit


class TokenFormation {

    class func formationWithFourFourTwo() -> TokenFormation {
        
        let fourFourTwoLocations = [
            CGPoint(x: 100.0, y: 333.0),
            CGPoint(x: 340.0, y: 566.0),
            CGPoint(x: 340.0, y: 102.0),
            CGPoint(x: 500.0, y: 250.0),
            CGPoint(x: 270.0, y: 250.0),
            CGPoint(x: 270.0, y: 418.0),
            CGPoint(x: 600.0, y: 566.0),
            CGPoint(x: 500.0, y: 418.0),
            CGPoint(x: 780.0, y: 438.0),
            CGPoint(x: 780.0, y: 230.0),
            CGPoint(x: 600.0, y: 102.0)
        ]
        
        return TokenFormation(locations: fourFourTwoLocations)
    }
    
    
    required init(locations: [CGPoint]) {
        self.locations = locations
    }
    
    func locationForTokenAtIndex(index: Int) -> CGPoint {
        if index < self.locations.count {
            return self.locations[index]
        }
        
        return CGPointZero
    }

    //MARK: - Private
    
    private let locations: [CGPoint]
    
}
