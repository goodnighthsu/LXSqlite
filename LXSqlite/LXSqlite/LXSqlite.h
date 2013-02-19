//
//  LXSqlite.h
//  LeonXuSqite
//
//  Created by Leon on 13-2-4.
//  Copyright (c) 2013年 Leon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Column : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger type;

@end

@interface LXSqliteResult : NSObject

@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSMutableArray *results;

@end

@interface LXSqlite : NSObject
{
    sqlite3 *_db;
}

@property (nonatomic, strong) NSString *dbPath;
@property (nonatomic, strong) NSString *state;

+ (LXSqlite *)shareInstance;
+ (LXSqliteResult *)getModel:(NSString *)className bySql:(NSString *)sql;
+ (LXSqliteResult *)getDataSetBySql:(NSString *)sql;
+ (LXSqliteResult *)getDataDicBySql:(NSString *)sql;


//
- (id)initWithDbPath:(NSString *)dbPath;
//Model(直接根据Value Object构造）
- (LXSqliteResult *)getModel:(NSString *)className bySql:(NSString *)sql;
//DataSet(由array[][]构成的表)
- (LXSqliteResult *)getDataSetBySql:(NSString *)sql;
//DataDic(有array[][]dic{})
- (LXSqliteResult *)getDataDicBySql:(NSString *)sql;

//在LXSqliteResult.state 中返回成功与否
- (LXSqliteResult *)executeSql:(NSString *)sql;

@end
