//
//  PlaylistController.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 18/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "ChannelsViewController.h"
#import "Video.h"
#import "UIImageView+WebCache.h"
#import "CustomHUD.h"
#import "SMServerAPI.h"
#import "ExtrasView.h"
#import "User.h"
#import "GSUserSync.h"
#import "PlaylistCell.h"


static const NSString *strChannels[28] = {
  @"iSofa.tv Experience", @"Fail", @"Facebook", @"History", @"Ted Talks", @"Porta des Fundos", @"ESPM", @"YouTube", @"holas", @"thom yorke",
  @"Rihanna", @"Karina Zeviani", @"Katy Perry", @"Bjork", @"JennaMarbles", @"nigahiga", @"TaylorSwiftVEVO", @"machinima", @"ERB", @"Partoba",
  @"CNN", @"PewDiePie", @"ViceScience", @"TechViral", @"Joker", @"Eric clapton", @"MOVIES", @"macari"
};


@interface ChannelsViewController ()
{
    IBOutlet CustomHUD *screenLocker;
    NSString *lastURL;
    SEL      callback;
    NSMutableArray *pageArray;
    NSString *nextPage;
    NSString *my_keyword;
    
    int start;
    int end;
    IBOutlet UICollectionView *collectionSource;
    NSString *my_channel;
}

@end

@implementation ChannelsViewController

- (void)viewDidLoad
{
    self.screenName = @"Channel-list";
    [super viewDidLoad];
    
    
    // intialize...
    pageArray = [NSMutableArray array];
   [self showActivity];
   
    end = 10;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    [self showActivity];
}

-(void)viewDidLayoutSubviews
{
    CGSize winSize = collectionSource.frame.size;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionSource.collectionViewLayout;
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);

    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(winSize.width/4.5, (winSize.height - 50)/3);
    collectionSource.collectionViewLayout = layout;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self animationCollectionView];
}

-(void)animationCollectionView
{
    collectionSource.transform = CGAffineTransformMakeScale(20.0, 20.0);
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        collectionSource.transform = CGAffineTransformMakeScale(1.0, 1.0);
        collectionSource.center = self.view.center;
        
    } completion:nil];
}

- (void) channels:(NSArray *) channels
{
    filteredSource = [NSArray arrayWithArray:arrChannels];
    [collectionSource reloadData];
}

- (void) noResults
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"iSofa" message:@"Nops, zero results" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];

}

- (void) showActivity
{
    screenLocker.labelText = @"Please wait...";
    screenLocker.hidden = NO;
}

- (void) hideActivity
{
    screenLocker.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tracker

- (void)dispatchWithCategory:(NSString *)categoryName andActionName:(NSString *)actionName andLabel:(NSString *)labelName
{
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:categoryName
                                            action:actionName
                                             label:labelName
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}

#pragma mark - collection 

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 28;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistCell *cell = (PlaylistCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *strImage = [NSString stringWithFormat:@"%@.png", strChannels[(int)[indexPath row]]];
    cell.video.image = [UIImage imageNamed: strImage];
    
    // set name
    cell.video.layer.cornerRadius = 10;
    cell.name.text = (NSString *)strChannels[(int)[indexPath row]];
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    index = indexPath.row;
    
    // set search Channel name
    strSearchChannel = (NSString *)strChannels[(int)[indexPath row]];
    [self performSegueWithIdentifier:@"goPlaylist" sender:self];
}


-(BOOL)checkLogin:(NSString *)name
{
    if([name isEqualToString:@"Facebook"] || [name isEqualToString:@"History"])
    {
        User *user = [[GSUserSync sharedInstance] getSavedUser];
        if(!user) return NO;
    }
    
    return YES;
}


@end
