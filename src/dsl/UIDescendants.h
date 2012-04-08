
@interface UIDescendants : NSObject {

}

-(NSArray *)collect:(NSArray *)views;
-(void)collectDescendantsOnView:(NSView *)view inToArray:(NSMutableArray *)array;
+(id)withTraversal;

@end
