//
//  main.m
//  TestApplication
//
//  Created by Rick Carragher on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppSpec.h"

int main(int argc, char *argv[])
{
    [AppSpec runSpecsAfterDelay:3];
    return NSApplicationMain(argc, (const char **)argv);
}
