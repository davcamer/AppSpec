@class AppSpec;

@protocol UILog

-(void)onStart;
-(void)onSpec:(AppSpec *)spec;
-(void)onBeforeAll;
-(void)onBeforeAllException:(NSException *)exception;
-(void)onBefore:(NSString *)example;
-(void)onBeforeException:(NSException *)exception;
-(void)onExample:(NSString *)example;
-(void)onExampleException:(NSException *)exception;
-(void)onAfter:(NSString *)example;
-(void)onAfterException:(NSException *)exception;
-(void)onAfterAll;
-(void)onAfterAllException:(NSException *)exception;
-(void)afterSpec:(AppSpec *)spec;
-(void)onFinish:(int)count;

@end
