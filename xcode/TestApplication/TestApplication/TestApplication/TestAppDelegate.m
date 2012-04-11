//
//  TestAppDelegate.m
//  TestApplication
//
//  Created by Rick Carragher on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestAppDelegate.h"

@implementation TestAppDelegate

@synthesize window = _window;
@synthesize slider = _slider;
@synthesize textField = _textField;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)mute:(id)sender {
    NSLog(@"Time to mute");
    [_slider setFloatValue:0];
    [_textField setFloatValue:0];
}

- (IBAction)volumeValueChanged:(id)sender {
    float value = 0;
    if (sender == _textField){
        value = [_textField floatValue];
        [_slider setFloatValue:value];
    }
    else{
        value = [_slider floatValue];
        [_textField setFloatValue:value];
    }
    NSLog(@"Set volume to %1.2f", value);
}
@end
