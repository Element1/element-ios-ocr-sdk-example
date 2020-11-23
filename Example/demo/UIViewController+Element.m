//
//  UIViewController+Element.m
//  facedemo
//
//  Created by Laurent Grandhomme on 11/19/18.
//  Copyright © 2018 Element. All rights reserved.
//

#import "UIViewController+Element.h"

#if !(TARGET_IPHONE_SIMULATOR)
#import <ElementOCR/ElementOCR.h>
#endif

@implementation UIViewController (Element)

#if !(TARGET_IPHONE_SIMULATOR)

- (void)objc_startOcrWithCardMatching:(void(^)(NSNumber *))block {
    // select the document type
    DocumentTypePickerViewController *dpv = [[DocumentTypePickerViewController alloc] initWithDocumentSelectedBlock:^(UIViewController * viewController, OcrDocument * selectedDocument) {
        NSArray *requiredFields = @[@"GIVEN_NAME", @"SURNAME", @"DATE_OF_BIRTH", @"DATE_OF_ISSUE", @"DATE_OF_EXPIRY", @"GENDER", @"SEX", @"NATIONALITY", @"ADDRESS"];
        OcrScanParameters *params = [[OcrScanParameters alloc] initWithOcrReviewType:OcrReviewTypeLocalReviewOnly documentType:selectedDocument documentSideScanType:DocumentSideScanTypeFrontOnly requiredFields:requiredFields detectFace:YES];
        // scan the document and perform OCR
        ScanDocumentViewController *scanVc = [[ScanDocumentViewController alloc] initWithAccountScannedBlock:^(UIViewController * viewController, NSArray<TaggedImage *> * cardImages, ELTAccount * account) {
            NSDictionary *additionalParams = [ElementOCRHelper additionalOcrParametersWithRequiredFields:requiredFields documentType:selectedDocument];
            // enrollment with card matching
            FaceEnrollmentOCRIntroViewController *feiv = [[FaceEnrollmentOCRIntroViewController alloc] initWithAccount:account accountEnrolledBlock:^(UIViewController * viewController, ELTAccount * account, NSNumber *confidenceScore) {
                // let the swift code show the result
                block(confidenceScore);
            } cancelBlock:^(UIViewController * viewController) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            } enrollmentMode:ELTEnrollmentModeRemote cardImages:cardImages additionalOcrParameters:additionalParams enrollmentAction:ELTOcrPostEnrollmentActionCardMatching];
            [viewController.navigationController pushViewController:feiv animated:YES];
        } cancelBlock:^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        } ocrScanParameters:params];
        [viewController.navigationController pushViewController:scanVc animated:YES];
    }];
    [self.navigationController pushViewController:dpv animated:YES];
}

#endif

@end
