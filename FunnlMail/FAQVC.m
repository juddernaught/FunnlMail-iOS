//
//  FAQVC.m
//  FunnlMail
//
//  Created by Pranav Herur on 8/14/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FAQVC.h"
#import "UIColor+HexString.h"
#import <Mixpanel/Mixpanel.h>

@interface FAQVC ()

@end
NSArray *questions;
NSArray *answers;

@implementation FAQVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
#ifdef TRACK_MIXPANEL
    [[Mixpanel sharedInstance] track:@"FAQ Pressed"]; // Viewed Help/FAQS section
#endif
    
    [super viewDidLoad];
    [self.navigationController setTitle:@"Help (FAQs)"];
    self.navigationItem.title = @"Help (FAQs)";
    UITableView *faq = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) style:UITableViewStylePlain];
    faq.dataSource = self;
    faq.delegate = self;
    
    [self.view addSubview:faq];
    questions = [NSArray arrayWithObjects:@"How can Funnl Mail make mobile email easier & better?",@"What is a Funnl?",@"How are Funnls different from Gmail filters?",@"How can I create a Funnl?",@"If I create a Funnl, do emails in that Funnl move out of my Primary inbox?",@"If I delete a Funnl, does it delete my emails under that Funnl?",@"Does Funnl Mail change anything on my desktop Gmail or on other devices/ clients?", nil];
    answers = [NSArray arrayWithObjects:@"Funnl Mail (iOS) is built to help you find your most important emails faster on your mobile. With just 5-7 effective Funnls like VIP, clients, team, friends & family and news/ shopping, you can browse through your list of 100+ emails in lesser time and still stay on top!",@"Funnl (filter “from:”) is a filtered set of emails from a specific sender/ group of senders. With Funnls, you can organize your emails the way you like. You can create a Funnl for work teams or clients, and other Funnls for friends, family or even news",@"You can create Funnls easily when reading emails on your iPhones. Funnls work more like Gmail labels than folders – emails from important senders can go into more than one Funnl at the same time if you choose",@"Super easy – simply swipe (right to left) any email and Funnl Mail will automatically create a new Funnl with the sender/ s who sent you that particular email. Funnls organize all previous emails in your inbox from these senders as well as new emails received from these senders going forward",@"No – not by default. However you can choose to take out all emails in a Funnl from the primary inbox if you want to (eg. for shopping promotions or listserves)",@"No – Funnl is only a filter rule. Deleting a Funnl will not delete any of your emails. It will simply delete that label from those emails",@"No – Funnl Mail only organizes your emails on the iPhone. It does not change anything on your desktop Gmail or anywhere else. However when you mark emails read, archive or trash them, we do sync that with your Gmail server", nil];
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return questions.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize myStringSize = [[answers objectAtIndex:indexPath.section] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:12] constrainedToSize:CGSizeMake(WIDTH - 40, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    return myStringSize.height + 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGSize myStringSize = [[questions objectAtIndex:section] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:14] constrainedToSize:CGSizeMake(WIDTH - 40, 1000) lineBreakMode:NSLineBreakByWordWrapping];
//    if (myStringSize.height < 20) {
//        return 20;
//    }
    return myStringSize.height + 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section  {
    return [questions objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
//    view.backgroundColor = [;
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor blackColor]];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    header.contentView.backgroundColor = [UIColor colorWithHexString:@"FDF5E6"];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIFont *labelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    CGSize myStringSize = [[questions objectAtIndex:section] sizeWithFont:labelFont constrainedToSize:CGSizeMake(WIDTH - 40, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, myStringSize.height + 4)];
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, WIDTH - 20, myStringSize.height)];
    sampleLabel.numberOfLines = 0;
    sampleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [sampleLabel setFont:labelFont];
    [sampleLabel setBackgroundColor:[UIColor clearColor]];
    sampleLabel.text = [questions objectAtIndex:section];
    [sampleLabel setTextColor:[UIColor blackColor]];
    [returnView setBackgroundColor:[UIColor colorWithHexString:@"FDF5E6"]];
    [returnView addSubview:sampleLabel];
    return returnView;
    
//    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    UIFont *labelFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
    CGSize myStringSize = [[answers objectAtIndex:indexPath.section] sizeWithFont:labelFont constrainedToSize:CGSizeMake(WIDTH - 40, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, WIDTH - 20, myStringSize.height + 10)];
    [sampleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    sampleLabel.text = [answers objectAtIndex:indexPath.section];
//    UITextView *text = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 80)];
//    text.text = [answers objectAtIndex:indexPath.section];
//    [text sizeToFit];
//    text.scrollEnabled = NO;
//    text.backgroundColor = WHITE_CLR;
//    [cell.contentView addSubview:text];
//    text.editable = NO;
    [sampleLabel setBackgroundColor:[UIColor whiteColor]];
    [sampleLabel setTextColor:[UIColor blackColor]];
    sampleLabel.numberOfLines = 0;
    sampleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [cell.contentView addSubview:sampleLabel];
    sampleLabel = nil;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
