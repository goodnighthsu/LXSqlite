//
//  LXAppDelegate.h
//  LeonXuSqite
//
//  Created by Leon on 13-2-4.
//  Copyright (c) 2013年 Leon. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Menu
@interface MenuEntity : NSObject

@property (assign) NSInteger sid;
@property (strong) NSString *title;
@property (strong) NSString *thumb;
@property (strong) NSString *image;
@property (strong) NSString *detail;
@property (assign) NSInteger typeID;
@property (assign) NSInteger pid;

@end

@interface LXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
