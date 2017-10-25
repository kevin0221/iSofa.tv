//
//  MRValidation.m
//  Auto
//
//  Created by Sorin's Macbook Pro on 15/01/14.
//  Copyright (c) 2014 mReady. All rights reserved.
//

#import "GSValidation.h"

@implementation GSValidation


+ (GSValidation *)sharedInstance {
    static GSValidation *sharedInstance;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[GSValidation alloc] init];
        }
    }
    return sharedInstance;
}

#pragma mark - validate input text
-(BOOL)validateCodPostal:(NSString *)text
{
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]].length > 0) {
        return NO;
    }
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        
        return NO;
    }

    return YES;
}
- (BOOL) validateAddress:(NSString *) text
{
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0 || [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 10) {
        [self updateValidation:NO];
        return NO;
    }
    if ([text isEqualToString:@"Selecteaza"]) {
        [self updateValidation:NO];
        return NO;
    }
    if ([text isEqualToString:@"Adauga"]) {
        [self updateValidation:NO];
        return NO;
    }
    [self updateValidation:YES];
    return YES;
}
- (BOOL) validateInput:(NSString *) text
{
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [self updateValidation:NO];
        return NO;
    }
    if ([text isEqualToString:@"Selecteaza"]) {
        [self updateValidation:NO];
        return NO;
    }
    if ([text isEqualToString:@"Adauga"]) {
        [self updateValidation:NO];
        return NO;
    }
    [self updateValidation:YES];
    return YES;
}
#pragma mark - validate input text

- (BOOL) validateSerie:(NSString *) text
{
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        
        return NO;
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[^io]{17}$" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];

    return matches.count != 0;
}


- (BOOL) validateCiv:(NSString *) text
{
    
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        
        return NO;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-z]\\d{6,7}$" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    return matches.count != 0;
}

#pragma mark - numeric

- (BOOL) validateNumericInput:(NSString *) text
{
    NSString *string = [text stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if ([string isEqualToString:@"."])
    {
        return YES;
    }
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]].length > 0) {
        return NO;
    }
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL) validatePhoneInput:(NSString *) text
{
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]].length > 0) {
        return NO;
    }
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return NO;
    }
    
    return [self validateNumericInput:text] && text.length >= 10;
}

#pragma mark - validate license plate
//
//- (BOOL)validateLicensePlate:(NSString *)licensePlate
//{
//    
//    
//    if ([licensePlate isEqualToString:@""]) {
//      //  [self displayAlertWithTitle:@"Validare" AndMessage:@"Numarul de inmatriculare trebuie sa fie in format valid!"];
//        return false;
//    }
//    
//    MRNumberUtils *numberUtils = [[MRNumberUtils alloc] init];
//    if (![numberUtils validate:licensePlate])
//    {
//       // [self displayAlertWithTitle:@"Validare" AndMessage:@"Numarul de inmatriculare trebuie sa fie in format valid!"];
//        return false;
//    }
//    
//    
//    return true;
//}

