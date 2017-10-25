//
//  MRValidation.h
//  Auto
//
//  Created by Sorin's Macbook Pro on 15/01/14.
//  Copyright (c) 2014 mReady. All rights reserved.
//


#import <UIKit/UIKit.h>
@protocol GSValidationDelegate <NSObject>

@optional
- (void) validationResult:(BOOL) isValid;

@end

@interface GSValidation : NSObject
@property (nonatomic,strong) id delegate;
+ (GSValidation *)sharedInstance;
- (BOOL ) validateYear:(NSInteger )year;
- (BOOL) validateInput        :(NSString *) text;
- (BOOL) validateNumericInput :(NSString *) text;
- (BOOL) validatePhoneInput   :(NSString *) text;
//- (BOOL) validateLicensePlate :(NSString *)licensePlate;
//- (BOOL) validateLicensePlateFull :(NSString *)licensePlate;
- (BOOL) validateEmail        :(NSString *) text;
//- (BOOL) validateCUI          :(NSString *)cui;
//- (BOOL) validateCNP          :(NSString *)cnpV;
- (BOOL) validateSerie        :(NSString *) text;
- (BOOL) validateCiv          :(NSString *) text;
- (BOOL) validateCodPostal    :(NSString *) text;
- (BOOL) validateAgeFromString:(NSString *) dateString;
- (BOOL) validateAge          :(NSDate *) date;
- (BOOL) validateAddress:(NSString *) text;
@end
