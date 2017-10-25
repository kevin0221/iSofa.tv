//
//  User.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 07/02/15.
//  Copyright (c) 2015 Sorin's Macbook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic,assign) int user_id;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSString *facebook_id;
@property (nonatomic,strong) NSString *name;
@end
