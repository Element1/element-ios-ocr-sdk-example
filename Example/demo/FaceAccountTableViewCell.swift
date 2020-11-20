//
//  FaceAccountTableViewCell.swift
//  demo
//
//  Created by Laurent Grandhomme on 11/1/17.
//  Copyright © 2017 Element. All rights reserved.
//

import UIKit
#if !(targetEnvironment(simulator))
import ElementSDK

class FaceAccountTableViewCell: AccountTableViewCell {
    override func configure(_ model: ELTAccount) {
        super.configure(model)
        if model.faceAccountState == .ready {
            self.bottomLabel.text = "Account status: Ready"
        } else if model.faceAccountState == .availableButNotDownloaded {
            self.bottomLabel.text = "Account status: Model needs to be downloaded"
        } else {
            self.bottomLabel.text = "Account status: Enrollment needed"
        }
    }
}
#endif
