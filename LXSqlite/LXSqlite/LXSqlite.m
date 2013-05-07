//
//  LXSqlite.m
//  LeonXuSqite
//
//  Created by Leon on 13-2-4.
//  Copyright (c) 2013年 Leon. All rights reserved.
//

#import "LXSqlite.h"
//#import <objc/runtime.h>

static LXSqlite *shareInstance = nil;

@implementation Column

@end

@implementation LXSqliteResult

- (id)init
{
    self = [super init];
    if (self) {
        self.results = [NSMutableArray array];
    }
    return self;
}


@end

@implementation LXSqlite

- (id)initWithDbPath:(NSString *)dbPath
{
    self = [super init];
    if (self) {
        NSAssert(dbPath != nil || ![dbPath isEqualToString:@""], @"LXSqlite error: dbPath = nil");
        self.dbPath = dbPath;
    }
    
    return self;
}

#pragma mark 单例
+ (LXSqlite *)shareInstance
{
    @synchronized(self)
    {
        if (shareInstance == nil) {
            shareInstance = [[self alloc] init];
        }
    }
    
    return  shareInstance;
}

+ (LXSqliteResult *)getModel:(NSString *)className bySql:(NSString *)sql
{
    __autoreleasing LXSqlite *lxSqlite = [LXSqlite shareInstance];
    return [lxSqlite getModel:className bySql:sql];
}

+ (LXSqliteResult *)getDataSetBySql:(NSString *)sql
{
    __autoreleasing LXSqlite *lxSqlite = [LXSqlite shareInstance];
    return [lxSqlite getDataSetBySql:sql];
}

+ (LXSqliteResult *)getDataDicBySql:(NSString *)sql
{
    __autoreleasing LXSqlite *lxSqlite = [LXSqlite shareInstance];
    return [lxSqlite getDataDicBySql:sql];
}

#pragma mark - OPEN & CLOSE DB
- (LXSqliteResult *)openDB:(NSString *)dbPath  callback:(LXSqliteResult *(^)())callback
{
    __autoreleasing LXSqliteResult *result = [[LXSqliteResult alloc] init];
    NSAssert(dbPath != nil, @"LXSqlite error: dbPath = nil");
    NSAssert(![dbPath isEqualToString:@""], @"LXSqlite error: dbPath = NULL");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL find = [fileManager fileExistsAtPath:dbPath];
    if (find) {
        if(sqlite3_open([dbPath UTF8String], &_db) == SQLITE_OK)
        {
            result = callback();
        }else{
            result.results = nil;
            result.state = [self errorMessage:dbPath errorMessage:@"can not open database"];
        }
        sqlite3_close(_db);
    }else
    {
        result.results = nil;
        result.state = [self errorMessage:dbPath errorMessage:@"can not find database"];
    }
    
    
    
    return result;
}

- (LXSqliteResult *)openDB:(LXSqliteResult *(^)())callbackBlock
{
    return [self openDB:self.dbPath callback:callbackBlock];
}

#pragma mark - get statement
- (LXSqliteResult *)getStatement:(NSString *)sql callback:(LXSqliteResult *(^)(sqlite3_stmt *))callback
{
    __autoreleasing LXSqliteResult *result = [self openDB:^{
        __autoreleasing LXSqliteResult *result = [[LXSqliteResult alloc] init];
        sqlite3_stmt *statement;
        NSInteger errorCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &statement, nil);
        
        if (errorCode != SQLITE_OK) {
            //sql 错误
            result.results = nil;
            result.state = [self errorMessage:sql errorCode:errorCode];
        }else{
            //sql 正确解析
            //get column struct
            result = callback(statement);
            result.state = [self succeedMessage:sql];
            
            if (result.results.count == 0) {
                result.results = nil;
            }
        }
        
        //释放staement
        sqlite3_finalize(statement);
        
        return result;
    }];
    
    return result;
}

#pragma mark - Get Model
- (LXSqliteResult *)getModel:(NSString *)className bySql:(NSString *)sql
{
    __autoreleasing LXSqliteResult *result = [self getStatement:sql callback:^(sqlite3_stmt *statement)
                                              {
                                                  __autoreleasing LXSqliteResult *result = [[LXSqliteResult alloc] init];
                                                  NSArray *columns = [self getColumn:statement];
                                                  
#warning 应该在这里比对下model 和 数据库Columns
                                                  
                                                  while (sqlite3_step(statement) == SQLITE_ROW) {
                                                      id model = [[NSClassFromString(className) alloc] init];
                                                      for (NSInteger n = 0; n < columns.count; n++) {
                                                          
                                                          id value = [self getColumnValue:statement atIndex:n];
                                                          //value = Null 时，nil
                                                          if (![value isEqual:[NSNull null]]) {
                                                              Column *column = [columns objectAtIndex:n];
                                                              [model setValue:value forKey:column.name];
                                                          }
                                                      }
                                                      
                                                      [result.results addObject:model];
                                                  }
                                                  
                                                  return  result;
                                              }];
    
    return result;
}

