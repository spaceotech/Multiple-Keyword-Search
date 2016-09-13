//
//  ViewController.h
//  MultipleKeywordSearch
//
//  Created by Keyur on 12/09/16.
//  Copyright © 2016 Keyur Bhalodiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBMultipleKeywordTextField.h"

@interface ViewController : UIViewController<KBTextFieldTokenDatasource,KBTextFieldTokenDelegate>{
    NSArray *arrCountries;
    NSMutableArray *arrSearchResult;
    NSMutableArray *arrSearchTags;
    BOOL isSearch;
}

@property (weak, nonatomic) IBOutlet UIScrollView *searchController;
@property (weak, nonatomic) IBOutlet KBMultipleKeywordTextField *KBtextField;
@property (weak, nonatomic) IBOutlet UITableView *tbl;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;

@end

