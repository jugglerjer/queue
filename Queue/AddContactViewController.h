//
//  AddContactViewController.h
//  Queue
//
//  Created by Jeremy Lubin on 6/5/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  Contact;

@interface AddContactViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Contact *contact;

@end
