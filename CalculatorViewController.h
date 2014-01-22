//
//  CalculatorViewController.h
//  calculator
//
//  Created by apple apple on 12-2-13.
//  Copyright (c) 2012年 xian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController<UISplitViewControllerDelegate>

@property (nonatomic,weak)IBOutlet UILabel *display;

@property (nonatomic,weak)IBOutlet UILabel *brainDisplay;

@end
