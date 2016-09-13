//
//  ViewController.m
//  MultipleKeywordSearch
//
//  Created by Keyur on 12/09/16.
//  Copyright © 2016 Keyur Bhalodiya. All rights reserved.
//

#import "ViewController.h"

#define  WINDOW_WIDTH [UIScreen mainScreen].applicationFrame.size.width

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set Obeserver for update scroll view content height run time....
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateScrollHeight:)
                                                 name:@"updateScrollHeight"
                                               object:nil];
    
    _searchController.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _searchController.layer.borderWidth = 0.5f;

    _KBtextField.delegate = self;
    _KBtextField.dataSource = self;
    
    _KBtextField.textField.placeholder = @"Enter Keyword";
    
    isSearch = NO;
    _lblMessage.hidden = YES;
    
    arrSearchResult = [NSMutableArray new];
    arrSearchTags = [NSMutableArray new];
    
    arrCountries = [NSArray arrayWithObjects:@"Afghanistan", @"Akrotiri", @"Albania", @"Algeria", @"American Samoa", @"Andorra", @"Angola", @"Anguilla", @"Antarctica", @"Antigua and Barbuda", @"Argentina", @"Armenia", @"Aruba", @"Ashmore and Cartier Islands", @"Australia", @"Austria", @"Azerbaijan", @"The Bahamas", @"Bahrain", @"Bangladesh", @"Barbados", @"Bassas da India", @"Belarus", @"Belgium", @"Belize", @"Benin", @"Bermuda", @"Bhutan", @"Bolivia", @"Bosnia and Herzegovina", @"Botswana", @"Bouvet Island", @"Brazil", @"British Indian Ocean Territory", @"British Virgin Islands", @"Brunei", @"Bulgaria", @"Burkina Faso", @"Burma", @"Burundi", @"Cambodia", @"Cameroon", @"Canada", @"Cape Verde", @"Cayman Islands", @"Central African Republic", @"Chad", @"Chile", @"China", @"Christmas Island", @"Clipperton Island", @"Cocos (Keeling) Islands", @"Colombia", @"Comoros", @"Democratic Republic of the Congo", @"Republic of the Congo", @"Cook Islands", @"Coral Sea Islands", @"Costa Rica", @"Cote d'Ivoire", @"Croatia", @"Cuba", @"Cyprus", @"Czech Republic", @"Denmark", @"Dhekelia", @"Djibouti", @"Dominica", @"Dominican Republic", @"Ecuador", @"Egypt", @"El Salvador", @"Equatorial Guinea", @"Eritrea", @"Estonia", @"Ethiopia", @"Europa Island", @"Falkland Islands (Islas Malvinas)", @"Faroe Islands", @"Fiji", @"Finland", @"France", @"French Guiana", @"French Polynesia", @"French Southern and Antarctic Lands", @"Gabon", @"The Gambia", @"Gaza Strip", @"Georgia", @"Germany", @"Ghana", @"Gibraltar", @"Glorioso Islands", @"Greece", @"Greenland", @"Grenada", @"Guadeloupe", @"Guam", @"Guatemala", @"Guernsey", @"Guinea", @"Guinea-Bissau", @"Guyana", @"Haiti", @"Heard Island and McDonald Islands", @"Holy See (Vatican City)", @"Honduras", @"Hong Kong", @"Hungary", @"Iceland", @"India", @"Indonesia", @"Iran", @"Iraq", @"Ireland", @"Isle of Man", @"Israel", @"Italy", @"Jamaica", @"Jan Mayen", @"Japan", @"Jersey", @"Jordan", @"Juan de Nova Island", @"Kazakhstan", @"Kenya", @"Kiribati", @"North Korea", @"South Korea", @"Kuwait", @"Kyrgyzstan", @"Laos", @"Latvia", @"Lebanon", @"Lesotho", @"Liberia", @"Libya", @"Liechtenstein", @"Lithuania", @"Luxembourg", @"Macau", @"Macedonia", @"Madagascar", @"Malawi", @"Malaysia", @"Maldives", @"Mali", @"Malta", @"Marshall Islands", @"Martinique", @"Mauritania", @"Mauritius", @"Mayotte", @"Mexico", @"Federated States of Micronesia", @"Moldova", @"Monaco", @"Mongolia", @"Montserrat", @"Morocco", @"Mozambique", @"Namibia", @"Nauru", @"Navassa Island", @"Nepal", @"Netherlands", @"Netherlands Antilles", @"New Caledonia", @"New Zealand", @"Nicaragua", @"Niger", @"Nigeria", @"Niue", @"Norfolk Island", @"Northern Mariana Islands", @"Norway", @"Oman", @"Pakistan", @"Palau", @"Panama", @"Papua New Guinea", @"Paracel Islands", @"Paraguay", @"Peru", @"Philippines", @"Pitcairn Islands", @"Poland", @"Portugal", @"Puerto Rico", @"Qatar", @"Reunion", @"Romania", @"Russia", @"Rwanda", @"Saint Helena", @"Saint Kitts and Nevis", @"Saint Lucia", @"Saint Pierre and Miquelon", @"Saint Vincent and the Grenadines", @"Samoa", @"San Marino", @"Sao Tome and Principe", @"Saudi Arabia", @"Senegal", @"Serbia", @"Montenegro", @"Seychelles", @"Sierra Leone", @"Singapore", @"Slovakia", @"Slovenia", @"Solomon Islands", @"Somalia", @"South Africa", @"South Georgia and the South Sandwich Islands", @"Spain", @"Spratly Islands", @"Sri Lanka", @"Sudan", @"Suriname", @"Svalbard", @"Swaziland", @"Sweden", @"Switzerland", @"Syria", @"Taiwan", @"Tajikistan", @"Tanzania", @"Thailand", @"Tibet", @"Timor-Leste", @"Togo", @"Tokelau", @"Tonga", @"Trinidad and Tobago", @"Tromelin Island", @"Tunisia", @"Turkey", @"Turkmenistan", @"Turks and Caicos Islands", @"Tuvalu", @"Uganda", @"Ukraine", @"United Arab Emirates", @"United Kingdom", @"United States", @"Uruguay", @"Uzbekistan", @"Vanuatu", @"Venezuela", @"Vietnam", @"Virgin Islands", @"Wake Island", @"Wallis and Futuna", @"West Bank", @"Western Sahara", @"Yemen", @"Zambia", @"Zimbabwe", nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [_KBtextField.textField becomeFirstResponder];
}

