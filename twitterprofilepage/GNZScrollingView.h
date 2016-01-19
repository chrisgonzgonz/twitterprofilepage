//
//  GNZScrollingView.h
//  twitterprofilepage
//
//  Created by Chris Gonzales on 1/19/16.
//  Copyright © 2016 share. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNZSegmentedControl.h"

@protocol GNZScrollingViewDatasource <NSObject>
- (CGFloat)navbarHeight;
- (NSUInteger)numberOfRows;
@end
@protocol GNZScrollingViewDelegate <NSObject>
- (void) configureNavBar;
- (void)switchToExpandedHeader;
- (void)switchToMinifiedHeader;
- (void)adjustNavTitleForDelta:(CGFloat)delta;
- (void)segmentSelected:(UISegmentedControl *)segmentedControl;
@end
@interface GNZScrollingView : UIView
@property (weak, nonatomic) id <GNZScrollingViewDatasource> datasource;
@property (weak, nonatomic) id <GNZScrollingViewDelegate> delegate;
@property (weak) UITableView *tableView;
@property (weak) UIImageView *imageHeaderView;
@property (weak) UIVisualEffectView *visualEffectView;
@property (strong,nonatomic) UIView *customTitleView;
@property (strong) UIImage *originalBackgroundImage;

@property (strong) NSMutableDictionary* blurredImageCache;

@property (nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic) NSArray *segmentViewControllers;
@property (nonatomic) UIView *sectionView;
- (void)configureWithHashtagName:(NSString *)hashtagName hashtagMeta:(NSString *)hashtagMeta navTitle:(NSString *)navTitle andNavSubtitle:(NSString *)navSubtitle;


@end
