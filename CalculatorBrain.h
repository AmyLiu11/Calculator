//
//  CalculatorBrain.h
//  calculator
//
//  Created by apple apple on 12-2-13.
//  Copyright (c) 2012年 xian. All rights reserved.
//

#import <Foundation/Foundation.h>
#define PI 3.141592654

@interface CalculatorBrain : NSObject

-(void)pushOperand:(double)operand;
-(double)performOperation:(NSString*)operation;
-(NSString*)descriptionOfBrain;
-(void)clearProgramStack;

@property (readonly) id program;

+(NSString*)descriptionOfProgram:(id)program;

@property (nonatomic)double variableValues;
- (void)pushVariable:(NSString *)variables;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;

@end
