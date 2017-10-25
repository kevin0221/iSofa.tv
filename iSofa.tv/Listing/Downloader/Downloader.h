//
//  Downloader.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 24/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Configuration.h"
#import "Parser.h"
@interface Downloader : NSObject
{
      NSString   *accessToken;
      Parser *parser;
}
+ (Downloader *)sharedInstance;
- (void) requestDataWithType:(RequestType) type andText:(NSString *)text;

@property (nonatomic,strong) id delegate;
@end
