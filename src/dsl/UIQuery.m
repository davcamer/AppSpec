
#import "UIQuery.h"
#import "objc/runtime.h"
#import "UIDescendants.h"
#import "UIChildren.h"
#import "UIParents.h"
#import "WaitUntilIdle.h"
#import "UIRedoer.h"
#import "UIQuerySegmentedControl.h"
#import "UIQueryWebView.h"
#import "UIQueryAll.h"
#import "UIFilter.h"
#import "UIQueryExpectation.h"

@implementation UIQuery

@synthesize with;
@synthesize should;
@synthesize parent, child, descendant, find;
@synthesize touch, flash, show, path, inspect;
@synthesize timeout;
@synthesize views;
@synthesize className;
@synthesize redoer;
@synthesize first, last, all, redo;

+(id)withApplication {
	return [self withViews:[NSMutableArray arrayWithObject:[NSApplication sharedApplication]] className:NSStringFromClass([NSApplication class])];
}

-(UIQuery *)find {
	return [self descendant];
}

-(UIQuery *)descendant {
	[self wait:.25];
	return [UIQuery withViews:[[UIDescendants withTraversal] collect:views] className:className filter:YES];
}

-(UIQuery *)child {
	[self wait:.25];
	return [UIQuery withViews:[[UIChildren withTraversal] collect:views] className:className filter:YES];
}

-(UIQuery *)parent {
	[self wait:.25];
	return [UIQuery withViews:[[UIParents withTraversal] collect:views] className:className filter:YES];
}

-(UIQueryExpectation *)should {
	return [UIQueryExpectation withQuery:self];
}

-(UIFilter *)with {
	return [UIFilter withQuery:self];
}

+(id)withViews:(NSArray *)views className:(NSString *)className {
	return [UIRedoer withTarget:[[[self alloc] initWithViews:views className:className filter:NO] autorelease]];
}

+(id)withViews:(NSArray *)views className:(NSString *)className filter:(BOOL)filter {
	return [UIRedoer withTarget:[[[self alloc] initWithViews:views className:className filter:filter] autorelease]];
}

-(id)initWithViews:(NSArray *)_views className:(NSString *)_className filter:(BOOL)_filter {
	if (self = [super init]) {
		timeout = 10;
		views = [[[NSMutableArray alloc] initWithArray:_views] autorelease];
		className = _className;
		filter = _filter;
	}
	return self;
}

-(NSArray *)collect:(NSArray *)some_views {
	return [[[[UIDescendants alloc] init] autorelease] collect:some_views];
}

-(UIQuery *)target {
	return self;
}

-(NSArray *)targetViews {
	return (views.count == 0) ? [NSArray array] : [NSArray arrayWithObject:[views objectAtIndex:0]];
}

-(UIQuery *)timeout:(int)seconds {
	UIQuery *copy = [UIQuery withViews:views className:className];
	copy.timeout = seconds;
	return copy;
}

/* This method is gets called by specs when you use dot-notation to get to a specific view in a class.  For example, when you call:
   app.button, the "button" method gets resolved to this method.  It converts the "button" to NSButton and tries to find the NSButton
   on the parent */
-(id)templateFilter {
	NSString *viewName = NSStringFromSelector(_cmd);
	return [self view:[NSString stringWithFormat:@"NS%@", [viewName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[viewName substringWithRange:NSMakeRange(0,1)] uppercaseString]]]];
}

-(UIQuery *)index:(int)index {
	if (index >= views.count) {
		NSLog(@"UISPEC WARNING: %@ doesn't exist at index %i", className, index);
	}
	NSArray *resultViews = (index >= views.count) ? [NSArray array] : [NSArray arrayWithObject:[views objectAtIndex:index]];
	return [UIQuery withViews:resultViews className:className];
}

-(UIQuery *)first {
	return [self index:0];
}

-(UIQuery *)last {
	return [self index:views.count - 1];
}

-(UIQuery *)all {
	return [UIQueryAll withViews:views className:className];
}

