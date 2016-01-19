//
//  ViewController2.m
//  twitterprofilepage
//
//  Created by Chris Gonzales on 1/19/16.
//  Copyright © 2016 share. All rights reserved.
//

#import "ViewController2.h"
#import "GNZScrollingView.h"

@interface ViewController2 () <UITableViewDataSource, GNZScrollingViewDelegate, GNZScrollingViewDatasource> {
    NSUInteger _rowCount;

}
@property (nonatomic) GNZScrollingView *scrollingView;
@end
@implementation ViewController2

- (void)loadView {
    [super loadView];
    self.scrollingView = [GNZScrollingView new];
//    self.scrollingView.translatesAutoresizingMaskIntoConstraints = NO;
    self.view = self.scrollingView;
//    [self.view addSubview: self.scrollingView];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollingView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_scrollingView)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollingView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_scrollingView)]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollingView.delegate = self;
    self.scrollingView.datasource = self;
    [self.scrollingView configureWithHashtagName:@"Bronx Science Wolverines" hashtagMeta:@"Bronx, NY - 1,234 Plays" navTitle:@"Bronx Science Wolverines" andNavSubtitle:@"1,234 Plays"];
    self.scrollingView.tableView.dataSource = self;
    _rowCount = 25;
//    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)segmentSelected:(UISegmentedControl *)sender {
    NSLog(@"segmenet selected");
    switch (sender.selectedSegmentIndex) {
        case 1:
            _rowCount = 2;
            break;
        case 2:
            _rowCount = 30;
        case 0:
            _rowCount = 24;
    }
    [self.scrollingView.tableView reloadData];
}

#pragma mark - GNZScrollingViewDatasource
- (CGFloat)navbarHeight {
    
    return self.navigationController.navigationBar.frame.size.height;
}

- (NSUInteger)numberOfRows {
    return _rowCount;
}

#pragma mark - GNZScrollingViewDelegate
- (void) configureNavBar {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"dank" style:UIBarButtonItemStyleBordered target:self action:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:nil];
}
- (void)switchToExpandedHeader {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = nil;
}
- (void)switchToMinifiedHeader {
    self.navigationItem.titleView = self.scrollingView.customTitleView;
    self.navigationController.navigationBar.clipsToBounds = YES;
    
    //Setting the view transform or changing frame origin has no effect, only this call does
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:60 forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationItem.titleView updateConstraintsIfNeeded];
}
- (void)adjustNavTitleForDelta:(CGFloat)delta {
        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:delta forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rowCount + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [UITableViewCell new];
    
    if (indexPath.row == _rowCount) {
        return cell;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Item %lu", indexPath.row+1];
    
    return cell;
}

@end
