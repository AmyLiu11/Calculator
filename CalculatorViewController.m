//
//  CalculatorViewController.m
//  calculator
//
//  Created by apple apple on 12-2-13.
//  Copyright (c) 2012年 xian. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphView.h"
#import "GraphingViewController.h"
#import "splitViewBarButtonItemPresenter.h"


@interface CalculatorViewController()
@property (nonatomic)BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic,strong) CalculatorBrain*brain;

@end

@implementation CalculatorViewController
@synthesize brain = _brain;
@synthesize brainDisplay = _brainDisplay;
@synthesize display = _display;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;



-(id<splitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(splitViewBarButtonItemPresenter)]) 
    {
        detailVC = nil;
    }
    return detailVC;
}//判定detail view是否可以显示barbuttonItem，如果可以，则返回

-(BOOL)splitViewController:(UISplitViewController *)svc 
  shouldHideViewController:(UIViewController *)vc 
             inOrientation:(UIInterfaceOrientation)orientation
{
    if ([self splitViewBarButtonItemPresenter])
    {
        return UIInterfaceOrientationIsPortrait(orientation);//只在portrait时隐藏calculator
    }//detail view is already a button presenter,but you only want to show the button in the portrait orientation.
    else
    {
        return NO;//显示master(calculator)
    }
}//Asks the delegate whether the first view controller should be hidden for the specified orientation.

-(void)splitViewController:(UISplitViewController*)svc
       willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem 
      forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"calculator";
    //tell the detail view to put this button up
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}//Tells the delegate that the specified view controller is about to be hidden.

-(void)splitViewController:(UISplitViewController*)svc
       willShowViewController:(UIViewController *)aViewController 
       invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //tell the detail view to take the button away
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;//setter ,hook up with Graph,splitViewBarButtonItem is splitViewBarButtonItemPresenter's property 
    
}//Tells the delegate that the specified view controller is about to be shown again.

//Calculator and detail view working together blindly through protocol!!!!!!!
//If you want to display the master view controller when in portrait orientations, you do so using a delegate object. When rotating to a portrait orientation, the split-view controller provides its delegate with a button that, when tapped, shows the first pane in a popover. All your application has to do is add this button to your application’s toolbar in the delegate’s splitViewController:willHideViewController:withBarButtonItem:forPopoverController: method and remove the button in the splitViewController:willShowViewController:invalidatingBarButtonItem: method. 

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;//make CalculatorViewController the delegate of any splitView it's in
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


-(CalculatorBrain*)brain
{ 
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"] ) 
    {
        [segue.destinationViewController  setGraphStack:[self.brain program]];//segue.destinationViewController return id type
    }
}//很重要，千万不能忘记

-(GraphingViewController*)splitViewGraphingViewController
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphingViewController class]]) {
        gvc = nil;
    }
    return  gvc;
}


-(void)performGraph
{
    if ([self splitViewGraphingViewController]) 
    {
        [self splitViewGraphingViewController].graphStack = [self.brain program];//assign an immutable array(this stack hasn't been described还没有规范成为中缀式)to the GraphingViewController's graphStack,redrew the view
        for (int i = 0; i<[[self splitViewGraphingViewController].graphStack count]; i++) {
            NSLog(@"op = %@",[[self splitViewGraphingViewController].graphStack objectAtIndex:i]);
        }
   }
}//set the graphStack calls setNeedsDisplay , call drawRect,redraw the GraphView

- (IBAction)graph 
{
    [self performGraph];
}

- (IBAction)dotPressed 
{
    NSRange range;
    range = [self.display.text rangeOfString:@"."];
    if (range.location == NSNotFound) 
    {
        self.display.text=[self.display.text stringByAppendingString:@"."];
    }
    
}
- (IBAction)clear
{
    [self.brain clearProgramStack];
    self.display.text = @"0";
    self.brainDisplay.text = @"";
}


- (IBAction)digitPressed:(UIButton*)sender
{
    NSString *digit = sender.currentTitle;
    // NSLog(@"digit Pressed = %@",digit);//console
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    }
    else
    {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}//IBAction means void,sender is button in this case,id is pointer to any object
//%@ represent object


- (IBAction)enterPressed 
{
    if ([self.display.text isEqualToString:@"π"]) 
    {
        [self.brain pushOperand:3.141592654];
    }
    else
    {
        [self.brain pushOperand:[self.display.text doubleValue]];
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
}

- (IBAction)operationPressed:(UIButton*)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }//将当前屏幕上的操作数也入栈，For example, 6 Enter 4 - would be the same as 6 Enter 4 Enter -.
    double result = [self.brain performOperation:sender.currentTitle];
    self.brainDisplay.text = @"";
    self.brainDisplay.text = [self.brainDisplay.text stringByAppendingString:[self.brain descriptionOfBrain]];
    NSLog(@"text = %@",self.brainDisplay.text);
    if ([sender.currentTitle isEqualToString:@"x"]) {
        self.display.text = @"x";
        // self.brainDisplay.text = @"";
    }
    else if ([sender.currentTitle isEqualToString: @"π"])
    {
        self.display.text = @"π";
        //   self.brainDisplay.text = @"";
    }
    else if([sender.currentTitle isEqualToString:@"-/+"])
    {
        self.brainDisplay.text = @"";
    }
    else if([sender.currentTitle isEqualToString:@"cos"]||[sender.currentTitle isEqualToString:@"sin"])
    {
        self.display.text = [NSString stringWithFormat:@"%g",result];
    }
    else
    {
        NSString *resultString = [NSString stringWithFormat:@"%g",result];//class method
        self.display.text = resultString;
    }
}


@end

    
