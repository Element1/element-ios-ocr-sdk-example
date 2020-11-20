//
//  UIViewController+Alert.swift
//  demo
//
//  Created by Laurent Grandhomme on 9/28/16.
//  Copyright © 2016 Element. All rights reserved.
//

import UIKit

struct AlertButton {
    let text: String
    let block: ()->()
    let style: UIAlertAction.Style
    
    init(text: String, block: @escaping ()->()) {
        self.text = text
        self.block = block
        self.style = .default
    }
    init(text: String, style: UIAlertAction.Style, block: @escaping ()->()) {
        self.text = text
        self.block = block
        self.style = style
    }
}

extension UIViewController {
    
    func showMessage(title: String?, message: String?, block: @escaping ()->()) {
        self.showAlertView(title: title, message: message, fullWidthButtons: true, alertButtons: [AlertButton(text: "OK", block: {
            block()
        })])
    }
    
    func showMessage(title: String?, message: String?, buttons: [AlertButton]) {
        self.showAlertView(title: title, message: message, fullWidthButtons: true, alertButtons: buttons)
    }
    
    private struct AssociatedKeys {
        static var backgroundView = "backgroundView"
    }
    
    func showAlertView(title: String?, message: String?, fullWidthButtons: Bool, alertButtons: [AlertButton]) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        let margin : CGFloat = 20.0
        let alertStackView = UIStackView()
        alertStackView.translatesAutoresizingMaskIntoConstraints = false
        alertStackView.axis = .vertical
        alertStackView.spacing = 20.0
        alertStackView.distribution = .equalSpacing
        alertStackView.alignment = .fill

        let alertStackBackgroundView = UIView()
        alertStackBackgroundView.backgroundColor = UIColor.white
        alertStackBackgroundView.layer.cornerRadius = 5
        alertStackView.addSubview(alertStackBackgroundView)
        alertStackBackgroundView.pinToSuperview()
        
        alertStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        alertStackView.isLayoutMarginsRelativeArrangement = true
        
        backgroundView.addSubview(alertStackView)
        alertStackView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, constant: -2 * margin).isActive = true
        alertStackView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        alertStackView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        if let title = title {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 20.0)
            titleLabel.textColor = UIColor(rgb: 0x02364A)
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0
            alertStackView.addArrangedSubview(titleLabel)
        }
        
        if let message = message {
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = UIFont.systemFont(ofSize: 16.0)
            messageLabel.numberOfLines = 0
            messageLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
            messageLabel.textAlignment = .center
            alertStackView.addArrangedSubview(messageLabel)
        }
        
        for (index, buttonDesc) in alertButtons.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(buttonDesc.text, for: .normal)
            button.addTargetClosure { (b) in
                if let v = objc_getAssociatedObject(self, &AssociatedKeys.backgroundView) as? UIView {
                    v.removeFromSuperview()
                }
            
                buttonDesc.block()
            }
            if buttonDesc.style == .destructive {
                button.setTitleColor(UIColor(red: 1, green: 0.439, blue: 0.09, alpha: 1), for: .normal)
                button.setTitleColor(UIColor(red: 1, green: 0.439, blue: 0.09, alpha: 1).withAlphaComponent(0.7), for: .highlighted)
            } else {
                button.setTitleColor(UIColor(red: 0.471, green: 0.502, blue: 0.506, alpha: 1), for: .normal)
                button.setTitleColor(UIColor(red: 0.471, green: 0.502, blue: 0.506, alpha: 1).withAlphaComponent(0.7), for: .highlighted)
            }
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
            alertStackView.addArrangedSubview(button)
            if index != alertButtons.count - 1 {
                let line = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                line.backgroundColor = UIColor.lightGray
                alertStackView.addArrangedSubview(line)
                line.heightAnchor.constraint(equalToConstant: 1).isActive = true
                line.widthAnchor.constraint(equalTo: alertStackView.widthAnchor, constant: -2 * margin).isActive = true
                line.centerXAnchor.constraint(equalTo: alertStackView.centerXAnchor).isActive = true
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(backgroundView)
        backgroundView.pinToSuperview()
        objc_setAssociatedObject(self, &AssociatedKeys.backgroundView, backgroundView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func elt_pushViewController(_ vc: UIViewController?) {
        if let vc = vc {
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            print("ERROR: view controller is nil")
        }
    }
}
