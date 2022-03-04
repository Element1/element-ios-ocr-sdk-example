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
        
        let versionsLabel = UILabel()
        versionsLabel.translatesAutoresizingMaskIntoConstraints = false
        versionsLabel.textColor = .darkGray
        versionsLabel.adjustsFontSizeToFitWidth = true
        versionsLabel.textAlignment = .center
        versionsLabel.text = "Face v" + ElementSDKConfiguration.shared().sdkVersion + " - eKYC v" + ElementOCRSDKConfiguration.shared.sdkVersion
        self.view.addSubview(versionsLabel)
        if #available(iOS 11.0, *) {
            versionsLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
            versionsLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            versionsLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
            versionsLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        } else {
            versionsLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
            versionsLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            versionsLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
            versionsLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20.0
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(stackView)

        let enrollmentButton = UIButton.elt_primaryButton(withFrame: CGRect(x: 0, y: 0, width: UIScreen.width() / 2, height: 50), title: "Enrollment")
        enrollmentButton.addTarget(self, action: #selector(HomePageViewController.faceEnrollment), for: .touchUpInside)
        enrollmentButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        stackView.addArrangedSubview(enrollmentButton)
        enrollmentButton.translatesAutoresizingMaskIntoConstraints = false

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

        stackView.bottomAnchor.constraint(equalTo: versionsLabel.topAnchor).isActive = true
        if #available(iOS 11.0, *) {
            stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
        stackView.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        
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
        
        ElementOCRSDKTransaction.getReviewResult(for: account, successBlock: { (resp) in
            LoadingController.hideLoading()
            self.reloadData()

            let sv = ApplicationSummaryView(account: account, applicationSummary: resp, subtitle: nil) { v in
                v.removeFromSuperview()
            }
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
            if transactionResult == .reviewRejected {
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
    
    func finishEKYCFlow(account: ELTAccount, cardMatchingConfidenceScore: Float?) {
        
        let continueButton = ELTAlertButton()
        continueButton.title = "OK"
        continueButton.block = {
            (view) in
            (view as! ELTSlidingCardAlertView).animateDown {
                view.removeFromSuperview()
            }
        }
        self.reloadData()
        
        var title = "Account successfully created!"
        if account.documentVerificationStatus == .rejected {
            title = "Account created but card matching failed, you will need to scan another document."
        }
        var subtitle : String? = nil
        // show if available cardMatchingConfidenceScore
        if let cms = cardMatchingConfidenceScore {
            subtitle = String(format: "Card Matching Result: %.2f%%", cms * 100)
        }

        let t = ELTContentText(text: title, type: .title, textColor: UIColor(rgb: 0x02364A))
        var content = [ELTContentSpace(height: 10), t, ELTContentSpace(height: 10)]
        if let st = subtitle {
            content.append(ELTContentText(text: st, type: .subtitle, textColor: UIColor(rgb: 0x02364A)))
            content.append(ELTContentSpace(height: 10))
        }
        
        let cv = ELTSlidingCardAlertView(content: content, animate: true, buttons: [continueButton], closeButtonBlock: nil)
        UIApplication.shared.keyWindow!.addSubview(cv)
        cv.elt_pinToSuperview()
        cv.animateUp()
    }
    
    @objc func startOcrWithCardMatching() {
        
        let mode : OcrReviewType = .localReviewOnly
        DispatchQueue.main.async {
            
            let documentSelectedBlock : (UIViewController, OcrDocument)->() = { (viewController, selectedDoc) in
                ElementSDKConfiguration.shared().country = selectedDoc.country
                let ocrScanParameters = OcrScanParameters(ocrReviewType: mode, documentType: selectedDoc, detectFace: false)
                
                let scanVc = ScanDocumentViewController(accountScannedBlock: { (viewController, cardImages, account) in
                    account.country = selectedDoc.country
                    let eKYCParameters = ELTeKYCParameters()
                    eKYCParameters.documentSupportId = selectedDoc.documentId
                    
                    eKYCParameters.cardMatchingMode = .enabledKeepUserWhenBelowThresholdButMustRescan
                    
                    
                    eKYCParameters.enrollmentMode = .local
                    
                    eKYCParameters.documentAction = .none
                    
                    let feoiv = self.faceEnrollmentOCRViewController(account: account, accountEnrolledBlock: {
                        vc, account, eKYCResponse in
                        self.navigationController?.popToRootViewController(animated: true)
                        
                        self.handleCardMatchingResponse(eKYCResponse: eKYCResponse, account: account) {
                            cardMatchingConfidenceScore in // handled
                            
                            self.finishEKYCFlow(account: account, cardMatchingConfidenceScore: cardMatchingConfidenceScore)
                        }
                    }, cancelBlock: {
                        vc, earlyExitReason in
                        if earlyExitReason != .userGaveUpUploading {
                            // Report enrollment early exit
                            account.deleteFromDevice()
                        }
                        self.navigationController?.popToRootViewController(animated: true)
                        self.reloadData()
                    }, eKYCParameters: eKYCParameters, cardImages: cardImages)
                    if let feoiv = feoiv {
                        viewController.navigationController?.pushViewController(feoiv, animated: true)
                    }
                }, cancelBlock: {
                    (vc, acc) in
                    acc?.deleteFromDevice()
                    // cancelled
                    self.reloadData()
                    self.navigationController?.popToRootViewController(animated: true)
                }, ocrScanParameters: ocrScanParameters)
                viewController.elt_pushViewController(scanVc)
            }
            self.useProvidedDocOrSelect(documentSelectedBlock: documentSelectedBlock)
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                let account = self.accounts[indexPath[1]]
                var buttons = [AlertButton]()
                if account.eKYCStatus == .waitingForReview {
                    buttons.append(AlertButton(text: "Download OCR data / review status", block: {
                        self.downloadOcrData(account: account)
                    }))
                }
                if account.faceAccountState == .ready {
                    buttons.append(AlertButton(text: "Card Matching / ID Validation", block: {
                        // doc scanner
                        let eKYCParams = ELTeKYCParameters()
                        eKYCParams.enrollmentMode = .none
                        eKYCParams.deduplicationMode = .disabled
                        eKYCParams.documentAction = .none
                        eKYCParams.cardMatchingMode = .enabledKeepUserWhenBelowThresholdButMustRescan
                        if let vc = CardMatchingIntroViewController(account: account, eKYCParameters: eKYCParams, matchedBlock: {
                            _,_,_  in
                            account.documentVerificationStatus = .verified
                            account.save()
                            self.navigationController?.popToRootViewController(animated: true)
                        }, cancelBlock: {
                            _ in 
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
    
    var document : OcrDocument? = nil
    var customizeUITheme = false
    
    func useProvidedDocOrSelect(documentSelectedBlock : @escaping (UIViewController, OcrDocument)->()) {
        if let document = self.document {
            documentSelectedBlock(self, document)
            return
        }
        
        let vc = DocumentTypePickerViewController(documentSelectedBlock: documentSelectedBlock, cancelBlock: {
            (viewController) in
            self.reloadData()
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        if customizeUITheme {
            vc?.customizeDocumentBlock = {
                doc in
                if doc.documentDisplayName == "Passport" {
                    let doc2 = doc
                    doc2.documentDisplayName = doc.country + " " + doc.documentDisplayName
                    doc2.icon = UIImage(named: "pending")
                    doc2.firstScanPrompt = "Scan Information Page"
                    doc2.secondScanPrompt = "Scan Signature Page"
                    return doc2
                }
                return doc
            }
        }
        vc?.leftButtonType = .backButton
        
        self.elt_pushViewController(vc)
    }
    
    public func faceEnrollmentOCRViewController(account: ELTAccount,
                                   accountEnrolledBlock: @escaping (UIViewController, ELTAccount, ELTeKYCResponse)->(),
                                            cancelBlock: @escaping (UIViewController, ELTEarlyExitReason)->(),
                                         eKYCParameters: ELTeKYCParameters,
                                             cardImages: Array<TaggedImage>) -> FaceEnrollmentViewController? {
        let successBlock : (UIViewController, ELTeKYCResponse)->() = {
            (viewController, details) in
            account.save()
            //self.restoreNavigationBarHiddenState()
            accountEnrolledBlock(self, account, details)
        }
        let earlyExitBlock : (UIViewController, ELTEarlyExitReason)->() = {
            (viewController, earlyExitReason) in
            //self.restoreNavigationBarHiddenState()
            cancelBlock(self, earlyExitReason)
        }
        if eKYCParameters.enrollmentMode == .local {
            let vc = LocalFaceEnrollmentOCRViewController(userId: account.userId, cardImages: cardImages, eKYCParameters: eKYCParameters, completionHandler: successBlock, onEarlyExit: earlyExitBlock)
            if let vc = vc {
                if eKYCParameters.documentAction == .manualReview {
                    let c = ReviewProgressView(checkReviewStatusBlock: nil, doneBlock: nil, scanAgainBlock: nil)
                    vc.customEnrollmentProgressView = c
                    vc.customEnrollmentProgressViewAddedCallback = {
                        v in
                        v.elt_pinToSuperview()
                    }
                }
                vc.showGazeInstructions = true
                vc.showEnrollmentSuccessScreen = false
                return vc
            }
        } else {
            let vc = RemoteFaceEnrollmentOCRViewController(userId: account.userId, cardImages: cardImages, eKYCParameters: eKYCParameters, completionHandler: successBlock, onEarlyExit: earlyExitBlock)
            if let vc = vc {
                if eKYCParameters.documentAction == .manualReview {
                    let c = ReviewProgressView(checkReviewStatusBlock: nil, doneBlock: nil, scanAgainBlock: nil)
                    vc.customEnrollmentProgressView = c
                    vc.customEnrollmentProgressViewAddedCallback = {
                        v in
                        v.elt_pinToSuperview()
                    }
                }
                vc.showGazeInstructions = true
                // showEnrollmentSuccessScreen not read/used for remote
                return vc
            }
        }
        return nil
    }
    
    func handleCardMatchingResponse(eKYCResponse: ELTeKYCResponse, account: ELTAccount, viewToRemove: UIView? = nil, proceedBlock: (Float?)->()) {
        
        let threshold : Float = 0.85
        guard let cm = eKYCResponse.cardMatchingResult else {
            if let v = viewToRemove {
                v.removeFromSuperview()
            }
            return
        }
        
        if cm.cardMatchingConfidenceScore.floatValue > threshold {
            account.documentVerificationStatus = .verified
            account.save()
            proceedBlock(cm.cardMatchingConfidenceScore.floatValue)
        } else {
            account.documentVerificationStatus = .rejected
            account.save()
            proceedBlock(cm.cardMatchingConfidenceScore.floatValue)
        }
    }
    
    func pullReviewFor(account: ELTAccount, progressView: ReviewProgressView, cardMatchingResultString: String? = nil) {
        ElementOCRSDKTransaction.getReviewResult(for: account, successBlock: { (resp) in
            progressView.justCheckedReviewStatus()
            progressView.setStep(2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let applicationSummaryViewController = ApplicationSummaryViewController(account: account, applicationSummary: resp, subtitle: cardMatchingResultString) { viewController in
                    viewController.dismiss(animated: true, completion: nil)
                }
                applicationSummaryViewController.modalPresentationStyle = .fullScreen
                self.present(applicationSummaryViewController, animated: false, completion: nil)
                self.reloadData()
                progressView.removeFromSuperview()
            }
        }) { (transactionResult, error, errorMessage) in
            progressView.justCheckedReviewStatus()
            if transactionResult == .reviewRejected {
                progressView.switchToScanAgainState()
                return
            }
        }
    }
    
    @objc public func scanOnly(account: ELTAccount? = nil) {
        DispatchQueue.main.async {
            
            let documentSelectedBlock : (UIViewController, OcrDocument)->() = {
                (viewController, selectedDoc) in
                ElementSDKConfiguration.shared().country = selectedDoc.country
                let ocrScanParameters = OcrScanParameters(ocrReviewType: .none, documentType: selectedDoc, detectFace: false)
                let scanVc = ScanDocumentViewController(documentScannedBlock: {
                    (viewController, cardImageArray) in
                    
                    viewController.navigationController?.popToRootViewController(animated: true)
                    
                    let eKYCParameters = ELTeKYCParameters()
                    eKYCParameters.enrollmentMode = .none
                    eKYCParameters.documentSupportId = selectedDoc.documentId
                    eKYCParameters.documentAction = .manualReview
                    eKYCParameters.cardMatchingMode = .disabled
                    
                    var accountOrNil = account
                    if accountOrNil == nil {
                        accountOrNil = ELTAccount.createNew()
                        eKYCParameters.enrollmentMode = .remote
                    }
                    
                    guard let account = accountOrNil else {
                        return
                    }
                    
                    account.country = selectedDoc.country
                    account.cardImages = cardImageArray
                    
                    let ocrWaiting = ReviewProgressView(checkReviewStatusBlock: { pv in
                        self.pullReviewFor(account: account, progressView: pv)
                    }, doneBlock: { pv in
                        pv.removeFromSuperview()
                        account.save()
                        self.reloadData()
                    }) { pv in
                        pv.removeFromSuperview()
                        // scan again
                        self.scanOnly(account: account)
                    }

                    UIApplication.shared.keyWindow!.addSubview(ocrWaiting)
                    ocrWaiting.setStep(0)
                    ocrWaiting.elt_pinToSuperview()
                    
                    ElementOCRSDKTransaction.eKYC(with: account, cardImages: cardImageArray, selfieImages: [], parameters: eKYCParameters) { eKYCResponse in
                        
                        ocrWaiting.setStep(1)
                        self.pullReviewFor(account: account, progressView: ocrWaiting)
                    } errorBlock: {
                        result, error, errorMessage in
                        if result != .errorNetwork {
                            account.deleteFromDevice()
                        }
                        ocrWaiting.removeFromSuperview()
                        self.reloadData()
                        // error
                        self.showMessage(title: "An error occurred, please try again.", message: nil) {
                            
                        }
                    }
                }, cancelBlock: {
                    (vc, acc) in
                    acc?.deleteFromDevice()
                    print("user cancelled")
                    self.reloadData()
                    self.navigationController?.popToRootViewController(animated: true)
                }, ocrScanParameters: ocrScanParameters)
                if let scanVc = scanVc {
                    viewController.navigationController?.pushViewController(scanVc, animated: true)
                }
            }
            self.useProvidedDocOrSelect(documentSelectedBlock: documentSelectedBlock)
        }
    }
    
    func continueReviewFlow(account: ELTAccount, cardMatchingConfidenceScore: Float?) {
        
        
        var subtitle : String? = nil
        
            if let cms = cardMatchingConfidenceScore {
                subtitle = String(format: "Card Matching Result: %.2f%%", cms * 100)
                if account.documentVerificationStatus == .rejected {
                    subtitle?.append("\n")
                    subtitle?.append("Card matching failed, you will need to scan another document.")
                }
            }
        
        
        
            let ocrWaiting = ReviewProgressView(checkReviewStatusBlock:{ pv in
                self.pullReviewFor(account: account, progressView: pv)
            }, doneBlock: { pv in
                pv.removeFromSuperview()
                self.reloadData()
            }, scanAgainBlock: { pv in
                pv.removeFromSuperview()
                self.reloadData()
                self.scanOnly(account: account)
            })
            UIApplication.shared.keyWindow!.addSubview(ocrWaiting)
            ocrWaiting.setStep(1)
            ocrWaiting.elt_pinToSuperview()
            
            self.pullReviewFor(account: account, progressView: ocrWaiting, cardMatchingResultString: subtitle)
    }
    
    @objc func startOnlineReviewFlow() {
        DispatchQueue.main.async {
            
            let documentSelectedBlock : (UIViewController, OcrDocument)->() = {
                (viewController, selectedDoc) in
                ElementSDKConfiguration.shared().country = selectedDoc.country
                let ocrScanParameters = OcrScanParameters(ocrReviewType: .none, documentType: selectedDoc, detectFace: false)
                ocrScanParameters.allowCameraRollPictures = false
                let scanVc = ScanDocumentViewController(documentScannedBlock: {
                    (viewController, cardImageArray) in
                    
                    let account = ELTAccount.createNew()
                    account.country = selectedDoc.country
                    account.cardImages = cardImageArray
                    
                    let eKYCParameters = ELTeKYCParameters()
                    eKYCParameters.documentSupportId = selectedDoc.documentId
                    eKYCParameters.cardMatchingMode = .enabledKeepUserWhenBelowThresholdButMustRescan
                    eKYCParameters.enrollmentMode = .local
                    eKYCParameters.documentAction = .manualReview
                    
                    let feoiv = self.faceEnrollmentOCRViewController(account: account, accountEnrolledBlock: {
                        vc, account, eKYCResponse in
                        self.navigationController?.popToRootViewController(animated: true)
                        self.handleCardMatchingResponse(eKYCResponse: eKYCResponse, account: account) {
                            cardMatchingConfidenceScore in // handled
                            self.continueReviewFlow(account: account, cardMatchingConfidenceScore: cardMatchingConfidenceScore)
                        }
                    }, cancelBlock: {
                        vc, earlyExitReason in
                        // Report enrollment early exit
                        if earlyExitReason != .userGaveUpUploading {
                            account.signOut()
                        }
                        self.navigationController?.popToRootViewController(animated: true)
                        self.reloadData()
                    }, eKYCParameters: eKYCParameters, cardImages: cardImageArray)
                    if let feoiv = feoiv {
                        // upload everything (demos)
                        feoiv.sessionDataUploadMask = [.everything]
                        viewController.navigationController?.pushViewController(feoiv, animated: true)
                    }
                }, cancelBlock: {
                    (vc, acc) in
                    print("user cancelled")
                    acc?.deleteFromDevice()
                    self.reloadData()
                    self.navigationController?.popToRootViewController(animated: true)
                }, ocrScanParameters: ocrScanParameters)
                if let scanVc = scanVc {
                    viewController.navigationController?.pushViewController(scanVc, animated: true)
                }
            }
            self.useProvidedDocOrSelect(documentSelectedBlock: documentSelectedBlock)
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
        if account.eKYCStatus == .waitingForReview {
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
        } else if account.eKYCStatus == .rejected {
            let title = "Account activation pending further review."
            let subtitle = "We had trouble processing the front of your ID, please try again."
            self.showMessage(title: title, message: subtitle, buttons: [ AlertButton(text: "OK", block: {
                self.scanOnly(account: account)
            })])
            return
        } else if account.eKYCStatus == .uploadNeeded {
            LoadingController.showLoading("Uploading OCR Data")
            ElementOCRSDKTransaction.uploadEKYCData(for: account, successBlock: { (resp) in
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
    
    @objc func faceEnrollment() {
        let account = ELTAccount.createNew()
        self.handleUserInitNeededRemote(account: account)
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
            return ELTContentText(text: "Thank you", type: .medium)
        }

        if let _ = UserDefaults.standard.object(forKey: "hidePreCaptureInstructions") {
            enrollmentVC?.showGazeInstructions = !UserDefaults.standard.bool(forKey: "hidePreCaptureInstructions")
        } else {
            enrollmentVC?.showGazeInstructions = true
        }
        
        enrollmentVC?.showGazeInstructions = false
        
        self.elt_pushViewController(enrollmentVC)
    }
    
    func handleAccountReadyRemote(account: ELTAccount) {    
        let vc = RemoteFaceAuthenticationViewController(userId: account.userId, onAuthentication:  { (viewController, confidencScore, message) in
            print("success authenticating")
            if ElementSDKConfiguration.shared().uiTheme.themeId == .selfieDotV2 {
                viewController.dismiss(animated: false, completion: nil)
            } else {
                _ = viewController.navigationController?.popViewController(animated: true)
            }
        }, onEarlyExit: { (viewController, earlyExitReason) in
            print("authentication cancelled")
            if ElementSDKConfiguration.shared().uiTheme.themeId == .selfieDotV2 {
                viewController.dismiss(animated: false, completion: nil)
            } else {
                _ = viewController.navigationController?.popViewController(animated: true)
            }
        })
        vc?.showGazeInstructions = true
        vc?.userId = account.userId
        if ElementSDKConfiguration.shared().uiTheme.themeId == .selfieDotV2 {
            if let vc = vc {
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: false, completion: nil)
            } else {
                print("ERROR: view controller is nil")
            }
        } else {
            self.elt_pushViewController(vc)
        }
    }
#endif
}
