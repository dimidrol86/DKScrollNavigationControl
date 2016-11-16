//
//  ViewController.m
//  test
//
//  Created by Dimidrol on 11.11.16.
//  Copyright © 2016 Finch. All rights reserved.
//

#import "ViewController.h"

#import "DKScrollNavigationControl.h"
#import <PureLayout/PureLayout.h>


@interface ViewController () <DKScrollNavigationControlDelegate>
{
    UIScrollView * scrol;
    NSArray *src;
    DKScrollNavigationControl *scroll;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    src=@[@"Test",@"Test2",@"Test3",@"Test4"];
    
    scroll = [[DKScrollNavigationControl alloc] initWithFrame:CGRectZero];
    scroll.delegateVC = self;
    scroll.textColor = [UIColor orangeColor];
    scroll.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:scroll];
    [scroll autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [scroll autoSetDimensionsToSize:CGSizeMake(150, 50)];
    [scroll autoAlignAxisToSuperviewAxis:ALAxisVertical];

    scrol = [[UIScrollView alloc] initWithFrame:CGRectZero];
    NSLog(@"%f,%f",scrol.contentSize.width,scrol.contentSize.height);
    scrol.backgroundColor = [UIColor whiteColor];
    scrol.pagingEnabled = true;
    [self.view addSubview:scrol];
    [scrol autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:scroll];
    [scrol autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    
    
    scroll.asyncScrollView = scrol;

}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [scroll setSource:src];
    scrol.contentSize = CGSizeMake(CGRectGetWidth(scrol.bounds) * src.count, CGRectGetHeight(scrol.bounds));
    NSLog(@"%f,%f",scrol.contentSize.width,scrol.contentSize.height);

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DKScrollNavigationControlDelegate 

-(void)DKScrollNavigationControlFinishPageChanging:(NSInteger)page{
    NSLog(@"Page : %ld", (long)page);
}






@end
