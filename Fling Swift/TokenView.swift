//
//  TokenView.swift
//  Fling Swift
//
//  Created by Chris Parrish on 5/2/15.
//  Copyright (c) 2015 Chris Parrish. All rights reserved.
//

import UIKit

class TokenView: UIView {
    
    let TokenViewDiameter = 75.0
    
    private var textLabel = UILabel()
    private var primaryColor = UIColor.blackColor()
    private var alternateColor = UIColor.whiteColor()
    
    init(label: String) {
        let frame = CGRect(x: 0.0, y: 0.0, width: TokenViewDiameter, height: TokenViewDiameter)
        super.init(frame: frame)
        
        self.commonInit()
        self.textLabel.text = label
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
        self.textLabel.text = nil
    }
    
    func commonInit() {
        self.textLabel = UILabel()
        self.textLabel.textColor = self.alternateColor
        self.textLabel.textAlignment = NSTextAlignment.Center
        self.textLabel.font = UIFont.boldSystemFontOfSize(30.0)
        
        self.addSubview(self.textLabel)
        
        self.backgroundColor = self.primaryColor
        self.clipsToBounds = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tokenDoubleTapped:")
        tapRecognizer.numberOfTapsRequired = 2
        tapRecognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapRecognizer)
    }

    //MARK: - UIView
    
    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.size.width / 2.0
        self.textLabel.frame = self.bounds
    }
    
    //MARK: - Actions
    
    func tokenDoubleTapped(sender: AnyObject?) {
        if self.backgroundColor == self.primaryColor {
            self.backgroundColor = self.alternateColor
            self.textLabel.textColor = self.primaryColor
        }
        else {
            self.backgroundColor = self.primaryColor
            self.textLabel.textColor = self.alternateColor
        }
    }
}

