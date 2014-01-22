//
//  GraphingViewController.h
//  calculator
//
//  Created by apple apple on 12-2-11.
//  Copyright (c) 2012年 xian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "splitViewBarButtonItemPresenter.h"

@interface GraphingViewController : UIViewController<splitViewBarButtonItemPresenter>//you have to inplement this protocol,which is a property,so you have to implement the property

@property (nonatomic,strong) NSMutableArray *graphStack;//model
@end