#pragma mark TableView Delegate method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return isSearch ? arrSearchResult.count : (arrSearchTags.count > 0 ? arrSearchTags.count : arrCountries.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (isSearch) {
        cell.textLabel.text = [arrSearchResult objectAtIndex:indexPath.row];
    }
    else{
        if (arrSearchTags.count > 0) {
            cell.textLabel.text = [arrSearchTags objectAtIndex:indexPath.row];
        }
        else{
            cell.textLabel.text = [arrCountries objectAtIndex:indexPath.row];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isSearch) {
        if ([arrSearchTags containsObject:[arrSearchResult objectAtIndex:indexPath.row]]) {
            return;
        }
        [arrSearchTags addObject:[arrSearchResult objectAtIndex:indexPath.row]];
    }
    else{
        if ([arrSearchTags containsObject:[arrCountries objectAtIndex:indexPath.row]]) {
            return;
        }
        [arrSearchTags addObject:[arrCountries objectAtIndex:indexPath.row]];
    }
    [self reloadKBTextField];
}

#pragma mark - KBTextFieldToken Datasource

- (CGFloat)textTokenHeight:(KBMultipleKeywordTextField *)textToken
{
    return 30;
}

- (NSUInteger)NoOfTextToken:(KBMultipleKeywordTextField *)textToken
{
    return arrSearchTags.count;
}

