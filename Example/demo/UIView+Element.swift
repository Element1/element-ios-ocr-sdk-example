//
//  UIView+Element.swift
//  demo
//
//  Created by Laurent Grandhomme on 9/29/16.
//  Copyright © 2016 Element. All rights reserved.
//

import UIKit

extension UIView {
    func size() -> CGSize {
        return self.frame.size
    }
    
    func origin() -> CGPoint {
        return self.frame.origin
    }
    
    func left() -> CGFloat {
        return self.frame.minX
    }
    
    func top() -> CGFloat {
        return self.frame.minY
    }
    
    func right() -> CGFloat {
        return self.frame.maxX
    }
    
    func bottom() -> CGFloat {
        return self.frame.maxY
    }
    
    func width() -> CGFloat {
        return self.frame.width
    }
    
    func setTop(_ top: CGFloat) {
        var f = self.frame
        f.origin.y = top
        self.frame = f
    }
    
    func setWidth(_ width: CGFloat) {
        var f = self.frame
        f.size.width = width
        self.frame = f
    }
    
    func extendSizeBy(_ x: CGFloat) {
        var f = self.frame
        f.size.width += x
        f.size.height += x
        self.frame = f
    }
    
    func height() -> CGFloat {
        return self.frame.height
    }
    
    func centerInSuperView() {
        self.centerVertically()
        self.centerHorizontally()
    }
    
    func centerVertically() {
        if let sv = self.superview {
            self.frame = CGRect(x: self.origin().x,
                                y: (sv.frame.size.height / 2 - self.frame.size.height / 2),
                                width: self.frame.size.width,
                                height: self.frame.size.height).integral
        }
    }
    
    func centerHorizontally() {
        if let sv = self.superview {
            self.frame = CGRect(x: (sv.frame.size.width / 2 - self.frame.size.width / 2),
                                y: self.frame.origin.y,
                                width: self.frame.size.width,
                                height: self.frame.size.height).integral
        }
    }
    
    func pinToSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        // will crash (on purpose) if called before adding the view (self) to its superview
        self.topAnchor.constraint(equalTo: self.superview!.topAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: self.superview!.leftAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: self.superview!.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: self.superview!.heightAnchor).isActive = true
    }
}
