//
//  ChannelsView.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 27/11/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ChannelsViewDelegate
@optional
- (void) selectChannel:(NSString *) name;
@end
@interface ChannelsView : UIView <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *dataSource;
    NSArray        *filteredSource;
    IBOutlet UITableView *source;
    IBOutlet UISearchBar *searchBarChannel;
}
@property (nonatomic,strong) id   delegate;
- (void) updateVisualPosition:(BOOL) hide animated:(BOOL )animated;
- (void) hideScreen;
- (void) loadSource;
@property (nonatomic,assign) BOOL onScreen;
@end
