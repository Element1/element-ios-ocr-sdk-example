//
//  UserSignInViewController.swift
//  demo
//
//  Created by Laurent Grandhomme on 10/23/17.
//  Copyright © 2017 Element. All rights reserved.
//

import UIKit

#if !(targetEnvironment(simulator))
import ElementSDK
#endif

/*
 * Example showing how to use ElementSDKTransaction's userSignInWithEmail:pin:successBlock:errorBlock endpoint.
 * If successful, the ELTAccount that's returned is ready to use (the face and / or palm models will
 * be downloaded if available).
 */
enum SignInType {
    case emailAndPin
    case userId
}

class UserSignInViewController: UIViewController, UITextFieldDelegate {

    static func makeGenericTextField(_ placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.size.width - 20, height: 50)
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.darkGray
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.font = UIFont.systemFont(ofSize: 20)
        return textField
    }

    lazy var userIdTextField : UITextField = {
        let tf = UserSignInViewController.makeGenericTextField("userId")
        var frame = tf.frame
        frame.origin.y = 80
        tf.frame = frame
        tf.keyboardType = .emailAddress
        return tf
    }()
    lazy var emailTextField : UITextField = {
        let tf = UserSignInViewController.makeGenericTextField("email")
        var frame = tf.frame
        frame.origin.y = 80
        tf.frame = frame
        tf.keyboardType = .emailAddress
        return tf
    }()
    lazy var pinTextField : UITextField = {
        let tf = UserSignInViewController.makeGenericTextField("pin")
        var frame = tf.frame
        frame.origin.y = 140
        tf.frame = frame
        return tf
    }()
    
    var signInType : SignInType
    
    var email : String?
    var pin : String?

    var signInButton : UIButton?
    var spinningContainerView : UIView?
    
    
    init(email: String, pin: String) {
        self.signInType = .emailAndPin
        self.email = email
        self.pin = pin
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        self.signInType = .emailAndPin
        self.email = nil
        self.pin = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        self.title = "User Sign In"
        
        self.userIdTextField.autocorrectionType = .no
        self.userIdTextField.autocapitalizationType = .none
        
        self.emailTextField.autocapitalizationType = .none
        self.emailTextField.autocorrectionType = .no
        
        self.pinTextField.keyboardType = .numberPad
        self.pinTextField.isSecureTextEntry = true
        self.pinTextField.delegate = self
        
        self.signInButton = UIButton(type: .custom)
        self.signInButton?.setTitleColor(.blue, for: .normal)
        self.signInButton?.frame = CGRect(x: 20, y: 0, width: UIScreen.width() - 40, height: 50)
        self.signInButton?.setTitle("Sign In", for: .normal)
#if !(targetEnvironment(simulator))
        self.signInButton?.addTarget(self, action: #selector(UserSignInViewController.signIn), for: .touchUpInside)
#endif
        self.signInButton?.setTop(self.pinTextField.bottom() + 20)
        self.view.addSubview(self.signInButton!)
        self.signInButton?.centerHorizontally()
        
        let leftButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(UserSignInViewController.dismissVc))
        self.navigationItem.leftBarButtonItem = leftButton
        
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "icon_settings"), style: UIBarButtonItem.Style.done,
                                            target: self, action: #selector(UserSignInViewController.changeSignInType))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.setUpForm()
        
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUpForm() {
        if self.signInType == .emailAndPin {
            self.userIdTextField.removeFromSuperview()
            self.view.addSubview(self.emailTextField)
            self.view.addSubview(self.pinTextField)
            self.signInButton?.setTop(self.pinTextField.bottom() + 20)
        } else if self.signInType == .userId {
            self.emailTextField.removeFromSuperview()
            self.pinTextField.removeFromSuperview()
            self.view.addSubview(self.userIdTextField)
            self.signInButton?.setTop(self.userIdTextField.bottom() + 20)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pinTextField.setWidth(UIScreen.main.bounds.size.width - 20)
        self.emailTextField.setWidth(UIScreen.main.bounds.size.width - 20)
        self.userIdTextField.setWidth(UIScreen.main.bounds.size.width - 20)
        self.signInButton?.setWidth(UIScreen.main.bounds.size.width - 40)
    }
    
    @objc func changeSignInType() {
        let alert = UIAlertController(title: "Select the sign in type", message: nil, preferredStyle: .alert)
        
        let emailAndPinAction = UIAlertAction(title: "Email and pin", style: .default, handler: {
            (alert: UIAlertAction!) in
            self.signInType = .emailAndPin
            self.setUpForm()
        })
        let userIdAction = UIAlertAction(title: "User Id", style: .default, handler: {
            (alert: UIAlertAction!) in
            self.signInType = .userId
            self.setUpForm()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) in
        })
        
        alert.addAction(emailAndPinAction)
        alert.addAction(userIdAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissVc() {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                
            }
        }
    }
    
#if !(targetEnvironment(simulator))
    @objc func signIn() {
        self.emailTextField.resignFirstResponder()
        self.pinTextField.resignFirstResponder()
        self.userIdTextField.resignFirstResponder()
        
        let email = self.emailTextField.text!
        let pin = self.pinTextField.text!
        let userId = self.userIdTextField.text!

        let successBlock = {
            (account: ELTAccount) in
            print("got an account: ", account)
            DispatchQueue.main.async {
                LoadingController.hideLoading()
                self.dismissVc()
            }
        }
        
        let errorBlock = {
            (errorCode: ELTTransactionResult, error: Error, message: String?) in
            print("transaction result:", errorCode)
            DispatchQueue.main.async {
                LoadingController.hideLoading()
                if let errorString = (error as NSError).userInfo["message"] as? String {
                    self.showMessage(title: nil, message: errorString, block: {
                    
                    })
                } else {
                    self.showMessage(title: nil, message: error.localizedDescription, block: {
                    
                    })
                }
            }
        }
        
        if self.signInType == .emailAndPin {
            ElementSDKTransaction.userSignIn(withEmail: email.trimmingCharacters(in: CharacterSet.whitespaces), pin: pin.trimmingCharacters(in: CharacterSet.whitespaces), successBlock: successBlock, errorBlock: errorBlock)
        } else if self.signInType == .userId {
            ElementSDKTransaction.userSignIn(withUserId: userId.trimmingCharacters(in: CharacterSet.whitespaces), successBlock: successBlock, errorBlock: errorBlock)
        }
    }
#endif
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            return txtAfterUpdate.lengthOfBytes(using: .utf8) <= 4
        } else {
            print("cant get the text")
        }
        return true
    }
}
