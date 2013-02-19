//
//  LXAppDelegate.m
//  LeonXuSqite
//
//  Created by Leon on 13-2-4.
//  Copyright (c) 2013年 Leon. All rights reserved.
//

#import "LXAppDelegate.h"
#import "LXSqlite.h"


@implementation MenuEntity

@end

@implementation LXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self test];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)test
{
    [LXSqlite shareInstance].dbPath = @"/Users/leon/Documents/PurpleMountain.sqlite";
    
    //测试 getModel
    /*
     LXSqliteResult *menus = [LXSqlite getModel:@"MenuEntity" bySql:@"select * from Menu_Table"];
     NSLog(@"state : %@", menus.state);
     for (MenuEntity *menuEntity in menus.results) {
     NSLog(@"titlel: %@  detail:%@", menuEntity.title, menuEntity.detail);
     }
     */
    
    //测试 getDataSet
    /*
     LXSqliteResult *menus = [LXSqlite getDataSetBySql:@"select id, title from Menu_Table"];
     NSLog(@"menus.state :%@", menus.state);
     NSLog(@"id: %i", [menus.results[1][0] integerValue]);
     NSLog(@"title: %@", menus.results[1][1]);
     
     LXSqliteResult *menus1 = [LXSqlite getDataSetBySql:@"select introid from Menu_Table"];
     NSLog(@"menus.state :%@", menus1.state);
     NSLog(@"intorid: %i", [menus1.results[1][0] integerValue]);
     */
    
    //测试 getDataDic
    LXSqliteResult *menus = [LXSqlite getDataDicBySql:@"select id, title from Menu_Table"];
    NSLog(@"menus.state :%@", menus.state);
    if (menus.results != nil) {
        NSLog(@"id: %i", [menus.results[1][0][@"id"] integerValue]);
        NSLog(@"title: %@", menus.results[1][1][@"title"]);
    }
    
    LXSqliteResult *menus1 = [LXSqlite getDataDicBySql:@"select introid1 from Menu_Table"];
    NSLog(@"menus.state :%@", menus1.state);
    if (menus1.results != nil) {
        NSLog(@"intorid: %i", [menus1.results[1][0][@"id"] integerValue]);
    }
    
    
    //测试 exeSql
    //LXSqliteResult *deleteResult = [lxSqlite executeSql:@"DELETE FROM Menu_Table WHERE id = 109"];
    //NSLog(@"delete state: %@", deleteResult.state);
    
}


@end
