//
//  CopyLinkToPasteboard.m
//  Stand for Something
//
//  Created by Alper Cugun on 5/9/14.
//  Copyright (c) 2014 Alper Cugun. All rights reserved.
//

#import "CopyLinkToPasteboardActivity.h"

@implementation CopyLinkToPasteboardActivity

- (NSString *)activityType {
    return @"eu.hubbub.standing.copyLinkToPasteboardActivity";
}

- (NSString *)activityTitle {
    return @"Copy link";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"Copy-ios7"];
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
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:[[self.url absoluteString] stringByAppendingString:@"/"]];
    
    [self activityDidFinish:YES];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Copied";
    
    [hud show:YES];
    [hud hide:YES afterDelay:0.8];
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

@end
