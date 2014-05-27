//
//  CreateFunnlViewController.h
//  FunnlMail
//
//  Created by Krunal on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "View+MASAdditions.h"
@interface CreateFunnlViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tableview;
    UITextField *nameTextField,*conversattionTextField,*subjectTextField;
    NSMutableDictionary *dictionaryOfConversations,*dictionaryOfSubjects;
    NSString *funnlName;
    id activeField;
    NSArray *randomColors;
}
-(id)initTableViewWithSenders:(NSMutableDictionary*)sendersDictionary subjects:(NSMutableDictionary*)subjectsDictionary;
@end