//- (BOOL)validateLicensePlateFull:(NSString *)licensePlate
//{
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(B|AB|AR|AG|BC|BH|BN|BT|BR|BV|BZ|CL|CS|CJ|CT|CV|DB|DJ|GL|GR|GJ|HR|HD|IL|IS|IF|MM|MH|MS|NT|OT|PH|SJ|SM|SB|SV|TR|TM|TL|VS|VL|VN)\\s{0,1}(?:((?:(?<=^B)[1-9]\\d{2})|[1-9]\\d{1})\\s{0,1}(?!O|I|AIA|AII|AOO|AOZ|BII|BOI|BOO|BOU|BOW|BOY|BSI|CAC|CII|COA|COE|COI|COO|COW|COY|CUI|CUR|DII|DOO|DOS|EII|EOO|FII|FIS|FOO|FOS|FOT|FSI|FUI|FUT|GII|GOI|GOO|GOY|GOZ|HII|HOO|HUI|HUO|JEG|JII|JOO|JOS|KCI|KII|KIL|KIX|KKI|KKO|KOA|KOI|KOO|KOR|KUI|KUR|LBI|LOO|MII|MOE|MOI|MOO|MOR|MUI|NAO|NII|NOO|PII|PIX|PIZ|POC|POK|POO|RII|ROG|ROO|SII|SOI|SOO|TII|TOO|TOV|UDO|UII|UOO|UOU|UUI|UUO|VII|VKO|VOO|WCO|WII|WOO|XII|XOO|YAO|YII|YOC|YOO|YOY|ZII|ZIT|ZOB|ZOI|ZOO|ZOY)([A-Z]{3})|((?:(?=\\d{7,})((?!100)[1-9]\\d{2}|\\d{4,6})(\\d{2})(0[1-9]|1[0-2]))|(?!100)[1-9]\\d{2}|\\d{4,6}))$" options:NSRegularExpressionCaseInsensitive error:NULL];
//
//    NSArray *matches = [regex matchesInString:licensePlate options:0 range:NSMakeRange(0, [licensePlate length])];
//    if(matches.count != 0) {
//        NSTextCheckingResult *match = [matches objectAtIndex:0];
//        
//        if([match rangeAtIndex:4].length != 0) {
//            if([match rangeAtIndex:5].length != 0) {
//                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//                NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
//                int currentYear = [components year];
//                int currentMonth = [components month];
//                
//                NSString *year = [licensePlate substringWithRange:[match rangeAtIndex:6]];
//                NSString *month = [licensePlate substringWithRange:[match rangeAtIndex:7]];
//                
//                if([year integerValue] < 25) {
//                    year = [NSString stringWithFormat:@"20%@", year];
//                } else {
//                    year = [NSString stringWithFormat:@"19%@", year];
//                }
//                
//                if([year intValue] > currentYear) {
//                    return NO;
//                } else if([year intValue] == currentYear) {
//                    return [month intValue] < currentMonth;
//                }
//                
//                return YES;
//            }
//        }
//        return YES;
//    }
//    
//    return NO;
//    
//}
//

-(BOOL)validateAge:(NSDate *)date
{
    NSDateComponents* agecalcul = [[NSCalendar currentCalendar]
                                   components:NSYearCalendarUnit
                                   fromDate:date
                                   toDate:[NSDate date]
                                   options:0];
    //show the age as integer
    NSInteger age = [agecalcul year];
    
    NSLog(@"the age of user==%ld",(long)age);
    
    if (age > 17)
    {
        [self updateValidation:YES];
        return YES;
    }
    [self updateValidation:NO];
    return NO;
}
- (BOOL ) validateYear:(NSInteger )year
{
    NSDate *date = [NSDate date];
    NSString *dateDesc = date.description;

    NSString *dateString = [[dateDesc componentsSeparatedByString:@" "] firstObject];
    
    NSInteger curentYear = [self yearFromString:dateString];
    
    
    if (curentYear - year > 17)
        return YES;
    
    return NO;
    
}
- (NSInteger ) yearFromString:(NSString *) dateString
{
    NSString *year = nil;
    
    NSArray * arr = [dateString componentsSeparatedByString:@"/"];
    
    if (arr.count > 1)
    {
        
        for (NSString *string in arr)
        {
            if (string.length == 4)
            {
                year = string;
                break;
            }
        }
    }
    else
    {
        arr = [dateString componentsSeparatedByString:@"-"];
        if (arr.count > 1)
        {
            
            for (NSString *string in arr)
            {
                if (string.length == 4)
                {
                    year = string;
                    break;
                }
            }
            
        }
    }
    return year.integerValue;
    
}

