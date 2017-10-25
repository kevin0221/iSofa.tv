//
//  SMServerAPI.m
//  iTrack
//
//  Created by Sorin's Macbook Pro on 01/06/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "SMServerAPI.h"

static SMServerAPI *instance;
@implementation SMServerAPI


+(SMServerAPI *)sharedInstance
{
    if (instance == nil)
    {
        instance = [[SMServerAPI alloc] init];
        
    }
    
    return instance;
}
-(void) performMethod:(NSString *)method withDelegate:(id)delegate andCallback:(SEL)callback
{
    appendData = nil;
    baseCallback = callback;
    baseDelegate = delegate;
    
    NSURL *url       = [NSURL URLWithString:method];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [connection start];
}


-(void) performMethod:(NSString *)method withParameters:(NSDictionary *)dict withDelegate:(id)delegate andCallback:(SEL)callback
{
    
    [NSURLConnection cancelPreviousPerformRequestsWithTarget:self];
    appendData = nil;
    
    baseCallback = callback;
    baseDelegate = delegate;
    
    NSURL *url       = [NSURL URLWithString:method];
    
    NSMutableString *dataString = [NSMutableString string];
    for (NSString *key in dict.allKeys)
        [dataString appendFormat:@"%@=%@&",key,dict[key]];
    
    NSData *postData             = [dataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength         = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [connection start];
}

-(void) performURL:(NSString *)url withDelegate:(id)delegate andCallback:(SEL)callback
{
    appendData = nil;
    baseCallback = callback;
    baseDelegate = delegate;   
    
    NSURL *loadurl       = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loadurl];
    [request setTimeoutInterval:300];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    [connection start];
}

#pragma mark - data

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (appendData == nil)
    {
        appendData = [NSMutableData data];
    }
    
    [appendData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([baseDelegate respondsToSelector:baseCallback])
    {
        if (appendData)
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:appendData options:NSJSONReadingMutableContainers error:nil];
            //NSString *text = [[NSString alloc] initWithData:appendData encoding:NSUTF8StringEncoding];
            
            if(![dict isKindOfClass:[NSArray class]])
            {
                NSInteger code = [[dict objectForKey:@"code"] integerValue];
                if (code == 200)
                {
                    [baseDelegate performSelector:baseCallback withObject:[dict objectForKey:@"data"]];
                }
                else{
                    [baseDelegate performSelector:baseCallback withObject:nil];
                }
            }
            else
            {
                NSArray *list = [NSJSONSerialization JSONObjectWithData:appendData options:NSJSONReadingMutableContainers error:nil];
                [baseDelegate performSelector:baseCallback withObject: list];
            }
        }
        else
        {
            [baseDelegate performSelector:baseCallback withObject:nil];
        }
    }
    
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([baseDelegate respondsToSelector:baseCallback])
    {
        [baseDelegate performSelector:baseCallback withObject:nil];
    }
}

#pragma mark - protection space
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod
         isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        NSURLCredential *credential =
        [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}


-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}


@end
