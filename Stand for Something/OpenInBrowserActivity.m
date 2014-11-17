//
//  OpenInBrowserActivity.m
//  Stand for Something
//
//  Created by Alper Cugun on 5/9/14.
//  Copyright (c) 2014 Alper Cugun. All rights reserved.
//

#import "OpenInBrowserActivity.h"

@implementation OpenInBrowserActivity

- (NSString *)activityType {
    return @"eu.hubbub.standing.openInBrowserActivity";
}

- (NSString *)activityTitle {
    return @"Open in browser";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"share-browser-button"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	for (id item in activityItems){
		if ([item isKindOfClass:NSURL.class]){
			return YES;
		}
	}
	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
		if ([item isKindOfClass:NSURL.class]) {
			self.url = (NSURL *)item;
			return;
		}
	}
}

- (void)performActivity {
    [[UIApplication sharedApplication] openURL:self.url];
    
    [self activityDidFinish:YES];
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}
@end
