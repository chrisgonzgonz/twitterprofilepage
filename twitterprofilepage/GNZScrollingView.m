//
//  GNZScrollingView.m
//  twitterprofilepage
//
//  Created by Chris Gonzales on 1/19/16.
//  Copyright © 2016 share. All rights reserved.
//

#import "UIImage+ImageEffects.h"
#import "GNZScrollingView.h"

@interface GNZScrollingView () <UITableViewDelegate>
{
    CGFloat _headerHeight;
    CGFloat _subHeaderHeight;
    CGFloat _headerSwitchOffset;
    CGFloat _avatarImageSize;
    CGFloat _avatarImageCompressedSize;
    BOOL _barIsCollapsed;
    BOOL _barAnimationComplete;
}

@property (nonatomic) NSString *hashtagName;
@property (nonatomic) NSString *hashtagMeta;
@property (nonatomic) NSString *navTitle;
@property (nonatomic) NSString *navSubtitle;
@end
@implementation GNZScrollingView


- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initPrivate];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initPrivate];
}
- (instancetype)initPrivate {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        
    }
    return self;
    
}

- (void)configureWithHashtagName:(NSString *)hashtagName hashtagMeta:(NSString *)hashtagMeta navTitle:(NSString *)navTitle andNavSubtitle:(NSString *)navSubtitle {
    _hashtagName = hashtagName;
    _hashtagMeta = hashtagMeta;
    _navTitle = navTitle;
    _navSubtitle = navSubtitle;
    
    [self configureNavBar];
    _headerHeight = 100.0;
    _subHeaderHeight = 150.0;
    _avatarImageSize = 70;
    _avatarImageCompressedSize = 44;
    _barIsCollapsed = false;
    _barAnimationComplete = false;
    
    
    UIApplication* sharedApplication = [UIApplication sharedApplication];
    CGFloat kStatusBarHeight = sharedApplication.statusBarFrame.size.height;
    CGFloat kNavBarHeight =  [self.datasource navbarHeight];
    
    _headerSwitchOffset = _headerHeight - /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight)  - kStatusBarHeight - kNavBarHeight;
    
    NSMutableDictionary* views = [NSMutableDictionary new];
    views[@"super"] = self;
    
    UITableView* tableView = [[UITableView alloc] init];
    tableView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    self.tableView = tableView;
    self.tableView.delegate = self;
    [self addSubview:tableView];
    views[@"tableView"] = tableView;
    
    UIImage* bgImage = [UIImage imageNamed:@"vegetation.jpg"];
    _originalBackgroundImage = bgImage;
    
    UIImageView* headerImageView = [[UIImageView alloc] initWithImage:bgImage];
    headerImageView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    headerImageView.clipsToBounds = true;
    self.imageHeaderView = headerImageView;
    views[@"headerImageView"] = headerImageView;
    
    /* Not using autolayout for this one, because i don't really have control on how the table view is setting up the items.*/
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,
                                                                       _headerHeight - /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight) + _subHeaderHeight)];
    //tableHeaderView.backgroundColor = [UIColor purpleColor];
    [tableHeaderView addSubview:headerImageView];
    
    UIView* subHeaderPart = [self createSubHeaderView];// [[UIView alloc] init];
    subHeaderPart.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    // subHeaderPart.backgroundColor  = [UIColor greenColor];
    [tableHeaderView insertSubview:subHeaderPart belowSubview:headerImageView];
    views[@"subHeaderPart"] = subHeaderPart;
    
    
    
    tableView.tableHeaderView = tableHeaderView;
    
    
    
    UIImageView* avatarImageView = [self createAvatarImage];
    avatarImageView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    views[@"avatarImageView"] = avatarImageView;
    [tableHeaderView addSubview:avatarImageView];
    
    /*
     * At this point tableHeader views are ordered like this:
     * 0 : subHeaderPart
     * 1 : headerImageView
     * 2 : avatarImageView
     */
    
    /* This is important, or section header will 'overlaps' the navbar */
    //    self.automaticallyAdjustsScrollViewInsets = YES;
    
    
    //Now Let's do the layout
    NSArray* constraints;
    NSLayoutConstraint* constraint;
    NSString* format;
    NSDictionary* metrics = @{
                              @"headerHeight" : [NSNumber numberWithFloat:_headerHeight- /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight) ],
                              @"minHeaderHeight" : [NSNumber numberWithFloat:(kStatusBarHeight + kNavBarHeight)],
                              @"avatarSize" :[NSNumber numberWithFloat:_avatarImageSize],
                              @"avatarCompressedSize" :[NSNumber numberWithFloat:_avatarImageCompressedSize],
                              @"subHeaderHeight" :[NSNumber numberWithFloat:_subHeaderHeight],
                              };
    
    // ===== Table view should take all available space ========
    
    format = @"|-0-[tableView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self addConstraints:constraints];
    
    format = @"V:|-0-[tableView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self addConstraints:constraints];
    
    
    
    // ===== Header image view should take all available width ========
    
    format = @"|-0-[headerImageView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [tableHeaderView addConstraints:constraints];
    
    format = @"|-0-[subHeaderPart]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [tableHeaderView addConstraints:constraints];
    
    
    // ===== Header image view should not be smaller than nav bar and stay below navbar ========
    
    format = @"V:[headerImageView(>=minHeaderHeight)]-(subHeaderHeight@750)-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self addConstraints:constraints];
    
    format = @"V:|-(headerHeight)-[subHeaderPart(subHeaderHeight)]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self addConstraints:constraints];
    
    // ===== Header image view should stick to top of the 'screen'  ========
    
    NSLayoutConstraint* magicConstraint = [NSLayoutConstraint constraintWithItem:headerImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0];
    [self addConstraint: magicConstraint];
    
    
    
    // ===== avatar should stick to left with default margin spacing  ========
    [self addConstraint:[NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    //    format = @"|-[avatarImageView]";
    //    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    //    [self.view addConstraints:constraints];
    
    
    // === avatar is square
    constraint = [NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:avatarImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0];
    [self addConstraint: constraint];
    
    
    // ===== avatar size can be between avatarSize and avatarCompressedSize
    format = @"V:[avatarImageView(<=avatarSize@760,>=avatarCompressedSize@800)]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self addConstraints:constraints];
    
    
    constraint = [NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:(kStatusBarHeight + kNavBarHeight)];
    constraint.priority = 790;
    [self addConstraint: constraint];
    
    
    constraint = [NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:subHeaderPart attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-100.0];
    constraint.priority = 801;
    [self addConstraint: constraint];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fillBlurredImageCache];
    });
}

