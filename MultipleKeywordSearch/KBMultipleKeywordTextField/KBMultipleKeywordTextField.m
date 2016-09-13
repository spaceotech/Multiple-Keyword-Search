//
//  KBMultipleKeywordTextField.m
//  MultipleKeywordSearch
//
//  Created by Keyur on 12/09/16.
//  Copyright © 2016 Keyur Bhalodiya. All rights reserved.
//

#import "KBMultipleKeywordTextField.h"

@interface KBMultipleKeywordSearch ()
- (NSString *)KBtextField;
@end

@implementation KBMultipleKeywordSearch

- (void)setText:(NSString *)text
{
    if ([text isEqualToString:@""]) {
        if (((KBMultipleKeywordTextField *)self.superview).NoOfTextField > 0) {
            text = @"\u200B";
        }
    }
    [super setText:text];
}

- (NSString *)text
{
    return [super.text stringByReplacingOccurrencesOfString:@"\u200B" withString:@""];
}

- (NSString *)KBtextField
{
    return super.text;
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //Prevent zooming
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        gestureRecognizer.enabled = NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
    return;
}

@end

@interface KBMultipleKeywordTextField () <UITextFieldDelegate>
@property (nonatomic, strong) KBMultipleKeywordSearch *textField;
@property (nonatomic, strong) NSMutableArray *tokenViews;
@property (nonatomic, strong) NSString *tempTextFieldText;
@end

@implementation KBMultipleKeywordTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (BOOL)focusOnTextField
{
    [self.textField becomeFirstResponder];
    return YES;
}

#pragma mark -

- (void)setup
{
    self.clipsToBounds = YES;
    [self addTarget:self action:@selector(focusOnTextField) forControlEvents:UIControlEventTouchUpInside];
    
    self.textField = [[KBMultipleKeywordSearch alloc] init];
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self refreshData:NO];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self invalidateIntrinsicContentSize];
    
    NSEnumerator *tokenEnumerator = [self.tokenViews objectEnumerator];
    [self enumerateItemRectsUsingBlock:^(CGRect itemRect) {
        UIView *token = [tokenEnumerator nextObject];
        [token setFrame:itemRect];
    }];
    
}

- (CGSize)intrinsicContentSize
{
    if (!self.tokenViews) {
        return CGSizeZero;
    }
    
    __block CGRect totalRect = CGRectNull;
    [self enumerateItemRectsUsingBlock:^(CGRect itemRect) {
        totalRect = CGRectUnion(itemRect, totalRect);
    }];
    return totalRect.size;
}

#pragma mark - Public

- (void)refreshData:(BOOL)isKeyboardOpen
{
    // clear
    for (UIView *view in self.tokenViews) {
        [view removeFromSuperview];
    }
    self.tokenViews = [NSMutableArray array];
    
    if (self.dataSource) {
        NSUInteger count = [self.dataSource NoOfTextToken:self];
        for (int i = 0 ; i < count ; i++) {
            UIView *tokenView = [self.dataSource tokenField:self viewForTokenAtIndex:i];
            //            tokenView.autoresizingMask = UIViewAutoresizingNone;
            [self addSubview:tokenView];
            //            NSLog(@"token field width %f",tokenView.frame.size.width);
            [self.tokenViews addObject:tokenView];
        }
    }
    
    [self.tokenViews addObject:self.textField];
    [self addSubview:self.textField];
    self.textField.frame = (CGRect) {0,0,150,[self.dataSource textTokenHeight:self]};
    [self invalidateIntrinsicContentSize];
    [self.textField setText:@""];
    if (isKeyboardOpen) {
        [self.textField becomeFirstResponder];
    }
}

- (NSUInteger)NoOfTextField
{
    return self.tokenViews.count - 1;
}

- (NSUInteger)indexOfTextField:(UIView *)view
{
    return [self.tokenViews indexOfObject:view];
}