-(UIQuery *)view:(NSString *)aClassName {
	NSMutableArray *array = [NSMutableArray array];
	NSDate *start = [NSDate date];
	while ([start timeIntervalSinceNow] > (0 - timeout)) {
		NSArray *theViews = filter ? self.views : self.descendant.views;
		Class class = NSClassFromString(aClassName);
		for (NSView * v in theViews) {
			if ([v isKindOfClass:class]) {
				[array addObject:v];
			} 
		}
		if (array.count > 0) {
			break;
		}
		[self redo];
	}

    if ([className isEqualToString:@"UISegmentedControl"]) {
		return [UIQuerySegmentedControl withViews:array className:className];
	}
	else if ([className isEqualToString:@"UIWebView"]) {
		return [UIQueryWebView withViews:array className:className];
	}
	else {
		return [UIQuery withViews:array className:className];
	}
}

//-(UIQuery *)marked:(NSString *)mark {
//	return [self.with accessibilityLabel:mark];
//}
 
-(UIQuery *)wait:(double)seconds {
	CFRunLoopRunInMode(kCFRunLoopDefaultMode, seconds, false);
	return [UIQuery withViews:views className:className];
}

-(id)redo {
	//NSLog(@"UIQuery redo");
	if (redoer != nil) {
		//NSLog(@"UIQuery redo redoer = %@", redoer);
		UIRedoer *redone = [redoer redo];
		redoer.target = redone.target;
		self.views = [[redoer play] views];
	}
	//return is provided by uiredoer
    return nil;
}

-(BOOL)exists {
	return [self targetViews].count > 0;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	if ([UIQuery instancesRespondToSelector:aSelector]) {
		return [super methodSignatureForSelector:aSelector];
	}
	
	[[UIQueryExpectation withQuery:self] exist:[NSString stringWithFormat:@"before you can call %@", NSStringFromSelector(aSelector)]];
	NSString *selector = NSStringFromSelector(aSelector);
	
	for (NSView *target in [self targetViews]) {
		if ([target respondsToSelector:aSelector]) {
			return [target methodSignatureForSelector:aSelector];
		}
	}
	
	//Check if any view responds as a property match
	NSArray *selectors = [selector componentsSeparatedByString:@":"];
	if (selectors.count > 1) {
		return [self.with methodSignatureForSelector:aSelector];
	}
	return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	BOOL isDirect = NO;
	for (NSView *target in [self targetViews]) {
		if ([target respondsToSelector:[anInvocation selector]]) {
			[anInvocation invokeWithTarget:target];
			isDirect = YES;
		}
	}
	
	if (!isDirect) {
		[[[UIRedoer withTarget:self] with] forwardInvocation:anInvocation];
	}
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	if ([UIQuery instancesRespondToSelector:aSelector]) {
		return YES;
	}
	for (NSView *target in [self targetViews]) {
		if ([target respondsToSelector:aSelector]) {
			return YES;
		}
	}
	return [super respondsToSelector:aSelector];
}

//UIKit specific....
-(UIQuery *)flash {
//	[[UIQueryExpectation withQuery:self] exist:@"before you can flash it"];
//	for (NSView *view in [self targetViews]) {
//		NSColor *tempColor = [view.backgroundColor retain];
//		for (int i=0; i<5; i++) {
//			view.backgroundColor = [NSColor yellowColor];
//			CFRunLoopRunInMode(kCFRunLoopDefaultMode, .05, false);
//			view.backgroundColor = [NSColor blueColor];
//			CFRunLoopRunInMode(kCFRunLoopDefaultMode, .05, false);
//		}
//		view.backgroundColor = tempColor;
//		[tempColor release];
//	}
//	return [UIQuery withViews:views className:className];
    return nil;
}

-(UIQuery *)show {
	//NSLog(@"calling show");
	[[UIQueryExpectation withQuery:self] exist:@"before you can show it"];
	[UIQuery show:[self targetViews]];
	return [UIQuery withViews:views className:className];
}

-(UIQuery *)path {
	[[UIQueryExpectation withQuery:self] exist:@"before you can show its path"];
	for (NSView *aView in [self targetViews]) {
		NSMutableString *aPath = [NSMutableString stringWithString:@"\n"];
		NSArray *parentViews = [[UIParents withTraversal] collect:[NSArray arrayWithObject:aView]];
		for (int i = parentViews.count-1; i>=0; i--) {
			[aPath appendFormat:@"%@ -> ", [[parentViews objectAtIndex:i] class]];
		}
		[aPath appendFormat:@"%@", [view class]];
		NSLog(@"Path is %@",path);
	}
	return [UIQuery withViews:views className:className]; 
}

//-(UIQuery *)inspect {
//	[UIBug openInspectorWithView:[views objectAtIndex:0]];
//	return [UIQuery withViews:views className:className]; 
//}

