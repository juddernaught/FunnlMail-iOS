//
//  FunnlViewController.m
//  FunnlMail
//
//  Created by Daniel Judd on 3/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FunnlViewController.h"
#import "Cell.h"

@interface FunnlViewController ()

@end

@implementation FunnlViewController

- (void)customToolbar {
    UIToolbar* toolbar = [[UIToolbar alloc]
                          initWithFrame:CGRectMake(0, 0, 320, 45)];
    [toolbar setBarStyle: UIBarStyleDefault];
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:8];
    
    // create a settings button
    //UIBarButtonItem *settingsButton = [self createImageButtonItemWithNoTitle:@"Settings.png" target:nil action:@selector(printHello)];
    UIImage *settingsImage = [UIImage imageNamed:@"Settings.png"];
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(0, 0, settingsImage.size.width, settingsImage.size.height);
    [settingsButton setBackgroundImage:settingsImage forState:UIControlStateNormal];
    
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:settingsButton]];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttons addObject:spaceItem];
    
    UIImage *mailImage = [UIImage imageNamed:@"Mail.png"];
    UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mailButton.frame = CGRectMake(0, 0, settingsImage.size.width, mailImage.size.height);
    [mailButton setBackgroundImage:mailImage forState:UIControlStateNormal];
    
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:mailButton]];
    // action:@selector(deleteAction:)];
    
    UIImage *funnlImage = [UIImage imageNamed:@"Funnl.png"];
    UIButton *funnlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    funnlButton.frame = CGRectMake(0, 0, settingsImage.size.width, funnlImage.size.height);
    [funnlButton setBackgroundImage:funnlImage forState:UIControlStateNormal];
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:funnlButton]];
    
    UIBarButtonItem *spaceItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [buttons addObject:spaceItem2];
    
    UIImage *composeImage = [UIImage imageNamed:@"Compose.png"];
    UIButton *composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    composeButton.frame = CGRectMake(0, 0, settingsImage.size.width, composeImage.size.height);
    [composeButton setBackgroundImage:composeImage forState:UIControlStateNormal];
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:composeButton]];
    
    
    UIBarButtonItem *rightMargin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightMargin.width = 12.0f;
    [buttons addObject:rightMargin];
    
    
    // put the buttons in the toolbar and release them
    [toolbar setItems:buttons animated:NO];
    
    // place the toolbar into the navigation bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
}


-(UIBarButtonItem *)createImageButtonItemWithNoTitle:(NSString *)imagePath target:(id)tgt action:(SEL)a
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"button_slice.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    UIImage *buttonPressedImage = [[UIImage imageNamed:@"button_slice_over.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    CGRect buttonFrame = [button frame];
    buttonFrame.size.width = 32;
    buttonFrame.size.height = 32;
    [button setFrame:buttonFrame];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
    imageView.image = [UIImage imageNamed:imagePath];
    [button addSubview:imageView];
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    
    [button addTarget:tgt action:a forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;
}

- (void) printHello {
    NSLog(@"got clicked");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self customToolbar];
    
    _funnlIcons = @[@"Files.png", @"Meetings.png", @"Payments.png", @"Travel.png", @"News.png", @"Forums.png", @"Shopping.png", @"Social.png", @"Plus Sign.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma collection view
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _funnlIcons.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //cell.imageView.image = [UIImage imageNamed:self.truckImages[0]];
    UIImage *funnlImage = [[UIImage alloc] init];
    funnlImage = [UIImage imageNamed:[self.funnlIcons objectAtIndex:indexPath.row]];
    cell.imageView.image = funnlImage;
    return cell;
}

@end
