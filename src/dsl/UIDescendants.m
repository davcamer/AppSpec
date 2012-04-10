
#import "UIDescendants.h"


@implementation UIDescendants

+(id)withTraversal {
	return [[[self alloc] init] autorelease];
}

-(NSArray *)collect:(NSArray *)views {
	NSMutableArray *array = [NSMutableArray array];
	for (NSView *view in views) {
		[self collectDescendantsOnView:view inToArray:array];
	}
	return array;
}

-(void)collectDescendantsOnView:(NSView *)view inToArray:(NSMutableArray *)array {
    NSLog(@"Collect Descendants for View ClassName %@", NSStringFromClass([view class]));
	NSArray *subViews = nil;
    if ([view isKindOfClass:[NSApplication class]])
         subViews = [(NSApplication *)view windows];
    else if ([view isKindOfClass:[NSWindow class]])
        subViews = [NSArray arrayWithObject:[(NSWindow *)view contentView]];
    else
         subViews = [view subviews];
         
	for (NSView * v in [subViews reverseObjectEnumerator]) {
		[array addObject:v];
	}
	for (NSView * v in [subViews reverseObjectEnumerator]) {
		[self collectDescendantsOnView:v inToArray:array];
	}
}


@end