+(void)show:(NSArray *)views {
	for (NSView *view in views) {
		NSDictionary *dict = [UIQuery describe:view];
		if ([dict allKeys].count > 0) {
			NSLog(@"\nClass: %@ \n%@", [view class], [dict description]);
		}
	}
}

+(NSDictionary *)describe:(id)object {
	//NSLog(@"describing object %@", object);
	NSMutableDictionary *properties = [NSMutableDictionary dictionary];
	Class clazz = [object class];
	do {
		//NSLog(@"describing class %@", NSStringFromClass(clazz));
		unsigned i;
		id objValue;
		int intValue;
		long longValue;
		char *charPtrValue;
		char charValue;
		short shortValue;
		float floatValue;
		double doubleValue;
		
		unsigned int propertyCount = 0;
		objc_property_t *propertyList = class_copyPropertyList(clazz, &propertyCount);
		//NSLog(@"property count = %d", propertyCount);
		for (i=0; i<propertyCount; i++) {
			objc_property_t *thisProperty = propertyList + i;
			const char* propertyName = property_getName(*thisProperty);
			const char* propertyAttributes = property_getAttributes(*thisProperty);
			
			NSString *key = [NSString stringWithFormat:@"%s", propertyName];
			NSString *keyAttributes = [NSString stringWithFormat:@"%s", propertyAttributes];
			//NSLog(@"key = %@", key);
			//NSLog(@"keyAttributes = %@", keyAttributes);
			
			NSArray *attributes = [keyAttributes componentsSeparatedByString:@","];
			if ([[[attributes lastObject] substringToIndex:1] isEqualToString:@"G"]) {
				key = [[attributes lastObject] substringFromIndex:1];
			}
			
			SEL selector = NSSelectorFromString(key);
			if ([object respondsToSelector:selector]) {
				NSMethodSignature *sig = [object methodSignatureForSelector:selector];
				//NSLog(@"sig = %@", sig);
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
				[invocation setSelector:selector];
				//NSLog(@"invocation selector = %@", NSStringFromSelector([invocation selector]));
				[invocation setTarget:object];
				
				@try {
					[invocation invoke];
				}
				@catch (NSException *exception) {
					NSLog(@"UIQuery.describe caught %@: %@", [exception name], [exception reason]);
					continue;
				}
				
				const char* type = [[invocation methodSignature] methodReturnType];
				NSString *returnType = [NSString stringWithFormat:@"%s", type];
				const char* trimmedType = [[returnType substringToIndex:1] cStringUsingEncoding:NSASCIIStringEncoding];
				//NSLog(@"return type = %@", returnType);
				switch(*trimmedType) {
					case '@':
						[invocation getReturnValue:(void **)&objValue];
						if (objValue == nil) {
							[properties setObject:[NSString stringWithFormat:@"%@", objValue] forKey:key];
						} else {
							[properties setObject:objValue forKey:key];
						}
						break;
					case 'i':
						[invocation getReturnValue:(void **)&intValue];
						[properties setObject:[NSString stringWithFormat:@"%i", intValue] forKey:key];
						break;
					case 's':
						[invocation getReturnValue:(void **)&shortValue];
						[properties setObject:[NSString stringWithFormat:@"%ud", shortValue] forKey:key];
						break;
					case 'd':
						[invocation getReturnValue:(void **)&doubleValue];
						[properties setObject:[NSString stringWithFormat:@"%lf", doubleValue] forKey:key];
						break;
					case 'f':
						[invocation getReturnValue:(void **)&floatValue];
						[properties setObject:[NSString stringWithFormat:@"%f", floatValue] forKey:key];
						break;
					case 'l':
						[invocation getReturnValue:(void **)&longValue];
						[properties setObject:[NSString stringWithFormat:@"%ld", longValue] forKey:key];
						break;
					case '*':
						[invocation getReturnValue:(void **)&charPtrValue];
						[properties setObject:[NSString stringWithFormat:@"%s", charPtrValue] forKey:key];
						break;
					case 'c':
						[invocation getReturnValue:(void **)&charValue];
						[properties setObject:[NSString stringWithFormat:@"%d", charValue] forKey:key];
						break;
					case '{': {
						unsigned int length = [[invocation methodSignature] methodReturnLength];
						void *buffer = (void *)malloc(length);
						[invocation getReturnValue:buffer];
						NSValue *value = [[[NSValue alloc] initWithBytes:buffer objCType:type] autorelease];
						[properties setObject:value forKey:key];
						break;
					}
				}
			}
		}
	} while ((clazz = class_getSuperclass(clazz)) != nil);
    return properties;
}

