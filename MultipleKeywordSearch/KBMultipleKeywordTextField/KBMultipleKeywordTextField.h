//
//  KBMultipleKeywordTextField.h
//  MultipleKeywordSearch
//
//  Created by Keyur on 12/09/16.
//  Copyright © 2016 Keyur Bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KBMultipleKeywordTextField;

@interface KBMultipleKeywordSearch : UITextField

@end

@protocol KBTextFieldTokenDatasource <NSObject>

- (CGFloat)textTokenHeight:(KBMultipleKeywordTextField *)textToken;
- (NSUInteger)NoOfTextToken:(KBMultipleKeywordTextField *)textToken;
- (UIView *)tokenField:(KBMultipleKeywordTextField *)textToken viewForTokenAtIndex:(NSUInteger)index;

@end


@protocol KBTextFieldTokenDelegate <NSObject>
@optional
- (CGFloat)textTokenSpace:(KBMultipleKeywordTextField *)tokenField;
- (void)textToken:(KBMultipleKeywordTextField *)textToken didDeleteAtIndex:(NSUInteger)index;
- (void)textToken:(KBMultipleKeywordTextField *)textToken didReturnWithText:(NSString *)text;
- (void)textToken:(KBMultipleKeywordTextField *)textToken didTextChanged:(NSString *)text;
- (void)textTokenDidBeginEditing:(KBMultipleKeywordTextField *)textToken;
- (BOOL)textTokenShouldEndEditing:(KBMultipleKeywordTextField *)textToken;
- (void)textTokenDidEndEditing:(KBMultipleKeywordTextField *)textToken;
@end

@interface KBMultipleKeywordTextField : UIControl

@property (nonatomic, weak) IBOutlet id<KBTextFieldTokenDatasource> dataSource;
@property (nonatomic, weak) IBOutlet id<KBTextFieldTokenDelegate> delegate;

@property (nonatomic, strong, readonly) KBMultipleKeywordSearch *textField;

- (void)refreshData:(BOOL)isKeyboardOpen;
- (NSUInteger)NoOfTextField;
- (NSUInteger)indexOfTextField:(UIView *)view;

@end