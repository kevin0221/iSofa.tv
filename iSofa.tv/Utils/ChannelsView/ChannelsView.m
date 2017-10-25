//
//  ChannelsView.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/11/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "ChannelsView.h"
#import "SMServerAPI.h"
@implementation ChannelsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - state
-(void)hideScreen
{
    [searchBarChannel resignFirstResponder];
    self.frame = CGRectMake(CGRectZero.origin.x ,
                            CGRectZero.origin.y - CGRectGetHeight(self.frame),
                            CGRectGetWidth(self.frame),
                            CGRectGetHeight(self.frame)
                            );
    self.onScreen = NO;

}
-(void)updateVisualPosition:(BOOL)hide animated:(BOOL )animated
{
    float duration = 0.5f;
    if (!animated)
        duration = 0.0f;

   if(!dataSource || dataSource.count == 0)
       [self loadSource];
       
    [UIView animateWithDuration:duration animations:^{
    if (!hide)
    {
        self.frame = CGRectMake(CGRectZero.origin.x,
                                CGRectZero.origin.y,
                                CGRectGetWidth(self.frame),
                                CGRectGetHeight(self.frame)
                                );
    }
    else
    {   [searchBarChannel resignFirstResponder];
        self.frame = CGRectMake(CGRectZero.origin.x ,
                                CGRectZero.origin.y - CGRectGetHeight(self.frame),
                                CGRectGetWidth(self.frame),
                                CGRectGetHeight(self.frame)
                                );
    }
    }];
     self.onScreen = !hide;
}
#pragma mark - table
-(void)loadSource
{
     [[SMServerAPI sharedInstance] performURL:CHANNELS_URL withDelegate:self andCallback:@selector(channels:)];
}
- (void) channels:(NSArray *) channels
{
    dataSource     = [NSMutableArray arrayWithArray:channels];
    filteredSource = [NSArray arrayWithArray:channels];
    [source reloadData];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filteredSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString *name = filteredSource[indexPath.row];
    
    if([name.lowercaseString isEqualToString:@"espm"])
    {
        name = [NSString stringWithFormat:@"ESPM (best tv commercials)"];
    }
    
    cell.textLabel.text = name;
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([filteredSource[indexPath.row] isEqualToString:@"Your Channel"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"iSofa" message:@"Coming soon!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
        
    
    if([_delegate respondsToSelector:@selector(selectChannel:)])
    {
        [_delegate selectChannel:filteredSource[indexPath.row]];
    }
}
#pragma mark - search
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchBar.text];
    filteredSource         = [dataSource filteredArrayUsingPredicate:predicate];
  
    [source reloadData];
    return YES;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchBar.text];
    filteredSource         = [dataSource filteredArrayUsingPredicate:predicate];
    
    [source reloadData];

     [searchBar resignFirstResponder];
}
@end