- (UIView *)tokenField:(KBMultipleKeywordTextField *)tokenField viewForTokenAtIndex:(NSUInteger)index
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"KBMultipleKeywordTextField" owner:nil options:nil];
    UIView *view = nibContents[0];
    CGFloat borderWidth = 0.5;
    view.frame = CGRectInset(view.frame, -borderWidth, -borderWidth);
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = borderWidth;

    UILabel *label = (UILabel *)[view viewWithTag:1];
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [btnCancel setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(tokenDeleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnCancel];
    
    label.text = [arrSearchTags objectAtIndex:index];
    CGSize size = [label sizeThatFits:CGSizeMake(1000, 40)];
    label.frame = CGRectMake(3, (view.frame.size.height-label.frame.size.height)/2, size.width, label.frame.size.height);
    btnCancel.frame = CGRectMake(label.frame.origin.x+label.frame.size.width+5, (label.frame.size.height-btnCancel.frame.size.height)/2, btnCancel.frame.size.width, btnCancel.frame.size.height);
    label.backgroundColor = [UIColor clearColor];
    
    view.frame = CGRectMake(0, 0, btnCancel.frame.origin.x+btnCancel.frame.size.width, 30);
    
    return view;
}

-(void)reloadKBTextField{
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        isSearch = NO;
        [_KBtextField refreshData:YES];
        [_tbl reloadData];
    });
}

#pragma mark - KBMultipleKeywordTextField Delegate

- (CGFloat)textTokenSpace:(KBMultipleKeywordTextField *)tokenField{
    return 5;
}

- (void)tokenDeleteButtonPressed:(UIButton *)tokenButton
{
    NSUInteger index = [_KBtextField indexOfTextField:tokenButton.superview];
    if (index != NSNotFound) {
        [arrSearchTags removeObjectAtIndex:index];
    }
    if ([arrSearchTags count]>0) {
        [self reloadKBTextField];
    }
    else{
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_KBtextField refreshData:YES];
            if (arrSearchTags.count==0) {
                isSearch = NO;
                [_tbl reloadData];
            }
        });
        [_tbl setContentOffset:CGPointZero animated:YES];
    }
}

- (void)textToken:(KBMultipleKeywordTextField *)textToken didDeleteAtIndex:(NSUInteger)index
{
    [arrSearchTags removeObjectAtIndex:index];
    [self reloadKBTextField];
}

- (BOOL)textTokenShouldEndEditing:(KBMultipleKeywordTextField *)textField
{
    return YES;
}

- (void)textToken:(KBMultipleKeywordTextField *)textToken didTextChanged:(NSString *)text{
    [arrSearchResult removeAllObjects];
    NSArray *filtered;
    NSPredicate *myPredicate = [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", text];
    filtered = [arrCountries filteredArrayUsingPredicate:myPredicate];
    [arrSearchResult addObjectsFromArray:filtered];
    isSearch = YES;
    if (arrSearchResult.count == 0) {
        _lblMessage.hidden = NO;
        _tbl.hidden = YES;
    }
    else{
        _lblMessage.hidden = YES;
        _tbl.hidden = NO;
    }
    [_tbl reloadData];
}

#pragma mark - update Scrollview contain height

- (void) updateScrollHeight:(NSNotification *) notification
{
    [_searchController setContentSize:CGSizeMake(0, [[notification.object objectForKey:@"height"] floatValue])];
    _KBtextField.frame = CGRectMake(_KBtextField.frame.origin.x, _KBtextField.frame.origin.y, _KBtextField.frame.size.width, [[notification.object objectForKey:@"height"] floatValue]);
    CGPoint bottomOffset = CGPointMake(0, _searchController.contentSize.height - _searchController.bounds.size.height);
    [_searchController setContentOffset:bottomOffset animated:YES];
}

#pragma mark - cancel button action

- (IBAction)btnClkCancel:(id)sender {
    [arrSearchTags removeAllObjects];
    [_KBtextField refreshData:NO];
    isSearch = NO;
    _tbl.hidden = NO;
    _lblMessage.hidden = YES;
    [_tbl reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
