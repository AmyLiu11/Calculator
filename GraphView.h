//
//  GraphView.h
//  calculator
//
//  Created by apple apple on 12-2-12.
//  Copyright (c) 2012年 xian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;
@protocol GraphViewDataSource
-(CGFloat)verticalValueForGraphView:(GraphView*)sender;//表示对data的需求,通常将自身作为传递参数pass ourselves along when we're delegating sth to someone else,in case to ask GraphView sth,(sender.x)
@end

@interface GraphView : UIView
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;
@property (nonatomic) double x;

@end
