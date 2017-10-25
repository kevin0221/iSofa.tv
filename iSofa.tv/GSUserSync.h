//
//  GSUserSync.h
//  YouSellIt
//
//  Created by Sorin's Macbook Pro on 04/06/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;
@interface GSUserSync : NSObject
+ (GSUserSync *)sharedInstance;
- (BOOL)synchroniseUser:(User *)user;
- (User *)      getSavedUser;
- (BOOL)        removeUser;
@end
