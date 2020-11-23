//
//  FaceAccountPickerViewController.swift
//  demo
//
//  Created by Laurent Grandhomme on 11/9/17.
//  Copyright © 2017 Element. All rights reserved.
//

import UIKit
#if !(targetEnvironment(simulator))
import ElementSDK
import ElementOCR
#endif

class HomePageViewController: UIViewController {
#if !(targetEnvironment(simulator))
    lazy var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0,
                                                  y: 0,
                                              width: UIScreen.width(),
                                             height: UIScreen.height()))
        tableView.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor.clear
        return tableView
    }()
    
    var ocrButton : UIButton?
    var createAccountButton : UIButton?
    
    var ds : TableViewDataSource?
    var accounts : [ELTAccount]
    
    init() {
        self.accounts = []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.title = "Element OCR Example";
        
        self.tableView.registerClass(AccountTableViewCell.self)
        self.tableView.backgroundColor = .clear
        self.view.addSubview(self.tableView)
        
        self.view.setupWhiteElementBackground()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20.0
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        let ocrButton = UIButton.elt_primaryButton(withFrame: CGRect(x: 0, y: 0, width: UIScreen.width(), height: 50), title: "OCR")
        ocrButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        ocrButton.addTarget(self, action: #selector(HomePageViewController.startOcrFlow), for: .touchUpInside)
        stackView.addArrangedSubview(ocrButton)
        
        let reviewFlowButton = UIButton.elt_primaryButton(withFrame: CGRect(x: 0, y: 0, width: UIScreen.width() / 2, height: 50), title: "Review Flow")
        reviewFlowButton.addTarget(self, action: #selector(HomePageViewController.startOnlineReviewFlow), for: .touchUpInside)
        reviewFlowButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        stackView.addArrangedSubview(reviewFlowButton)
        reviewFlowButton.translatesAutoresizingMaskIntoConstraints = false
        
        let ocrCMButton = UIButton.elt_primaryButton(withFrame: CGRect(x: 0, y: 0, width: UIScreen.width() / 2, height: 50), title: "OCR+CM")
        ocrCMButton.addTarget(self, action: #selector(HomePageViewController.startOcrWithCardMatching), for: .touchUpInside)
        ocrCMButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        ocrCMButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(ocrCMButton)
        
        if #available(iOS 11.0, *) {
            stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            stackView.heightAnchor.constraint(equalToConstant: 90.0).isActive = true
        } else {
            stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            stackView.heightAnchor.constraint(equalToConstant: 90.0).isActive = true
        }
        
        self.tableView.registerClass(AccountTableViewCell.self)
        self.tableView.backgroundColor = .clear
        self.view.addSubview(self.tableView)
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        let margin : CGFloat = 20.0
        if #available(iOS 11.0, *) {
            self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: margin).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -margin).isActive = true
        } else {
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: margin).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -margin).isActive = true
        }
        self.tableView.bottomAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(HomePageViewController.longPress(longPressGestureRecognizer:)))
        self.tableView.addGestureRecognizer(longPressRecognizer)
        
        let tvh = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 20))
        self.tableView.tableHeaderView = tvh
    }
    
    func downloadOcrData(account: ELTAccount) {
        LoadingController.showLoading(String(format: "Downloading %@'s OCR data", account.firstName))
        ElementOCRSDKTransaction.getOcrResult(for: account, successBlock: { (resp) in
            LoadingController.hideLoading()
            self.reloadData()

            let sv = ApplicationSummaryViewHelper.applicationSummaryView(response: resp as NSDictionary, account: account)
        
            let v = ElementScrollableView(frame: UIApplication.shared.keyWindow!.frame, image: UIImage(named: "success")!, title: "Account successfully opened!", subtitle: nil, additionalView: sv, buttonTitle: "Done") { (elementView) in
                    elementView.removeFromSuperview()
                }
            
            self.view.addSubview(v)
            v.pinToSuperview()
        }) { (transactionResult, error, errorMessage) in
            LoadingController.hideLoading()
            self.reloadData()
            
            var imageName = "pending"
            var title = "Pending review"
            var subtitle = "Please contact customer support for further assistance."
            if transactionResult == ELTOcrTransactionReviewRejected {
                imageName = "failure"
                title = "Account activation pending further review."
                subtitle = "We had trouble processing the front of your ID, please try again."
            }
            
            let ev = ElementView(frame: UIApplication.shared.keyWindow!.frame, image: UIImage(named: imageName)!, title: title, subtitle: subtitle, buttonTitle: "Done") { (elementView) in
                elementView.removeFromSuperview()
            }
            
            self.view.addSubview(ev)
            ev.pinToSuperview()
        }
    }
    
    @objc func startOcrWithCardMatching() {
        let useObjc = true
        
        if useObjc {
            self.objc_startOcrWithCard(matching: { (confidencScore) in
                self.navigationController?.popToRootViewController(animated: true)
                self.reloadData()
                if confidencScore.floatValue > 0.90 {
                    let ev = ElementView(frame: UIApplication.shared.keyWindow!.frame, image: UIImage(named: "success")!, title: "Enrolled successfully", subtitle: nil, buttonTitle: "Done") { (elementView) in
                        elementView.removeFromSuperview()
                    }
                    self.view.addSubview(ev)
                    ev.pinToSuperview()
                } else {
                    let ev = ElementView(frame: UIApplication.shared.keyWindow!.frame, image: UIImage(named: "failure")!, title: "The card doesn't seem to match your selfie", subtitle: nil, buttonTitle: "Done") { (elementView) in
                        elementView.removeFromSuperview()
                    }
                    self.view.addSubview(ev)
                    ev.pinToSuperview()
                }
            })
            return
        }
    
        let mode : OcrReviewType = .localReviewOnly
        DispatchQueue.main.async {
            let vc = DocumentTypePickerViewController(/*documentTypes: docs*/) { (viewController, selectedDoc) in
                print(selectedDoc)
                let requiredFields = ["GIVEN_NAME", "SURNAME", "DATE_OF_BIRTH", "DATE_OF_ISSUE", "DATE_OF_EXPIRY", "GENDER", "SEX", "NATIONALITY", "ADDRESS"]
                let ocrScanParameters = OcrScanParameters(ocrReviewType: mode, documentType: selectedDoc, documentSideScanType: .frontOnly, requiredFields: requiredFields, detectFace: true)
                let scanVc = ScanDocumentViewController(accountScannedBlock: { (viewController, cardImages, account) in
                    let additionalOcrParameters : [ AnyHashable : Any ] = ElementOCRHelper.additionalOcrParameters(requiredFields: requiredFields, documentType: selectedDoc)
                    let feoiv = FaceEnrollmentOCRIntroViewController(account: account, accountEnrolledBlock: {
                        vc, account, details in
                        self.navigationController?.popToRootViewController(animated: true)
                        self.reloadData()
                        if let detailsFloat = details as! NSNumber? {
                            if detailsFloat.floatValue > 0.90 {
                                let ev = ElementView(frame: UIApplication.shared.keyWindow!.frame, image: UIImage(named: "success")!, title: "Enrolled successfully", subtitle: nil, buttonTitle: "Done") { (elementView) in
                                    elementView.removeFromSuperview()
                                }
                                self.view.addSubview(ev)
                                ev.pinToSuperview()
                            } else {
                                let ev = ElementView(frame: UIApplication.shared.keyWindow!.frame, image: UIImage(named: "failure")!, title: "The card doesn't seem to match your selfie", subtitle: nil, buttonTitle: "Done") { (elementView) in
                                    elementView.removeFromSuperview()
                                }
                                self.view.addSubview(ev)
                                ev.pinToSuperview()
                            }
                        }
                    }, cancelBlock: {
                        vc in
                        self.navigationController?.popToRootViewController(animated: true)
                        self.reloadData()
                    }, enrollmentMode: .remote, cardImages: cardImages, additionalOcrParameters: additionalOcrParameters, enrollmentAction: ELTOcrPostEnrollmentActionCardMatching)
                    if let feoiv = feoiv {
                        viewController.navigationController?.pushViewController(feoiv, animated: true)
                    }
                }, cancelBlock: {
                    (viewController) in
                    // cancelled
                    self.navigationController?.popToRootViewController(animated: true)
                }, ocrScanParameters: ocrScanParameters)
                viewController.elt_pushViewController(scanVc)
            }
            self.elt_pushViewController(vc)
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                let account = self.accounts[indexPath[1]]
                var buttons = [AlertButton]()
                if account.ocrReviewStatus == .waiting {
                    buttons.append(AlertButton(text: "Download OCR data / review status", block: {
                        self.downloadOcrData(account: account)
                    }))
                }
                if account.faceAccountState == .ready {
                    buttons.append(AlertButton(text: "Card Matching / ID Validation", block: {
                        // doc scanner
                        if let vc = CardMatchingIntroViewController(account: account, matchedBlock: {
                            account.documentVerified = true
                            account.save()
                            self.navigationController?.popToRootViewController(animated: true)
                        }, cancelBlock: {
                            self.navigationController?.popToRootViewController(animated: true)
                        }) {
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }))
                }
                buttons.append(AlertButton(text: "Cancel", style: .cancel, block: {

                }))
                let title = String(format: "Actions for %@", account.firstName)
                self.showMessage(title: title, message: nil, buttons: buttons)
            }
        }
    }
    
    func startOcr(allowManualEdit: Bool) {
        var mode : OcrReviewType = .localReviewOnly
        if allowManualEdit {
            mode = .localReviewWithManualInputAllowed
        }
        DispatchQueue.main.async {
            let vc = DocumentTypePickerViewController(/*documentTypes: docs*/) { (viewController, selectedDoc) in
                print(selectedDoc)
                let requiredFields = ["GIVEN_NAME", "SURNAME", "DATE_OF_BIRTH", "DATE_OF_ISSUE", "DATE_OF_EXPIRY", "GENDER", "SEX", "NATIONALITY", "ADDRESS"]
                let ocrScanParameters = OcrScanParameters(ocrReviewType: mode, documentType: selectedDoc, documentSideScanType: .frontOnly, requiredFields: requiredFields, detectFace: true)
                let scanVc = ScanDocumentViewController(accountScannedBlock: { (viewController, cardImages, account) in
                    self.navigationController?.popToRootViewController(animated: true)
                }, cancelBlock: {
                    (viewController) in
                    // cancelled
                    self.navigationController?.popToRootViewController(animated: true)
                }, ocrScanParameters: ocrScanParameters)
                if let scanVc = scanVc {
                    viewController.navigationController?.pushViewController(scanVc, animated: true)
                }
            }
            self.elt_pushViewController(vc)
        }
    }
    
    @objc func startOcrFlow() {
        self.showMessage(title: "If OCR fails, allow the user to manually enter the document's information?", message: nil, buttons: [AlertButton(text: "Yes", block: {
            self.startOcr(allowManualEdit: true)
        }), AlertButton(text: "No", block: {
            self.startOcr(allowManualEdit: false)
        })])
    }
    
    @objc func startOnlineReviewFlow() {
        DispatchQueue.main.async {
            let vc = DocumentTypePickerViewController(/*documentTypes: docs*/) { (viewController, selectedDoc) in
                print(selectedDoc)
                let requiredFields = ["GIVEN_NAME", "SURNAME", "DATE_OF_BIRTH", "DATE_OF_ISSUE", "DATE_OF_EXPIRY", "GENDER", "SEX", "NATIONALITY", "ADDRESS"]
                let ocrScanParameters = OcrScanParameters(ocrReviewType: .none, documentType: selectedDoc, documentSideScanType: .frontOnly, requiredFields: requiredFields, detectFace: true)
                viewController.navigationController?.pushViewController(ScanDocumentViewController(documentScannedBlock: {
                    (viewController, cardImageArray) in
                    print("account created")
                    let additionalOcrParameters : [ AnyHashable : Any ] = ElementOCRHelper.additionalOcrParameters(requiredFields: requiredFields, documentType: selectedDoc)
                    let userId = NSUUID().uuidString.replacingOccurrences(of: "-", with: "")
                    let account = ELTAccount.createNewAccount(withUserId: userId)
                    let feoiv = FaceEnrollmentOCRIntroViewController(account: account, accountEnrolledBlock: {
                        vc, account, details in
                        self.navigationController?.popToRootViewController(animated: true)
                        self.reloadData()

                        let ev = ElementView(frame: UIApplication.shared.keyWindow!.frame, image: UIImage(named: "pending")!, title: "Pending review", subtitle: nil, buttonTitle: "Done") { (elementView) in
                            elementView.removeFromSuperview()
                        }

                        self.view.addSubview(ev)
                        ev.pinToSuperview()
                    }, cancelBlock: {
                        vc in
                        self.navigationController?.popToRootViewController(animated: true)
                        self.reloadData()
                    }, enrollmentMode: .remote, cardImages: cardImageArray, additionalOcrParameters: additionalOcrParameters, enrollmentAction: ELTOcrPostEnrollmentActionOnlineReview)
                    if let feoiv = feoiv {
                        viewController.navigationController?.pushViewController(feoiv, animated: true)
                    }
                }, cancelBlock: {
                    (viewController) in
                    print("user cancelled")
                    self.navigationController?.popToRootViewController(animated: true)
                }, ocrScanParameters: ocrScanParameters)!, animated: true)
            }
            self.elt_pushViewController(vc)
        }
    }
    
    func reloadData() {
        // get a list of accounts stored on the device
        self.accounts = ELTAccount.allAccounts()
        
        var sectionModel = TableViewSectionModel()
        
        for account in self.accounts {
            sectionModel.cellModels.append(TableViewCellModel<AccountTableViewCell>(model: account, canBeSelected: true, onSelect: {
                self.handleTap(account)
            }, onDisplay: nil, onSwipeToDelete: {
                print("ask confirmation to delete", account)
                self.confirmDelete(account: account)
            }))
        }
        self.ds = TableViewDataSource(section: sectionModel)
        self.tableView.delegate = ds
        self.tableView.dataSource = ds
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func confirmDelete(account: ELTAccount) {
        let alert = UIAlertController(title: "Delete Account?", message: "Are you sure you want to remove \(account.firstName) from the device?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            (alert: UIAlertAction!) in
            print("we can delete the account")
            account.deleteFromDevice()
            self.reloadData()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) in
            self.reloadData()
        })
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleTap(_ account: ELTAccount) {
        if account.ocrReviewStatus == .waiting {
            var buttons = [AlertButton]()
            let checkNowButton = AlertButton(text: "Check now") {
                self.downloadOcrData(account: account)
            }
            buttons.append(checkNowButton)
            let cancelButton = AlertButton(text: "Cancel") {
                self.reloadData()
            }
            buttons.append(cancelButton)
            self.showMessage(title: "Waiting for the review", message: "Would you like to check the account's review status?", buttons: buttons)
            return
        } else if account.ocrReviewStatus == .rejected {
            let title = "Account activation pending further review."
            let subtitle = "We had trouble processing the front of your ID, please try again."
            self.showMessage(title: title, message: subtitle, buttons: [ AlertButton(text: "OK", block: {
                self.reloadData()
            }) ])
            return
        } else if account.ocrReviewStatus == .uploadNeeded {
            LoadingController.showLoading("Uploading OCR Data")
            ElementOCRSDKTransaction.uploadOcrData(for: account, successBlock: { (resp) in
                LoadingController.hideLoading()
                self.reloadData()
            }, errorBlock: { (resCode, error, errorMessage) in
                LoadingController.hideLoading()
                self.reloadData()
            })
            return
        }
    
        // remote
        switch account.faceAccountState {
            case .availableButNotDownloaded:
                self.handleAccountReadyRemote(account: account)
                break
            case .userInitNeeded, .unknown:
                self.handleUserInitNeededRemote(account: account)
                break
            case .ready:
                self.handleAccountReadyRemote(account: account)
                break
            default:
                assert(false, "not yet supported")
                break
        }
    }
    
    func handleUserInitNeededRemote(account: ELTAccount) {
        let enrollmentVC = RemoteFaceEnrollmentViewController(firstName:account.firstName, lastName: account.lastName, userId: account.userId, successBlock: { (vc) in
            if account.faceAccountState != .ready {
                account.faceAccountState = .availableButNotDownloaded
            }
            account.save()
            _ = vc.navigationController?.popViewController(animated: true)
        }, onEarlyExit: { (vc, earlyExitReason) in
            _ = vc.navigationController?.popViewController(animated: true)
        })
        enrollmentVC?.enrollmentMessageBlock = {
            return "Thank you"
        }

        if let _ = UserDefaults.standard.object(forKey: "hidePreCaptureInstructions") {
            enrollmentVC?.showGazeInstructions = !UserDefaults.standard.bool(forKey: "hidePreCaptureInstructions")
        } else {
            enrollmentVC?.showGazeInstructions = true
        }
        
        enrollmentVC?.showGazeInstructions = false
        
        self.navigationController?.pushViewController(enrollmentVC!, animated: true)
    }
    
    func handleAccountReadyRemote(account: ELTAccount) {    
        let vc = RemoteFaceAuthenticationViewController(userId: account.userId, onAuthentication:  { (viewController, confidencScore, message) in
            print("success authenticating")
            _ = viewController.navigationController?.popViewController(animated: true)
        }, onEarlyExit: { (viewController, earlyExitReason) in
            print("authentication cancelled")
            _ = viewController.navigationController?.popViewController(animated: true)
        })
        vc?.showGazeInstructions = true
        vc?.userId = account.userId
        self.navigationController?.pushViewController(vc!, animated: true)
    }
#endif
}
