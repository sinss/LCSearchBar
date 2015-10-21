//
//  LCSearchBar.h
//  SearchBarPOC
//
//  Created by leo.chang on 10/21/15.
//  Copyright © 2015 leo.chang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LCSearchBarState)
{
    LCSearchBarStateNormal = 0,
    LCSearchBarStateVisible,
    LCSearchBarStateHasContent,
    LCSearchBarStateTransitioning,
};

@protocol LCSearchBarDelegate;
@interface LCSearchBar : UIControl

@property (nonatomic, readonly) LCSearchBarState searchState;
@property (nonatomic, readonly) UITextField *searchField;
@property (nonatomic, weak) id <LCSearchBarDelegate> delegate;

@end

@protocol LCSearchBarDelegate <NSObject>

- (CGRect)destinationFrameForSearchBar:(LCSearchBar *)searchBar;
- (void)searchBar:(LCSearchBar *)searchBar willStartTransitioningToState:(LCSearchBarState)destinationState;
- (void)searchBar:(LCSearchBar *)searchBar didEndTransitioningFromState:(LCSearchBarState)previousState;
- (void)searchBarDidTapReturn:(LCSearchBar *)searchBar;
- (void)searchBarTextDidChange:(LCSearchBar *)searchBar;


@end