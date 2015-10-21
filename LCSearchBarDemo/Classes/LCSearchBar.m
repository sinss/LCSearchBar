//
//  LCSearchBar.m
//  SearchBarPOC
//
//  Created by leo.chang on 10/21/15.
//  Copyright © 2015 leo.chang. All rights reserved.
//

#import "LCSearchBar.h"

static CGFloat const kINSSearchBarInset = 11.0;
static CGFloat const kINSSearchBarImageSize = 22.0;
static NSTimeInterval const kINSSearchBarAnimationStepDuration = 0.25;

@interface LCSearchBar() <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) LCSearchBarState searchState;

@property (nonatomic, strong) UIView *searchFrame;
@property (nonatomic, strong) UITextField *searchField;

@property (nonatomic, strong) UIImageView *searchImageViewOn;
@property (nonatomic, strong) UIImageView *searchImageViewOff;
@property (nonatomic, strong) UIImageView *searchImageCircle;
@property (nonatomic, strong) UIImageView *searchImageCrossLeft;
@property (nonatomic, strong) UIImageView *searchImageCrossRight;

@property (nonatomic, assign) CGRect originalFrame;

@property (nonatomic, strong) UITapGestureRecognizer *keyboardDismissGestureRecognizer;

@end

@implementation LCSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), 34.0)];
    if (self)
    {
        [self initialize];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - initialization

- (void)initialize
{
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.searchFrame];
    
    [self.searchFrame addSubview:self.searchField];
    
    UIView *searchImageViewOnContainerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - kINSSearchBarInset - kINSSearchBarImageSize, (CGRectGetHeight(self.bounds) - kINSSearchBarImageSize) / 2, kINSSearchBarImageSize, kINSSearchBarImageSize)];
    searchImageViewOnContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.searchFrame addSubview:searchImageViewOnContainerView];
    
    _searchImageViewOn = [[UIImageView alloc] initWithFrame:searchImageViewOnContainerView.bounds];
    _searchImageViewOn.alpha = 0.0;
    _searchImageViewOn.image = [UIImage imageNamed:@"NavBarIconSearch_blue"];
    [searchImageViewOnContainerView addSubview:_searchImageViewOn];
    
    _searchImageCircle = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 18.0, 18.0)];
    _searchImageCircle.alpha = 0.0;
    _searchImageCircle.image = [UIImage imageNamed:@"NavBarIconSearchCircle_blue"];
    
    [searchImageViewOnContainerView addSubview:_searchImageCircle];
    
    _searchImageCrossLeft = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 14.0, 8.0, 8.0)];
    _searchImageCrossLeft.alpha = 0.0;
    _searchImageCrossLeft.image = [UIImage imageNamed:@"NavBarIconSearchBar_blue"];
    
    [searchImageViewOnContainerView addSubview:_searchImageCrossLeft];
    
    _searchImageCrossRight = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 7.0, 8.0, 8.0)];
    _searchImageCrossRight.alpha = 0.0;
    _searchImageCrossRight.image = [UIImage imageNamed:@"NavBarIconSearchBar2_blue"];
    
    [searchImageViewOnContainerView addSubview:_searchImageCrossRight];
    
    _searchImageViewOff = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - kINSSearchBarInset - kINSSearchBarImageSize, (CGRectGetHeight(self.bounds) - kINSSearchBarImageSize) / 2, kINSSearchBarImageSize, kINSSearchBarImageSize)];
    _searchImageViewOff.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _searchImageViewOff.alpha = 1.0;
    self.searchImageViewOff.image = [UIImage imageNamed:@"NavBarIconSearch_white"];
    
    [self.searchFrame addSubview:self.searchImageViewOff];
    
    UIView *tapableView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - (2 * kINSSearchBarInset) - kINSSearchBarImageSize, 0.0, (2 * kINSSearchBarInset) + kINSSearchBarImageSize, CGRectGetHeight(self.bounds))];
    tapableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [tapableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeStateIfPossible:)]];
    
    [self.searchFrame addSubview:tapableView];
    
    self.keyboardDismissGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    self.keyboardDismissGestureRecognizer.cancelsTouchesInView = NO;
    self.keyboardDismissGestureRecognizer.delegate = self;
				
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.searchField];
}

