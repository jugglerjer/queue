//
//  QueuesViewController.h
//  Queue
//
//  Created by Jeremy Lubin on 5/18/13.
//  Copyright (c) 2013 Lubin Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLPullNavigationController.h"
#import "QueueCell.h"

@interface QueuesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, LLPullNavigationViewControllerDelegate, QueueCellDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
