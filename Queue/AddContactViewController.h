//
//  AddContactViewController.h
//  Queue
//
//  Created by Jeremy Lubin on 6/5/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  Contact;

typedef enum
{
    QueueEditContactTypeAdd,
    QueueEditContactTypeUpdate
} QueueEditContactType;

@protocol AddContactViewControllerDelegate;

@interface AddContactViewController : UIViewController <UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) id<AddContactViewControllerDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Contact *contact;
@property QueueEditContactType editContactType;

@end

@protocol AddContactViewControllerDelegate <NSObject>

- (void)addContactViewController:(AddContactViewController *)addContactViewController
                   didUpdateContact:(Contact *)contact;
- (void)addContactViewController:(AddContactViewController *)addContactViewController
didDismissWithoutUpdatingContact:(Contact *)contact;

@end