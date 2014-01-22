//
//  CalculatorBrain.m
//  calculator
//
//  Created by apple apple on 12-2-13.
//  Copyright (c) 2012年 xian. All rights reserved.
//

#import "CalculatorBrain.h"


@interface CalculatorBrain()
@property (nonatomic,strong)NSMutableArray *programStack;
@end

@implementation CalculatorBrain
@synthesize programStack = _programStack;
@synthesize variableValues = _variableValues;

- (id)program
{
    return [self.programStack copy];//immutable copy
}

-(NSMutableArray*)programStack
{
    if(_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}//avoid the stack to be nil

- (void)clearProgramStack
{
    [self.programStack removeAllObjects];
}

-(void)setOperandStack:(NSMutableArray *)operandStack
{
    _programStack = operandStack;
}//_operandStack only used in setter and getter

- (void)pushVariable:(NSString *)variables
{
    [self.programStack addObject:variables];
}

- (void)pushOperand:(double)operand
{
    [self.programStack  addObject:[NSNumber numberWithDouble:operand]];
}//when you send a message to nil,this line of code do nothing


- (double)performOperation:(NSString *)operation
{
       NSDictionary* variable = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble:0],
                              @"x",
                              nil];;
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.programStack usingVariableValues:variable];
}

- (NSString *)descriptionOfBrain
{
    return [CalculatorBrain descriptionOfProgram:self.program];
}


+(BOOL)isDoubleOperandOperation:(NSString*)operation
{
    if ([operation isEqualToString:@"+"]||[operation isEqualToString:@"-"]||[operation isEqualToString:@"*"]||[operation isEqualToString:@"/"])
    {
        return YES;
    }
    else return NO;
}

+(BOOL)isSingleOperandOperation:(NSString*)operation
{
    if ([operation isEqualToString:@"sqrt"]||[operation isEqualToString:@"cos"]||[operation isEqualToString:@"sin"])
    {
        return YES;
    }
    else return NO;
}

+(BOOL)isNoOperandOperation:(NSString*)operation
{
    if ([operation isEqualToString:@"π"])
    {
        return YES;
    }
    else return NO;
}

+(BOOL)isVariables:(NSString*)operation
{
    if ([operation isEqualToString:@"x"])
    {
        return YES;
    }
    else return NO;
}

+(BOOL)isNegative:(NSString*)operation
{
    if ([operation isEqualToString:@"-/+"])
    {
        return YES;
    }
    else return NO;
}


+(NSString *)descriptionofTopStack:(NSMutableArray *)stack
{
    NSMutableString *str = [NSMutableString stringWithString:@""];
    id topOfStack = [stack lastObject];
    if(topOfStack) [stack removeLastObject];
    if([topOfStack isKindOfClass:[NSNumber class]]){
        [str appendFormat:@"%g",[topOfStack doubleValue]];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) 
    {
        NSString *operation = topOfStack;
        if([self isDoubleOperandOperation:operation])
        {
            NSString *operand1 = [self descriptionofTopStack:stack];
            [str appendFormat:@"(%@ %@ %@)",[self descriptionofTopStack:stack],operation,operand1];
        }
        else if([self isSingleOperandOperation:operation])
        {
            [str appendFormat:@"%@(%@)",operation,[self descriptionofTopStack:stack]]; 
        }
        else if([self isNoOperandOperation:operation])
        {
            [str appendString:operation]; 
        }
        else if([self isVariables:operation])
        {
            [str appendString:operation]; 
        }
        else if([self isNegative:operation])
        {
            [str appendFormat:@"-%@",[self descriptionofTopStack:stack]]; 
        }
    }
    /* if ([stack count])
     {
     [str appendFormat:@"%@,%@",str,[self descriptionofTopStack:stack]];
     }*/
    
    NSLog(@"str = %@",str);
    return str;
}

+(NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]])
    {//introspection
        stack = [program mutableCopy];//mutableCopy returns idtype
    }
    return [[self class] descriptionofTopStack:stack];
}

+(double)popOperandOffStack:(NSMutableArray*)stack
{
    double result = 0;
    id topOfStack = [stack lastObject];
    if(topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    else if([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;//assign id to static type
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }
        else if([operation isEqualToString:@"-"]) {
            double jianshu = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - jianshu;
        }//We must be sure to get the order of operands correct! The input “6 Enter 2 -” should be 4, not -4.
        else if([operation isEqualToString:@"*"]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        }
        else if([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffStack:stack];
            if(divisor) result = [self popOperandOffStack:stack] / divisor;
        }
        else if([operation isEqualToString:@"sqrt"])
        {
            double num = [self popOperandOffStack:stack];
            if (num >= 0) {
                 result = sqrt(num);
            }
            else result = 0;
        }
        else if([operation isEqualToString:@"sin"])
        {
            double temp1 = [self popOperandOffStack:stack]*180/PI;
            result = sin(temp1);       
        }
        else if([operation isEqualToString:@"cos"])
        {
            double temp2 = [self popOperandOffStack:stack]*180/PI;
            result = cos(temp2);       
        }
        else if([operation isEqualToString:@"π"])
        {
            result = PI;
        }
        else if([operation isEqualToString:@"-/+"])
        {
            result = -[self popOperandOffStack:stack];
        }
    }
    return result;
}


-(double)variableValues
{
    return _variableValues;
}


+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    int i;
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]])
    {//introspection
        stack = [program mutableCopy];//mutableCopy returns idtype
    }
    for (i = 0; i < [stack count]; i++)
    {
        if ([[stack objectAtIndex:i] isKindOfClass:[NSString class]]) 
        {
            if ([[stack objectAtIndex:i] isEqualToString:@"x"])
            {
                [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:@"x"]];
            }
        }
    }
    return [[self class] popOperandOffStack:stack];
}//The values of the variables will only be supplied when the “program” is “run.” 




@end
