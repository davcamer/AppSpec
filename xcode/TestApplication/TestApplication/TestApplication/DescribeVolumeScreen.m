//
//  DescribeVolumeScreen.m
//  TestApplication
//
//  Created by Rick Carragher on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DescribeVolumeScreen.h"
#import "UIQuery.h"

@implementation DescribeVolumeScreen

-(void)beforeAll {
    //This is run once and only once, before all of the examples
    //and before the "before" method.
    NSLog(@"Before All");
}

-(void)before {
    //This is run before each example
    NSLog(@"Before");
}

-(void)itShouldMuteWhenPressingTheMute {
    NSLog(@"mute test");
    UIQuery *app = [UIQuery withApplication];

    [app.window.all.first.button click];
}

-(void)itShouldChangeTheSliderWhenChangingTheText {
   NSLog(@"Should Change the slider when changing the text");
}

-(void)itShouldNotAllowANegativeNumberInText {
    NSLog(@"mute not allow a negative number");
}

-(void)after {
    //This is run after each example
    NSLog(@"After");
}

-(void)afterAll {
    //This is run once and only once, after all of the examples
    //and after the "after" method.
    NSLog(@"After All");
}

@end
