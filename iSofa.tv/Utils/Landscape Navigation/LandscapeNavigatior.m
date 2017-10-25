//
//  LandscapeNavigatior.m
//  iSofa.tv
//
//  Created by Sorin's Macbook Pro on 18/10/14.
//  Copyright (c) 2014 Sorin's Macbook Pro. All rights reserved.
//

#import "LandscapeNavigatior.h"

@interface LandscapeNavigatior ()

@end

@implementation LandscapeNavigatior

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}


@end
