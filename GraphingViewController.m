//
//  GraphingViewController.m
//  calculator
//
//  Created by apple apple on 12-2-11.
//  Copyright (c) 2012年 xian. All rights reserved.
//

#import "GraphingViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"
#import "CalculatorProgramTableViewController.h"

@interface GraphingViewController()<GraphViewDataSource,CalculatorProgramTableViewControllerDelegate>
@property (nonatomic,weak)IBOutlet GraphView*graphView;//view
@property (nonatomic,strong)CalculatorBrain*brain;
@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;
@end

@implementation GraphingViewController
@synthesize graphView = _graphView;
@synthesize brain = _brain;
@synthesize graphStack = _graphStack;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;


#define FAVORITE_KEY @"GraphingViewController.favorites"

- (IBAction)addToFavorite:(id)sender 
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITE_KEY]  mutableCopy];
    //在缺省值中找到FAVORITE_KEY, 返回值是一个可变数组
    if (!favorites)  favorites = [NSMutableArray array];
    [favorites addObject: self.graphStack];
    if ([favorites count]>10) {
        [favorites removeAllObjects];
    }//设置数组上限
    [defaults setObject:favorites forKey:FAVORITE_KEY];
    [defaults synchronize];  
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Favorite Graphs"]) 
    {
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_KEY];//从userdefault中取出公式数组
        [segue.destinationViewController setPrograms:programs];//model在这里起到作用！！！！
        [segue.destinationViewController setDelegate:self];//when it segues,because that's when this thing is created,set GraphingViewController as delegate,segue.destinationViewController is Table view controller,has delegate property,can set delegate property
    }
}

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if(_splitViewBarButtonItem != splitViewBarButtonItem)//draw is not cheap ,if it's set sth new
    {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) {
            [toolbarItems removeObject:_splitViewBarButtonItem];
        }
        if(splitViewBarButtonItem)
        {
            [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];//left
        }
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}//setter  Typical “setSplitViewBarButton:” method
//Example of using a UIToolbar to show the bar button item.


-(void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    self.graphView.dataSource = self;//声明delegate就是GraphingViewController,implement <GraphViewDataSource>这一点很重要！！！！
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];//self.graphView is gonna handle the gesture
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    UITapGestureRecognizer * oneFingerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(triTap:)];
    oneFingerDoubleTap.numberOfTouchesRequired = 1;//one finger
    oneFingerDoubleTap.numberOfTapsRequired = 2;//two taps
    [self.graphView addGestureRecognizer:oneFingerDoubleTap];
        
}//add a grestureReconizer to the GraphView,the GraphView itself is gonna handle it

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}



- (void)setGraphStack:(NSMutableArray *)graphStack
{
    _graphStack = graphStack;
    [self.graphView setNeedsDisplay];
}//everytime graphStack changes,graph redraw its view

-(CGFloat)verticalValueForGraphView:(GraphView*)sender
{
    NSMutableDictionary *varDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithDouble:sender.x],
                            @"x",
                            nil];
    return [CalculatorBrain runProgram:self.graphStack
                   usingVariableValues:varDic];
}

-(void)calculatorProgramTableViewController:(CalculatorProgramTableViewController *)sender chooseProgram:(id)program
{
    self.graphStack = program;
}

-(void)calculatorProgramTableViewController:(CalculatorProgramTableViewController *)sender deleteProgram:(id)program
{
    NSString *deletedProgramDescription = program;
    NSMutableArray *favorites =[NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for ( id program in [defaults objectForKey:FAVORITE_KEY]) {
        if (![program isEqualToString:deletedProgramDescription]) {
            [favorites addObject:program];
        }//如果不是要删除的对象，重新进入数组中
    }
    [defaults setObject:favorites forKey:FAVORITE_KEY];
    [defaults synchronize];
    sender.programs = favorites;//change the model to reload the table view
}
  

@end
