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
    /*UIToolbar* toolbar = [[UIToolbar alloc]
                          initWithFrame:CGRectMake(0, 0, 320, 45)];
    [toolbar setBarStyle: UIBarStyleBlackOpaque];
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:5];
    
    // create a standard save button
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithImage:@"Settings.png"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:nil];
    saveButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:saveButton];
    
    // create a standard delete button with the trash icon
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                     target:self
                                     action:nil];
    deleteButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:deleteButton];
    
    UIBarButtonItem *addbutton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:nil];
    // action:@selector(deleteAction:)];
    addbutton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:addbutton];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                   target:self
                                   action:nil];
    editButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:editButton];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                   target:self
                                   action:nil];
    doneButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:doneButton];
    
    // put the buttons in the toolbar and release them
    [toolbar setItems:buttons animated:NO];
    
    // place the toolbar into the navigation bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    NSLog(@"Here");
    self.navigationController.toolbarHidden = NO;*/
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