#pragma mark - Private

- (void)enumerateItemRectsUsingBlock:(void (^)(CGRect itemRect))block
{
    NSUInteger rowCount = 0;
    CGFloat x = 0, y = 0;
    CGFloat margin = 0;
    CGFloat lineHeight = [self.dataSource textTokenHeight:self];
    
    if ([self.delegate respondsToSelector:@selector(textTokenSpace:)]) {
        margin = [self.delegate textTokenSpace:self];
    }
    
    for (UIView *token in self.tokenViews) {
        // Here -64 is Cancel button width..
        CGFloat width = MAX((CGRectGetWidth(self.bounds)), CGRectGetWidth(token.frame));
        CGFloat tokenWidth = MIN((CGRectGetWidth(self.bounds)), CGRectGetWidth(token.frame));
        if (x > width - tokenWidth) {
            y += lineHeight + margin;
            x = 0;
            rowCount = 0;
        }
        
        if ([token isKindOfClass:[KBMultipleKeywordSearch class]]) {
            UITextField *textField = (UITextField *)token;
            CGSize size = [textField sizeThatFits:(CGSize){(CGRectGetWidth(self.bounds)), lineHeight}];
            size.height = lineHeight;
            if (size.width > (CGRectGetWidth(self.bounds))) {
                size.width = (CGRectGetWidth(self.bounds));
            }
            token.frame = (CGRect){{x, y}, size};
            if (token.frame.origin.y>64.0) {
                NSDictionary *dictHeight = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",token.frame.origin.y+token.frame.size.height],@"height", nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"updateScrollHeight"object:dictHeight];
            }
        }
        
        block((CGRect){x, y, tokenWidth, token.frame.size.height});
        x += tokenWidth + margin;
        rowCount++;
    }
}

#pragma mark - TextField

- (void)textFieldDidBeginEditing:(KBMultipleKeywordSearch *)textField
{
    self.tempTextFieldText = [textField KBtextField];
    
    if ([self.delegate respondsToSelector:@selector(textTokenDidBeginEditing:)]) {
        [self.delegate textTokenDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(KBMultipleKeywordSearch *)textField
{
    /*
     if ([self.delegate respondsToSelector:@selector(tokenFieldShouldEndEditing:)]) {
     return [self.delegate tokenFieldShouldEndEditing:self];
     }
     */
    return YES;
}

- (void)textFieldDidEndEditing:(KBMultipleKeywordSearch *)textField
{
    if ([self.delegate respondsToSelector:@selector(textTokenDidEndEditing:)]) {
        [self.delegate textTokenDidEndEditing:self];
    }
}

- (void)textFieldDidChange:(KBMultipleKeywordSearch *)textField
{
    if ([[textField KBtextField] isEqualToString:@""]) {
        textField.text = @"\u200B";
        
        if ([self.tempTextFieldText isEqualToString:@"\u200B"]) {
            if (self.tokenViews.count > 1) {
                NSUInteger removeIndex = self.tokenViews.count - 2;
                [self.tokenViews[removeIndex] removeFromSuperview];
                [self.tokenViews removeObjectAtIndex:removeIndex];
                
                [self.textField setText:@""];
                
                if ([self.delegate respondsToSelector:@selector(textToken:didDeleteAtIndex:)]) {
                    [self.delegate textToken:self didDeleteAtIndex:removeIndex];
                }
            }
        }
    }
    
    self.tempTextFieldText = [textField KBtextField];
    [self invalidateIntrinsicContentSize];
    
    if ([self.delegate respondsToSelector:@selector(textToken:didTextChanged:)]) {
        [self.delegate textToken:self didTextChanged:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /*
     if ([self.delegate respondsToSelector:@selector(tokenField:didReturnWithText:)]) {
     [self.delegate tokenField:self didReturnWithText:textField.text];
     }
     */
    [textField resignFirstResponder];
    return YES;
}

@end
