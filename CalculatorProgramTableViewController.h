//
//  CalculatorProgramTableViewController.h
//  calculator
//
//  Created by apple apple on 12-2-20.
//  Copyright (c) 2012年 xian. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CalculatorProgramTableViewController;
@protocol CalculatorProgramTableViewControllerDelegate 
@optional
-(void)calculatorProgramTableViewController:(CalculatorProgramTableViewController*)sender chooseProgram:(id)program;//delegate methods,program is the program we choose in the table view
-(void)calculatorProgramTableViewController:(CalculatorProgramTableViewController *)sender deleteProgram:(id)program;
@end


@interface CalculatorProgramTableViewController : UITableViewController
@property (nonatomic,strong) NSArray *programs;//of CalculatorBrain Programs
@property (nonatomic,strong) id<CalculatorProgramTableViewControllerDelegate>delegate;
@end
