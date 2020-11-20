//
//  UIScreen+Element.swift
//  demo
//
//  Created by Laurent Grandhomme on 9/29/16.
//  Copyright © 2016 Element. All rights reserved.
//

import UIKit

extension UIScreen {
    class func width() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    class func height() -> CGFloat {
        return UIScreen.main.bounds.height
    }
}