#pragma mark Accessors

- (UIView*)searchFrame
{
    if (!_searchFrame)
    {
        _searchFrame = [[UIView alloc] initWithFrame:self.bounds];
        _searchFrame.backgroundColor = [UIColor clearColor];
        _searchFrame.opaque = NO;
        _searchFrame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _searchFrame.layer.masksToBounds = YES;
        _searchFrame.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2;
        _searchFrame.layer.borderWidth = 0.5;
        _searchFrame.layer.borderColor = [UIColor clearColor].CGColor;
        _searchFrame.contentMode = UIViewContentModeRedraw;
    }
    return _searchFrame;
}

- (UITextField*)searchField
{
    if (!_searchField)
    {
        _searchField = [[UITextField alloc] initWithFrame:CGRectMake(kINSSearchBarInset, 3.0, CGRectGetWidth(self.bounds) - (2 * kINSSearchBarInset) - kINSSearchBarImageSize, CGRectGetHeight(self.bounds) - 6.0)];
        _searchField.borderStyle = UITextBorderStyleNone;
        _searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _searchField.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
        _searchField.textColor = [UIColor colorWithRed:17.0/255.0 green:190.0/255.0 blue:227.0/255.0 alpha:1.0];
        _searchField.alpha = 0.0;
        _searchField.delegate = self;
    }
    return _searchField;
}

#pragma mark - state change

- (void)changeStateIfPossible:(UITapGestureRecognizer *)gestureRecognizer
{
    switch (self.searchState)
    {
        case LCSearchBarStateNormal:
        {
            [self showSearchBar:gestureRecognizer];
        }
            break;
            
        case LCSearchBarStateVisible:
        {
            [self hideSearchBar:gestureRecognizer];
        }
            break;
            
        case LCSearchBarStateHasContent:
        {
            self.searchField.text = nil;
            [self textDidChange:nil];
        }
            break;
            
        case LCSearchBarStateTransitioning:
        {
            // Do nothing.
        }
            break;
    }
}

- (void)showSearchBar:(id)sender
{
    if (self.searchState == LCSearchBarStateNormal)
    {
        if ([self.delegate respondsToSelector:@selector(searchBar:willStartTransitioningToState:)])
        {
            [self.delegate searchBar:self willStartTransitioningToState:LCSearchBarStateVisible];
        }
        
        self.searchState = LCSearchBarStateTransitioning;
        
        self.searchField.text = nil;
        
        [UIView animateWithDuration:kINSSearchBarAnimationStepDuration animations:^{
            
            self.searchFrame.layer.borderColor = [UIColor whiteColor].CGColor;
            
            if ([self.delegate respondsToSelector:@selector(destinationFrameForSearchBar:)])
            {
                self.originalFrame = self.frame;
                
                self.frame = [self.delegate destinationFrameForSearchBar:self];
            }
            
        } completion:^(BOOL finished) {
            
            [self.searchField becomeFirstResponder];
            
            [UIView animateWithDuration:kINSSearchBarAnimationStepDuration * 2 animations:^{
                
                self.searchFrame.layer.backgroundColor = [UIColor whiteColor].CGColor;
                self.searchImageViewOff.alpha = 0.0;
                self.searchImageViewOn.alpha = 1.0;
                self.searchField.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                self.searchState = LCSearchBarStateVisible;
                
                if ([self.delegate respondsToSelector:@selector(searchBar:didEndTransitioningFromState:)])
                {
                    [self.delegate searchBar:self didEndTransitioningFromState:LCSearchBarStateNormal];
                }
            }];
        }];
    }
}