- (void)dealloc {
    _originalBackgroundImage = nil;
    [_blurredImageCache removeAllObjects];
    _blurredImageCache = nil;
}

- (UIView *)sectionView {
    if (!_sectionView) {
        UIView* sectionView = [[UIView alloc] init];
        
        NSArray* items = @[@"Tweets", @"Photos", @"Favorites"];
        
        UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
        segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        segmentedControl.selectedSegmentIndex = 0;
        [segmentedControl addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];
        self.segmentedControl = segmentedControl;
        
        
        NSMutableDictionary* views = [NSMutableDictionary new];
        views[@"super"] = self;
        //    views[@"segment"] = self.gnzControl;
        
        //    [sectionView addSubview:self.gnzControl];
        [sectionView addSubview:segmentedControl];
        sectionView.backgroundColor = [UIColor whiteColor];
        
        
        //    [sectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[segment]|" options:0 metrics:nil views:views]];
        //    [sectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[segment]|" options:0 metrics:nil views:views]];
        [sectionView addConstraint:[NSLayoutConstraint constraintWithItem:segmentedControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:sectionView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [sectionView addConstraint:[NSLayoutConstraint constraintWithItem:segmentedControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:sectionView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        
        
        UIView* separator = [UIView new];
        separator.translatesAutoresizingMaskIntoConstraints = NO;
        separator.backgroundColor = [UIColor lightGrayColor];
        [sectionView addSubview:separator];
        [sectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[separator]-0-|" options:0 metrics:nil views:@{@"separator": separator}]];
        [sectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separator(1)]-0-|" options:0 metrics:nil views:@{@"separator": separator}]];
        _sectionView = sectionView;
        [segmentedControl setWidth:100 forSegmentAtIndex:0];
        [segmentedControl setWidth:100 forSegmentAtIndex:2];
        
    }
    return _sectionView;
}

#pragma mark - NavBar configuration

- (void) configureNavBar {
        
        self.backgroundColor = [UIColor blueColor];
    
//        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
//        
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"dank" style:UIBarButtonItemStyleBordered target:self action:nil];
//    
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:nil];
    [self.delegate configureNavBar];
    [self switchToExpandedHeader];
}


- (void)switchToExpandedHeader
{
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setTranslucent:YES];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    self.navigationItem.titleView = nil;
    [self.delegate switchToExpandedHeader];
    
    _barAnimationComplete = false;
    self.imageHeaderView.image = self.originalBackgroundImage;
    
    
    //Inverse Z-Order of avatar Image view
    [self.tableView.tableHeaderView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];

}

- (void)switchToMinifiedHeader
{
    
    _barAnimationComplete = false;
    
    [self.delegate switchToMinifiedHeader];
//    self.navigationItem.titleView = self.customTitleView;
//    self.navigationController.navigationBar.clipsToBounds = YES;
//    
//    //Setting the view transform or changing frame origin has no effect, only this call does
//    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:60 forBarMetrics:UIBarMetricsDefault];
    
    //[self.navigationItem.titleView updateConstraintsIfNeeded];
    
    //Inverse Z-Order of avatar Image view
    [self.tableView.tableHeaderView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
}

#pragma mark - UIScrollView delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yPos = scrollView.contentOffset.y;
    if (yPos > _headerSwitchOffset && !_barIsCollapsed) {
        [self switchToMinifiedHeader];
        _barIsCollapsed = true;
    } else if (yPos < _headerSwitchOffset && _barIsCollapsed) {
        [self switchToExpandedHeader];
        _barIsCollapsed = false;
    }
    
    //appologies for the magic numbers
    if(yPos > _headerSwitchOffset +20 && yPos <= _headerSwitchOffset +20 +40){
        CGFloat delta = (40 +20 - (yPos-_headerSwitchOffset));
//        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:delta forBarMetrics:UIBarMetricsDefault];
        [self.delegate adjustNavTitleForDelta:delta];
       
        self.imageHeaderView.image = [self blurWithImageAt:((60-delta)/60.0)];

    }
    if(!_barAnimationComplete && yPos > _headerSwitchOffset +20 +40) {
//        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
        [self.delegate adjustNavTitleForDelta:0];
        self.imageHeaderView.image = [self blurWithImageAt:1.0];
        _barAnimationComplete = true;
    }
    
}

#pragma mark - privates
- (UIImageView*) createAvatarImage {
    UIImageView* avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar.jpg"]];
    avatarView.contentMode = UIViewContentModeScaleToFill;
    avatarView.layer.cornerRadius = 8.0;
    avatarView.layer.borderWidth = 3.0f;
    avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    avatarView.clipsToBounds = YES;
    return avatarView;
    
}

- (UIView*) customTitleView {
    if(!_customTitleView){
        UILabel* myLabel = [UILabel new];
        myLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        myLabel.text = @"My Handle";
        myLabel.text = self.navTitle;
        myLabel.numberOfLines =1;
        
        [myLabel setTextColor:[UIColor whiteColor]];
        [myLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        
        
        
        UILabel* smallText = [UILabel new];
        smallText.translatesAutoresizingMaskIntoConstraints = NO;
//        smallText.text = @"2 666 Plays";
        smallText.text = self.navSubtitle;
        smallText.numberOfLines =1;
        
        [smallText setTextColor:[UIColor whiteColor]];
        [smallText setFont:[UIFont boldSystemFontOfSize:10.0f]];
        
        
        UIView* wrapper = [UIView new];
        [wrapper addSubview:myLabel];
        [wrapper addSubview:smallText];
        
        
        
       [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[myLabel]-0-|" options:0 metrics:nil views:@{@"myLabel": myLabel,@"smallText":smallText}]];
        [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[myLabel]-2-[smallText]-0-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"myLabel": myLabel,@"smallText":smallText}]];
        
        //mmm.. it seems that i have to set it like this, if not the view size is set to 0 by the navabar layout.. 
        wrapper.frame = CGRectMake(0, 0, MAX(myLabel.intrinsicContentSize.width,smallText.intrinsicContentSize.width), myLabel.intrinsicContentSize.height + smallText.intrinsicContentSize.height + 2);
        
        wrapper.clipsToBounds = true;
        
        _customTitleView  = wrapper;
    }
    return _customTitleView;
}

- (UIView*) createSubHeaderView {
    UIView* view = [UIView new];
    
    NSMutableDictionary* views = [NSMutableDictionary new];
    views[@"super"] = self;
    
    UIButton* followButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    followButton.translatesAutoresizingMaskIntoConstraints = NO;
    [followButton setTitle:@"  Follow  " forState:UIControlStateNormal];
    followButton.layer.cornerRadius = 2;
    followButton.layer.borderWidth = 1;
    followButton.layer.borderColor = [UIColor blueColor].CGColor;
    
    views[@"followButton"] = followButton;
    [view addSubview:followButton];
    
    UILabel* nameLabel = [UILabel new];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    nameLabel.text = @"My Display Name";
    nameLabel.text = self.hashtagName;
    nameLabel.numberOfLines =1;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [nameLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    views[@"nameLabel"] = nameLabel;
    [view addSubview:nameLabel];

    UILabel* metaLabel = [UILabel new];
    metaLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    metaLabel.text = @"Bronx, NY - 1,234 Plays";
    metaLabel.text = self.hashtagMeta;
    metaLabel.numberOfLines =1;
    metaLabel.textAlignment = NSTextAlignmentCenter;
    [metaLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [metaLabel setTextColor:[UIColor darkGrayColor]];
    views[@"metaLabel"] = metaLabel;
    [view addSubview:metaLabel];
    
    
    NSArray* constraints;
    NSString* format;
    //NSDictionary* metrics;
    
    [followButton addConstraint:[NSLayoutConstraint constraintWithItem:followButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:180]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:followButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
//    format = @"|-[followButton]-|";
//    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
//    [view addConstraints:constraints];
    
    format = @"|-[nameLabel]-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = @"|-[metaLabel]-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = @"V:[nameLabel]-2-[metaLabel]-[followButton]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = @"V:|-60-[nameLabel]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}

- (UIImage *)blurWithImageAt:(CGFloat)percent
{
    
    NSNumber* keyNumber = @0;
    if(percent <= 0.1){
        keyNumber = @1;
    } else if(percent <= 0.2) {
        keyNumber = @2;
    } else if(percent <= 0.3) {
        keyNumber = @3;
    } else if(percent <= 0.4) {
        keyNumber = @4;
    } else if(percent <= 0.5) {
        keyNumber = @5;
    } else if(percent <= 0.6) {
        keyNumber = @6;
    } else if(percent <= 0.7) {
        keyNumber = @7;
    } else if(percent <= 0.8) {
       keyNumber = @8;
    } else if(percent <= 0.9) {
       keyNumber = @9;
    } else if(percent <= 1) {
       keyNumber = @10;
    }
    UIImage* image = [_blurredImageCache objectForKey:keyNumber];
    if(image == nil){
        //TODO if cache not yet built, just compute and put in cache
        return _originalBackgroundImage;
    }
    return image;
}


- (UIImage *)blurWithImageEffects:(UIImage *)image andRadius: (CGFloat) radius
{
    return [image applyBlurWithRadius:radius tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.5 maskImage:nil];
}

- (void) fillBlurredImageCache {
    CGFloat maxBlur = 30;
    self.blurredImageCache = [NSMutableDictionary new];
    for (int i = 0; i <= 10; i++)
    {
        self.blurredImageCache[[NSNumber numberWithInt:i]] = [self blurWithImageEffects:_originalBackgroundImage andRadius:(maxBlur * i/10)];
    }
}

#pragma mark - UITableView Delegate 
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
    return self.sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 44;
    NSUInteger rowCount = [self.datasource numberOfRows];
    if (indexPath.row == rowCount) {
        return MAX(0, self.frame.size.height - (cellHeight*rowCount + _subHeaderHeight + 8));
    }
    return cellHeight;
}


- (void)segmentSelected:(UISegmentedControl *)sender {
    [self.delegate segmentSelected:sender];
}
@end