//UIKit Specific
- (UIQuery *)touch {
//	[[UIQueryExpectation withQuery:self] exist:@"before you can touch it"];
//	
//	for (UIView *view in [self targetViews]) {
//		UITouch *touch = [[UITouch alloc] initInView:view];
//		UIEvent *eventDown = [[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:touch];
//		NSSet *touches = [[NSMutableSet alloc] initWithObjects:&touch count:1];
//		
//		[touch.view touchesBegan:touches withEvent:eventDown];
//		
//		UIEvent *eventUp = [[NSClassFromString(@"UITouchesEvent") alloc] initWithTouch:touch];
//		[touch setPhase:UITouchPhaseEnded];
//		
//		[touch.view touchesEnded:touches withEvent:eventDown];
//		
//		[eventDown release];
//		[eventUp release];
//		[touches release];
//		[touch release];
//		[self wait:.5];
//	}
//	return [UIQuery withViews:views className:className];
    return nil;
}

- (UIQuery *)buttonPress {
    [[UIQueryExpectation withQuery:self] exist:@"before you can press it"];
    //	
    for (NSView *view in [self targetViews]) {
        //Simulate the click of a button here? Or should it be a mouse click?
        NSLog(@"Button pressed");

        [self wait:.5];
    }
    return [UIQuery withViews:views className:className];
}


-(NSString *)description {
	return [NSString stringWithFormat:@"UIQuery: %@", [views description]];
}

-(void)logRange:(NSString *)prefix range:(NSRange)range {
	NSLog(@"%@ location = %@, length = %@", prefix, range.location, range.length);
}

-(void)dealloc {
	views = nil;
	className = nil;
	redoer = nil;
	[super dealloc];
}

@end


//
// GSEvent is an undeclared object. We don't need to use it ourselves but some
// Apple APIs (UIScrollView in particular) require the x and y fields to be present.
//
@interface GSEventProxy : NSObject
{
@public
	unsigned int flags;
	unsigned int type;
	unsigned int ignored1;
	float x1;
	float y1;
	float x2;
	float y2;
	unsigned int ignored2[10];
	unsigned int ignored3[7];
	float sizeX;
	float sizeY;
	float x3;
	float y3;
	unsigned int ignored4[3];
}
@end
@implementation GSEventProxy
@end

//
// PublicEvent
//
// A dummy class used to gain access to UIEvent's private member variables.
// If UIEvent changes at all, this will break.
//
@interface PublicEvent : NSObject
{
@public
    GSEventProxy           *_event;
    NSTimeInterval          _timestamp;
    NSMutableSet           *_touches;
    CFMutableDictionaryRef  _keyedTouches;
}
@end

@implementation PublicEvent
@end

@interface NSEvent (Creation)

//- (id)_initWithEvent:(GSEventProxy *)fp8 touches:(id)fp12;

@end

//
// UIEvent (Synthesize)
//
// A category to allow creation of a touch event.
//
@implementation NSEvent (Synthesize)

//- (id)initWithTouch:(UITouch *)touch
//{
//	CGPoint location = [touch locationInView:touch.window];
//	GSEventProxy *gsEventProxy = [[GSEventProxy alloc] init];
//	gsEventProxy->x1 = location.x;
//	gsEventProxy->y1 = location.y;
//	gsEventProxy->x2 = location.x;
//	gsEventProxy->y2 = location.y;
//	gsEventProxy->x3 = location.x;
//	gsEventProxy->y3 = location.y;
//	gsEventProxy->sizeX = 1.0;
//	gsEventProxy->sizeY = 1.0;
//	gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
//	gsEventProxy->type = 3001;	
//	
//	//
//	// On SDK versions 3.0 and greater, we need to reallocate as a
//	// UITouchesEvent.
//	//
//	Class touchesEventClass = objc_getClass("UITouchesEvent");
//	if (touchesEventClass && ![[self class] isEqual:touchesEventClass])
//	{
//		[self release];
//		self = [touchesEventClass alloc];
//	}
//	
//	self = [self _initWithEvent:gsEventProxy touches:[NSSet setWithObject:touch]];
//	if (self != nil)
//	{
//	}
//	return self;
//}

@end


