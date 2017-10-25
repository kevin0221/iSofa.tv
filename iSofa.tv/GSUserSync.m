//
//  GSUserSync.m
//  YouSellIt
//
//  Created by Sorin's Macbook Pro on 04/06/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "GSUserSync.h"
#import "User.h"
#import "SMServerAPI.h"

@implementation GSUserSync
+ (GSUserSync *)sharedInstance
{
    static GSUserSync *sharedInstance;
    
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [[GSUserSync alloc] init];
        }
    }
    
    return sharedInstance;
}
#pragma mark - user
-(BOOL)synchroniseUser:(User *)user
{
    if (user == nil)
    {
        return NO;
    }
    
    NSMutableDictionary *userLocal = [NSMutableDictionary dictionary];
    
    [userLocal setObject:@(user.user_id)    forKey:@"user_id"];
    [userLocal setObject:user.email         forKey:@"email"];
    [userLocal setObject:user.password      forKey:@"password"];
  
    
   
    
    
    if(user.facebook_id != nil)
    {
        if (![user.facebook_id isKindOfClass:[[NSNull null] class]] )
        {
            [userLocal setObject:user.facebook_id   forKey:@"facebook_id"];
            
            NSDictionary *loginInfo = [NSDictionary dictionaryWithObjects:@[@(user.user_id),user.facebook_id,@"facebook"] forKeys:@[@"id",@"facebook_token",@"method"]];

            
            [[SMServerAPI sharedInstance] performMethod:LOGIN_URL
                                         withParameters:loginInfo
                                           withDelegate:self
                                            andCallback:@selector(updateUser:)];
        }
        
        
    }
    
    
    [userLocal setObject:user.name          forKey:@"name"];
    
    
    NSLog(@"%@",userLocal);
    //save user
    BOOL saved = [userLocal writeToFile:[self diskPath] atomically:YES];

    return saved;
}
- (void) updateUser:(NSDictionary *) dict
{
    NSLog(@"%@",dict);
}
-(User *)getSavedUser
{
   
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self diskPath] isDirectory:false])
    {
        
        NSMutableDictionary *userLocal = [NSMutableDictionary dictionaryWithContentsOfFile:[self diskPath]];
        User *user = [[User alloc] init];
        
        user.user_id      = [[userLocal objectForKey:@"user_id"] intValue];
        user.email        = [userLocal objectForKey:@"email"];
        user.password     = [userLocal objectForKey:@"password"];
        user.facebook_id  = [userLocal objectForKey:@"facebook_id"];
        user.name         = [userLocal objectForKey:@"name"];
        return user;
 
    }
    

    
    return  nil;
}
-(BOOL)removeUser
{
    
   return [[NSFileManager defaultManager] removeItemAtPath:[self diskPath] error:nil];
}
#pragma mark - disk location
- (NSString *) diskPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"user.plist"];
}
@end
