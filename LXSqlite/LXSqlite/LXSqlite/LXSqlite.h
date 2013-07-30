//
//  LXSqlite.h
//  LeonXuSqite
//
//  Created by Leon on 13-2-4.
//  Copyright (c) 2013年 Leon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


/** 运行结果 */
@interface LXSqliteResult : NSObject

/// SQL成功或失败消息
@property (nonatomic, strong) NSString *message;
/// 状态码 200成功， 400失败
@property (nonatomic, assign) NSInteger code;
/// 运行结果
@property (nonatomic, strong) NSMutableArray *results;

@end


/**
 1、初始化数据库路径
 [LXSqlite shareInstance].dbPath = [[NSBundle mainBundle] pathForResource:@"PurpleMountain" ofType:@"sqlite"];
 
 2、根据需要获取SQL结果或执行SQL
 
 Model Class:
 + (LXSqliteResult \*)getModel:(NSString \*)className bySql:(NSString \*)sql;
 
 NSArry:
 + (LXSqliteResult \*)getDataSetBySql:(NSString \*)sql;
 
 NSDictionArry
 + (LXSqliteResult \*)getDataDicBySql:(NSString \*)sql;
 
 Excute SQL
 + (LXSqliteResult \*)executeSql:(NSString \*)sql
 
 3、获取 LXSqliteResult 结果
 
 LXSqliteResult == 200 获取成果
 
 LXSqliteResult.results 结果
*/
@interface LXSqlite : NSObject
{
    sqlite3 *_db;
}

///数据库路径
@property (nonatomic, strong) NSString *dbPath;

///单例
+ (LXSqlite *)shareInstance;

///Create
/** 
 创建一个数据, LXSqlite 在打开database的时候发现没有database的时候，默认不创建。这个和sqlite open 默认会创建database 有区别
 @param dbPath database路径
 @return LXSqliteResult 结果*/
+ (LXSqliteResult *)createDB:(NSString *)dbPath;

/** 结果为Model Class 的NSArray合集(直接根据Value Object构造), 允许和数据库的列不匹配
 @param className id Model Class
 @param sql NSString sql命令
 @return LXSqliteResult 结果  */
+ (LXSqliteResult *)getModel:(NSString *)className bySql:(NSString *)sql;

/** 结果为Model Class 的NSArray合集(直接根据Value Object构造
 @param className id Model Class
 @param sql NSString sql命令
 @param tolerance tolerance 是否允许和数据库的列不匹配
 @return LXSqliteResult 结果  */
+ (LXSqliteResult *)getModel:(NSString *)className bySql:(NSString *)sql tolerance:(BOOL)tolerance;

/** 结果为NSArray的合集(由array[][]构成的表)
 @param sql NSString sql命令
 @return LXSqliteResult 结果  */
+ (LXSqliteResult *)getDataSetBySql:(NSString *)sql;

/** 结果为NSDictionary的合集(由array[]dic{})
 @param sql NSString sql命令
 @return LXSqliteResult 结果  */ 
+ (LXSqliteResult *)getDataDicBySql:(NSString *)sql;

/** 执行Sql
 @param sql NSString sql命令
 @return LXSqliteResult 结果  */
+ (LXSqliteResult *)executeSql:(NSString *)sql;


/** Initail
@param dbPath Database path*/
- (id)initWithDbPath:(NSString *)dbPath;

/** 创建一个数据, LXSqlite 在打开database的时候发现没有database的时候，默认不创建。这个和sqlite open 默认会创建database 有区别
 @param dbPath dbPath 路径
 @return LXSqliteResult 结果*/
- (LXSqliteResult *)createDB:(NSString *)dbPath;

/** 结果为Model Class 的NSArray合集(直接根据Value Object构造
@param className  Model Class
@param sql sql命令 
@param tolerance tolerance 是否允许和数据库的列不匹配
@return LXSqliteResult 结果  */
- (LXSqliteResult *)getModel:(NSString *)className bySql:(NSString *)sql tolerance:(BOOL)tolerance;

/** 结果为NSArray的合集(由array[][]构成的表)
 @param sql NSString sql命令
 @return LXSqliteResult 结果  */
- (LXSqliteResult *)getDataSetBySql:(NSString *)sql;

/** 结果为NSDictionary的合集(由array[]dic{})
 @param sql NSString sql命令
 @return LXSqliteResult 结果  */
- (LXSqliteResult *)getDataDicBySql:(NSString *)sql;

/** 执行Sql
 @param sql NSString sql命令
 @return LXSqliteResult 结果  */
- (LXSqliteResult *)executeSql:(NSString *)sql;

@end