#pragma mark - Get DataSet
- (LXSqliteResult *)getDataSetBySql:(NSString *)sql
{
    __autoreleasing LXSqliteResult *result = [self getStatement:sql callback:^(sqlite3_stmt *statement){
        __autoreleasing LXSqliteResult *result = [[LXSqliteResult alloc] init];
        //
        NSArray *columns = [self getColumn:statement];
        //
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableArray *arrays = [NSMutableArray array];
            for (NSInteger n = 0; n < columns.count; n++) {
                //
                id value = [self getColumnValue:statement atIndex:n];
                if (![value isEqual:[NSNull null]])
                {
                    [arrays addObject:value];
                }
            }
            
            [result.results addObject:arrays];
        }
        
        return result;
    }];
    
    return result;
}

#pragma mark - Get Dic
- (LXSqliteResult *)getDataDicBySql:(NSString *)sql
{
    __autoreleasing LXSqliteResult *result = [self getStatement:sql callback:^(sqlite3_stmt *statement){
        __autoreleasing LXSqliteResult *result = [[LXSqliteResult alloc] init];
        //
        NSArray *columns = [self getColumn:statement];
        //
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableArray *arrays = [NSMutableArray array];
            for (NSInteger n = 0; n < columns.count; n++) {
                //
                id value = [self getColumnValue:statement atIndex:n];
                if (![value isEqual:[NSNull null]]) {
                    Column *column = [columns objectAtIndex:n];
                    NSDictionary *columnDic = [NSDictionary dictionaryWithObject:value forKey:column.name];
                    
                    [arrays addObject:columnDic];
                }
                
            }
            
            [result.results addObject:arrays];
        }
        
        return result;
    }];
    
    return result;
}


