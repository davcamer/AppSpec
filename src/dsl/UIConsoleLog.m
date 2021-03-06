#import "UIConsoleLog.h"
#import "AppSpec.h"

@implementation UIConsoleLog

-(void)onStart {
	errors = [[NSMutableArray array] retain];
	start = [[NSDate date] retain];
}

-(void)onSpec:(AppSpec *)spec {
	currentSpec = NSStringFromClass([spec class]);
	NSLog(@"\n%@", currentSpec);
}

-(void)onBeforeAll{}

-(void)onBeforeAllException:(NSException *)exception {
	NSString *error = [NSString stringWithFormat:@"%@ in %@ beforeAll \n %@", exception.name, currentSpec, exception.reason];
	[errors addObject:error];
}

-(void)onBefore:(NSString *)example {
	currentExample = example;
}

-(void)onBeforeException:(NSException *)exception {
	NSString *error = [NSString stringWithFormat:@"%@ in %@ before %@ \n %@", exception.name, currentSpec, currentExample, exception.reason];
	[errors addObject:error];
}

-(void)onExample:(NSString *)example {
	currentExample = example;
	NSLog(@"\n- %@", currentExample);
}

-(void)onExampleException:(NSException *)exception {
	NSString *error = [NSString stringWithFormat:@"%@ %@ FAILED \n%@", currentSpec, currentExample, exception.reason];
	[errors addObject:error];
}

-(void)onAfter:(NSString *)example {
	currentExample = example;
}

-(void)onAfterException:(NSException *)exception {
	NSString *error = [NSString stringWithFormat:@"%@ in %@ after %@ \n %@", exception.name, currentSpec, currentExample, exception.reason];
	[errors addObject:error];
}

-(void)onAfterAll{}

-(void)onAfterAllException:(NSException *)exception {
	NSString *error = [NSString stringWithFormat:@"%@ in %@ afterAll \n %@", exception.name, currentSpec, exception.reason];
	[errors addObject:error];
}

-(void)afterSpec:(AppSpec *)spec { }

-(void)onFinish:(int)count {
	NSMutableString *log = [NSMutableString string];
	if (errors.count > 0) {
		int num = 0;
		for (NSString *error in errors) {
			[log appendFormat:@"\n\n%i)", ++num];
			[log appendFormat:@"\n%@", error];
		}
	}
	[log appendFormat:@"\n\nFinished in %f seconds", fabsf([start timeIntervalSinceNow])];
	
	[log appendFormat:@"\n\n%i examples %d failures", count, errors.count];
	NSLog(@"%@",log);
}

@end
