
#import "UIParents.h"


@implementation UIParents

+(id)withTraversal {
	return [[[self alloc] init] autorelease];
}

-(NSArray *)collect:(NSArray *)views {
	NSMutableArray *array = [NSMutableArray array];
	for (NSView *v in views) {
		NSView *sv = v.superview;
		while (sv != nil) {
			[array addObject:sv];
			sv = sv.superview;
		}
	}
	return array;
}

@end
