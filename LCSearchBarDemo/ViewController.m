//
//  ViewController.m
//  LCSearchBarDemo
//
//  Created by leo.chang on 10/21/15.
//  Copyright © 2015 leo.chang. All rights reserved.
//

#import "ViewController.h"
#import "LCSearchBar.h"

@interface ViewController () <LCSearchBarDelegate>

@property (nonatomic, strong) LCSearchBar *searchBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _searchBar = [[LCSearchBar alloc] initWithFrame:CGRectMake(20.0, 140.0, 44.0, 34.0)];
    _searchBar.delegate = self;
    
    [self.view addSubview:_searchBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - search bar delegate

- (CGRect)destinationFrameForSearchBar:(LCSearchBar *)searchBar
{
    return CGRectMake(20.0, 140.0, CGRectGetWidth(self.view.bounds) - 40.0, 34.0);
}

- (void)searchBar:(LCSearchBar *)searchBar willStartTransitioningToState:(LCSearchBarState)destinationState
{
    // Do whatever you deem necessary.
}

- (void)searchBar:(LCSearchBar *)searchBar didEndTransitioningFromState:(LCSearchBarState)previousState
{
    // Do whatever you deem necessary.
}

- (void)searchBarDidTapReturn:(LCSearchBar *)searchBar
{
    // Do whatever you deem necessary.
    // Access the text from the search bar like searchBar.searchField.text
}

- (void)searchBarTextDidChange:(LCSearchBar *)searchBar
{
    // Do whatever you deem necessary.
    // Access the text from the search bar like searchBar.searchField.text
}

@end