- (void)hideSearchBar:(id)sender
{
    if (self.searchState == LCSearchBarStateVisible || self.state == LCSearchBarStateHasContent)
    {
        [self.window endEditing:YES];
        
        if ([self.delegate respondsToSelector:@selector(searchBar:willStartTransitioningToState:)])
        {
            [self.delegate searchBar:self willStartTransitioningToState:LCSearchBarStateNormal];
        }
        
        self.searchField.text = nil;
        
        self.searchState = LCSearchBarStateTransitioning;
        
        [UIView animateWithDuration:kINSSearchBarAnimationStepDuration animations:^{
            
            if ([self.delegate respondsToSelector:@selector(destinationFrameForSearchBar:)])
            {
                self.frame = self.originalFrame;
            }
            
            self.searchFrame.layer.backgroundColor = [UIColor clearColor].CGColor;
            self.searchImageViewOff.alpha = 1.0;
            self.searchImageViewOn.alpha = 0.0;
            self.searchField.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:kINSSearchBarAnimationStepDuration animations:^{
                
                self.searchFrame.layer.borderColor = [UIColor clearColor].CGColor;
                
            } completion:^(BOOL finished) {
                
                self.searchImageCircle.frame = CGRectMake(0.0, 0.0, 18.0, 18.0);
                self.searchImageCrossLeft.frame = CGRectMake(14.0, 14.0, 8.0, 8.0);
                self.searchImageCircle.alpha = 0.0;
                self.searchImageCrossLeft.alpha = 0.0;
                self.searchImageCrossRight.alpha = 0.0;
                
                self.searchState = LCSearchBarStateNormal;
                
                if ([self.delegate respondsToSelector:@selector(searchBar:didEndTransitioningFromState:)])
                {
                    [self.delegate searchBar:self didEndTransitioningFromState:LCSearchBarStateVisible];
                }
            }];
        }];
    }
}

#pragma mark - keyboard handling

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([self.searchField isFirstResponder])
    {
        [self.window.rootViewController.view addGestureRecognizer:self.keyboardDismissGestureRecognizer];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if ([self.searchField isFirstResponder])
    {
        [self.window.rootViewController.view removeGestureRecognizer:self.keyboardDismissGestureRecognizer];
    }
}

- (void)dismissKeyboard:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.searchField isFirstResponder])
    {
        [self.window endEditing:YES];
        
        if (self.searchState == LCSearchBarStateVisible && self.searchField.text.length == 0)
        {
            [self hideSearchBar:nil];
        }
    }
}

#pragma mark - clear button handling

- (void)textDidChange:(NSNotification *)notification
{
    BOOL hasText = self.searchField.text.length != 0;
    
    if (hasText)
    {
        if (self.searchState == LCSearchBarStateVisible)
        {
            self.searchState = LCSearchBarStateTransitioning;
            
            self.searchImageViewOn.alpha = 0.0;
            self.searchImageCircle.alpha = 1.0;
            self.searchImageCrossLeft.alpha = 1.0;
            
            [UIView animateWithDuration:kINSSearchBarAnimationStepDuration animations:^{
                
                self.searchImageCircle.frame = CGRectMake(2.0, 2.0, 18.0, 18.0);
                self.searchImageCrossLeft.frame = CGRectMake(7.0, 7.0, 8.0, 8.0);
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:kINSSearchBarAnimationStepDuration animations:^{
                    
                    self.searchImageCrossRight.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                    
                    self.searchState = LCSearchBarStateHasContent;
                    
                }];
            }];
        }
    }
    else
    {
        if (self.searchState == LCSearchBarStateHasContent)
        {
            self.searchState = LCSearchBarStateTransitioning;
            
            [UIView animateWithDuration:kINSSearchBarAnimationStepDuration animations:^{
                
                self.searchImageCrossRight.alpha = 0.0;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:kINSSearchBarAnimationStepDuration animations:^{
                    
                    self.searchImageCircle.frame = CGRectMake(0.0, 0.0, 18.0, 18.0);
                    self.searchImageCrossLeft.frame = CGRectMake(14.0, 14.0, 8.0, 8.0);
                    
                } completion:^(BOOL finished) {
                    
                    self.searchImageViewOn.alpha = 1.0;
                    self.searchImageCircle.alpha = 0.0;
                    self.searchImageCrossLeft.alpha = 0.0;
                    
                    self.searchState = LCSearchBarStateVisible;
                    
                }];
            }];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidChange:)])
    {
        [self.delegate searchBarTextDidChange:self];
    }
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL retVal = YES;
    
    if ([self.delegate respondsToSelector:@selector(searchBarDidTapReturn:)])
    {
        [self.delegate searchBarDidTapReturn:self];
    }
    
    return retVal;
}

#pragma mark - gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL retVal = YES;
    
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self]))
    {
        retVal = NO;
    }
    
    return retVal;
}

#pragma mark - cleanup

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.searchField];
}
@end