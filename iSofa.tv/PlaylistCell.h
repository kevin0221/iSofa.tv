//
//  PlaylistCell.h
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 17/06/15.
//  Copyright (c) 2015 Sorin's Macbook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistCell : UICollectionViewCell

@property (nonatomic,strong) IBOutlet UIImageView *avatar;
@property (nonatomic,strong) IBOutlet UIImageView *video;
@property (nonatomic,strong) IBOutlet UILabel     *user;
@property (nonatomic,strong) IBOutlet UILabel     *name;

@end
