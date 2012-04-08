//
// Used to dynamically add all of the properties as methods onto UIQuery.
// This allows you to use <UIQueryInstance>.button, for example, in order to find a button
// Not sure why this is not embedded directly into UIQuery.

@class UIQuery;

@interface ViewFilterSwizzler : NSObject {
	UIQuery *textField, *navigationBar, *label, *button, *navigationButton, *alertView, *textView, *tableView, *tableViewCell, 
	*toolbar, *toolbarButton, *tabBar, *tabBarButton, *datePicker, *window, *webView, *view, *Switch, *slider, *segmentedControl,
	*searchBar, *scrollView, *progressView, *pickerView, *pageControl, *imageView, *control, *actionSheet, *activityIndicatorView,
	*threePartButton, *navigationItemButtonView, *navigationItemView, *removeControlMinusButton, *pushButton;
}

@property(nonatomic, readonly) UIQuery *textField, *navigationBar, *label, *button, *navigationButton, *alertView, *textView, *tableView, *tableViewCell, 
*toolbar, *toolbarButton, *tabBar, *tabBarButton, *datePicker, *window, *webView, *view, *Switch, *slider, *segmentedControl,
*searchBar, *scrollView, *progressView, *pickerView, *pageControl, *imageView, *control, *actionSheet, *activityIndicatorView,
*threePartButton, *navigationItemButtonView, *navigationItemView, *removeControlMinusButton, *pushButton;

+(void)initialize;
+(void)swizzleFiltersForClass:(Class )class;

@end
