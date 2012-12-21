//
//  UIView+RCLGeometryAdditions.m
//  ReactiveCocoaLayout
//
//  Created by Justin Spahr-Summers on 2012-12-13.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "UIView+RCLGeometryAdditions.h"
#import "EXTScope.h"
#import "RACSignal+RCLGeometryAdditions.h"

@implementation UIView (RCLGeometryAdditions)

// FIXME: These properties aren't actually declared as KVO-compliant by UIKit.
// Here be dragons?
- (RACSignal *)rcl_boundsSignal {
	return RACAbleWithStart(self.bounds).distinctUntilChanged;
}

- (RACSignal *)rcl_frameSignal {
	return RACAbleWithStart(self.frame).distinctUntilChanged;
}

- (RACSignal *)rcl_baselineSignal {
	__weak UIView *baselineView = self.viewForBaselineLayout;

	@weakify(self);
	return [RACSignal combineLatest:@[ self.rcl_boundsSignal, self.viewForBaselineLayout.rcl_frameSignal ] reduce:^(NSValue *bounds, NSValue *baselineViewFrame) {
		@strongify(self);

		NSAssert([baselineView isEqual:self.viewForBaselineLayout], @"-viewForBaselineLayout for %@ changed from %@ to %@", self, baselineView, baselineView);
		NSAssert([baselineView isDescendantOfView:self], @"%@ must be a descendant of %@ to be its viewForBaselineLayout", baselineView, self);

		CGRect topLevelFrame = [baselineView.superview convertRect:baselineViewFrame.med_rectValue toView:self];
		return @(CGRectGetMaxY(topLevelFrame));
	}].distinctUntilChanged;
}

@end