#pragma mark - Execute Sql
- (LXSqliteResult *)executeSql:(NSString *)sql
{
    __autoreleasing LXSqliteResult *result = [self openDB:^
                                              {
                                                  __autoreleasing LXSqliteResult *result = [[LXSqliteResult alloc] init];
                                                  char *err;
                                                  if (sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
                                                  {
                                                      result.state = [self errorMessage:sql errorMessage:[NSString stringWithUTF8String:err]];
                                                      sqlite3_free(err);
                                                  }else{
                                                      result.state = [self succeedMessage:sql];
                                                  }
                                                  
                                                  return result;
                                              }];
    
    return  result;
}

#pragma mark - Column
//获取columnName, 空置 nil;
- (NSArray *)getColumn:(sqlite3_stmt *)statement
{
    __autoreleasing NSMutableArray *results = [NSMutableArray array];
    for (NSInteger n = 0; n < sqlite3_column_count(statement); n++) {
        //column name
        Column *column = [[Column alloc] init];
        const char *name = sqlite3_column_name(statement, n);
        column.name = [NSString stringWithUTF8String:name];
        
        //column type
        column.type = sqlite3_column_type(statement, n);
        [results addObject:column];
    }
    
    //
    if (results.count == 0)
    {
        results = nil;
    }
    return results;
}


#pragma mark - Column Value
//获取columnValue, 空置 NSNull, 不能为nil
- (id )getColumnValue:(sqlite3_stmt *)statement atIndex:(NSInteger)index
{
    __autoreleasing id result = nil;
    
    NSInteger type = sqlite3_column_type(statement, index);
    
    switch (type) {
        case SQLITE_INTEGER:
        {
            int resultInt = sqlite3_column_int(statement, index);
            result = [NSNumber numberWithInt:resultInt];
        }
            break;
            
        case SQLITE_FLOAT:
        {
            float resultFloat = sqlite3_column_double(statement, index);
            result = [NSNumber numberWithFloat:resultFloat];
        }
            break;
            
        case SQLITE_BLOB:
        {
            bool resultBool = sqlite3_column_blob(statement, index);
            result = [NSNumber numberWithBool:resultBool];
        }
            break;
            
        case SQLITE_TEXT:
        {
            const char *resultChar = (const char *)sqlite3_column_text(statement, index);
            if (resultChar == NULL) {
                result = [NSNull null];
            }else{
                result = [NSString stringWithUTF8String:resultChar];
            }
        }
            break;
            
        case SQLITE_NULL:
        {
            //NSLog(@"LXSqlite->getColumnValue:atIndex->sqilte = null atIndex %i", index);
            result = [NSNull null];
        }
            break;
            
        default:
            break;
    }
    
    //在DataSet和DataDic 里有NSArray addObject这样的操作，所有不能有nil
    NSAssert(result != nil, @"getColumnValue atindex = nil");
    
    return result;
}

//获取all columnValue, 空置 nil
- (NSArray *)getAllColumnValue:(sqlite3_stmt *)statement
{
    __autoreleasing NSMutableArray *results = [NSMutableArray array];
    
    for (NSInteger n = 0; n < sqlite3_column_count(statement); n++) {
        id value = [self getColumnValue:statement atIndex:n];
        [results addObject:value];
    }
    
    if (results.count == 0)
    {
        results = nil;
    }
    
    return results;
}

#pragma mark - Deprecated
/*
 - (LXSqliteResult *)getModel:(NSString *)className bySql:(NSString *)sql
 {
 __autoreleasing LXSqliteResult *result = [self openDB:^{
 LXSqliteResult *result = [[LXSqliteResult alloc] init];
 sqlite3_stmt *statement;
 NSInteger errorCode = sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil);
 
 if (errorCode != SQLITE_OK) {
 //sql 错误
 result.state = [self errorMessage:sql errorCode:errorCode];
 }else{
 //sql 正确解析
 while (sqlite3_step(statement) == SQLITE_ROW) {
 //
 id _model =  [self checkProperty:className statement:statement];
 [result.results addObject:_model];
 }
 result.state = [self succeedMessage:sql];
 }
 
 //释放staement
 sqlite3_finalize(statement);
 
 return result;
 }];
 
 return result;
 }
 
 
 
 //按照数据库的定义，构造了model Class
 - (id)checkProperty:(NSString *)className statement:(sqlite3_stmt *)statement
 {
 __autoreleasing id model = [[NSClassFromString(className) alloc] init];
 unsigned int outCount, index;
 objc_property_t *properties = class_copyPropertyList([model class], &outCount);
 for (index = 0; index<outCount; index++)
 {
 objc_property_t property = properties[index];
 //属性name
 const char* char_name =property_getName(property);
 NSString *propertyName = [NSString stringWithUTF8String:char_name];
 //属性attribut
 const char* char_attribute = property_getAttributes(property);
 NSString *propertyAttribute = [NSString stringWithUTF8String:char_attribute];
 
 //封装
 NSArray *attributs = [propertyAttribute componentsSeparatedByString:@","];
 if ([attributs count] != 0) {
 NSString *type = attributs[0];
 //enmu、int、signed
 if ([type isEqualToString:@"Ti"]) {
 int intResult = (int)sqlite3_column_int(statement, index);
 [model setValue:[NSNumber numberWithInt:intResult] forKey:propertyName];
 }
 
 //float
 if ([type isEqualToString:@"Tf"]) {
 float floatResult = (float)sqlite3_column_double(statement, index);
 [model setValue:[NSNumber numberWithDouble:floatResult] forKey:propertyName];
 }
 
 //NSString
 if ([type isEqualToString:@"T@\"NSString\""]) {
 char *charResult =  (char *)sqlite3_column_text(statement, index);
 if (charResult == NULL) {
 //null
 [model setValue:[NSNull null] forKey:propertyName];
 }else{
 [model setValue:[NSString stringWithUTF8String:charResult] forKey:propertyName];
 }
 }
 }
 }
 
 free(properties);
 if (model == nil) {
 model = [NSNull null];
 }
 return model;
 }
 */

#pragma mark - Message
- (NSString *)succeedMessage:(NSString *)sql
{
    __autoreleasing NSString *result = [NSString stringWithFormat:@"Successed -> %@",sql];
    return result;
}

- (NSString *)errorMessage:(NSString *)sql errorCode:(NSInteger)errorCode
{
    __autoreleasing NSString *result = [NSString stringWithFormat:@"Error -> %@, errorCode: %i", sql, errorCode];
    return result;
}

- (NSString *)errorMessage:(NSString *)sql errorMessage:(NSString *)errorMessage
{
    __autoreleasing NSString *result = [NSString stringWithFormat:@"Error -> %@, errorMessage: %@", sql, errorMessage];
    return  result;
}

@end
