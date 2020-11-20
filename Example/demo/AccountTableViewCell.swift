//
//  AccountTableViewCell.swift
//  demo
//
//  Created by Laurent Grandhomme on 10/31/17.
//  Copyright © 2017 Element. All rights reserved.
//

import UIKit

#if !(targetEnvironment(simulator))
import ElementSDK

class AccountTableViewCell: UITableViewCell, TableViewCellProtocol {

    static let labelHeight : CGFloat = 26
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(rgb: 0x02364A)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    lazy var bottomLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor(rgb: 0x788081)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var cellBackgroundView : UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        
        let bgView = UIView()
        bgView.layer.cornerRadius = 5
        bgView.backgroundColor = UIColor(rgb: 0xf8f5f4).withAlphaComponent(0.9)
        self.backgroundView = bgView
        
        let selectedBgView = UIView()
        selectedBgView.layer.cornerRadius = 5
        selectedBgView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        selectedBgView.clipsToBounds = true
        self.selectedBackgroundView = selectedBgView
        
        self.addSubview(self.nameLabel)
        self.addSubview(self.bottomLabel)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        self.nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        self.nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        self.nameLabel.heightAnchor.constraint(equalToConstant: AccountTableViewCell.labelHeight).isActive = true
        
        self.bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        self.bottomLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 10).isActive = true
        self.bottomLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        self.bottomLabel.heightAnchor.constraint(equalToConstant: AccountTableViewCell.labelHeight).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // CollectionViewCellProtocol
    func configure(_ model: ELTAccount) {
        if model.firstName == "" && model.lastName == "" {
            self.nameLabel.text = model.userId
        } else {
            self.nameLabel.text = model.firstName + " " + model.lastName
        }
        self.bottomLabel.text = model.userId
    }
    
    class func heightForModel(_ model: ELTAccount) -> CGFloat {
        return 10 + AccountTableViewCell.labelHeight * 2 + 10 + 10
    }
}
#endif
