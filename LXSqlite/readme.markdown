Objective-c 封装的sqlite接口

#安装#
1、添加LXSqlite下的LXSqlite.h、 LXSqlite.m

2、添加libsqlite3.0.dylib

#使用
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