-(BOOL)validateAgeFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //set the dateFormat
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    
    //allocating the date
    NSDate *dateFromString = [[NSDate alloc] init];
    
    //Start the Date From
    dateFromString = [dateFormatter dateFromString:dateString];
    
    NSDateComponents* agecalcul = [[NSCalendar currentCalendar]
                                   components:NSYearCalendarUnit
                                   fromDate:dateFromString
                                   toDate:[NSDate date]
                                   options:0];
    //show the age as integer
    NSInteger age = [agecalcul year];
    
    NSLog(@"the age of user==%ld",(long)age);
    
    if (age > 17)
    {
        [self updateValidation:YES];
        return YES;
    }
    [self updateValidation:NO];
    return NO;
}
#pragma mark - email
- (BOOL) validateEmail:(NSString *) text
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if ([emailTest evaluateWithObject:text] == NO) {
       // [self displayAlertWithTitle:@"Validare" AndMessage:@"Email trebuie sa fie in format valid!"];
    
        [self updateValidation:NO];
        return NO;
    }
    [self updateValidation:YES];
    return YES;
    
}
- (void) updateValidation:(BOOL) testValue
{
    if ([_delegate respondsToSelector:@selector(validationResult:)])
    {
        [_delegate validationResult:testValue];
    }
}
//#pragma mark - validate cui
//
//- (BOOL) validateCUI:(NSString *)cui
//{
//    if(cui.length < 2)
//    {
//     //[self displayAlertWithTitle:@"Validare" AndMessage:@"CUI trebuie sa fie in format valid!"];
//    return NO;
//    }
//    if (cui.length >12)
//        return [self validateCNP:cui];
//    if (cui.length > 9)
//    {
//      //  [self displayAlertWithTitle:@"Validare" AndMessage:@"CUI trebuie sa fie in format valid!"];
//        return NO;
//    }
//
//    
//    long long numarSerie = 753217532;
//    long long numarCui = cui.longLongValue;
//    
//    int suma=0;
//    numarCui = numarCui / 10;
//    for (int i=0;i<10;i++)
//    {
//        suma += (numarCui %10) * (numarSerie %10);
//        numarCui = numarCui / 10;
//        numarSerie = numarSerie / 10;
//        
//    }
//    
//    int r = (suma * 10) %11;
//    if (r == 10) {
//        r = 0;
//    }
//    if (cui.longLongValue % 10 != r) {
//        
//          //  [self displayAlertWithTitle:@"Validare" AndMessage:@"CUI trebuie sa fie in format valid!"];
//        
//        return NO;
//    }
//    return YES;
//}
//
//#pragma mark - validate cnp
//
//- (BOOL) validateCNP:(NSString *)cnpV
//{
//    if (cnpV.length != 13) {
//      //  [self displayAlertWithTitle:@"Validare" AndMessage:@"CNP trebuie sa fie in format valid!"];
//        return NO;
//    }
//    long long numberCnp   = cnpV.longLongValue;
//    long long numberSerie = 279146358279;
//    NSInteger sum = 0;
//    numberCnp = numberCnp / 10;
//    
//    for (int i = 0 ; i < cnpV.length - 1; i++) {
//        sum += (numberCnp %10) * (numberSerie %10);
//        numberCnp = numberCnp / 10;
//        numberSerie = numberSerie / 10;
//    }
//    int r = sum-11*(sum/11);
//    if (r == 10)
//        r = 1;
//    
//    if (r != cnpV.longLongValue % 10)
//    {
//       // [self displayAlertWithTitle:@"Validare" AndMessage:@"CNP trebuie sa fie in format valid!"];
//        return NO;
//    }
//
//    
//    return YES;
//}
#pragma mark - displayAlert
- (void) displayAlertWithTitle:(NSString *) title AndMessage:(NSString *) message
{
    UIAlertView *validateAlert = [[UIAlertView alloc] initWithTitle: title
                                                            message: message
                                                           delegate: self
                                                  cancelButtonTitle: @"Ok"
                                                  otherButtonTitles: nil, nil];
    
    [validateAlert show];
}
@end
