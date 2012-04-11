//
//  TestAppDelegate.h
//  TestApplication
//
//  Created by Rick Carragher on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TestAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSSlider *slider;
@property (assign) IBOutlet NSTextField *textField;

- (IBAction)mute:(id)sender;
- (IBAction)volumeValueChanged:(id)sender;
@end
