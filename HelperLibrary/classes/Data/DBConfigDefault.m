//
//  Copyright (c) 2012 Rondinelli Morais. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
//  Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "DBConfigDefault.h"

@implementation DBConfigDefault

// ------------------------------------------------------------------------
// Public Methods
// ------------------------------------------------------------------------
#pragma mark - Public Methods
+ (instancetype)managerContext {
    
    DBConfigDefault * dbConfigDefault = [DBConfigDefault sharedInstance];
    
    if(dbConfigDefault){
        [dbConfigDefault _managerContext];
    }
    return dbConfigDefault;
}

+ (instancetype)managerContextWithDelegate:(id<DBConfigDefaultDelegate>)delegate {
    
    DBConfigDefault * dbConfigDefault = [DBConfigDefault sharedInstance];
    
    if(dbConfigDefault){
        [dbConfigDefault setDelegate:delegate];
        [dbConfigDefault _managerContext];
    }
    return dbConfigDefault;
}

// ------------------------------------------------------------------------
// Private Methods
// ------------------------------------------------------------------------
#pragma mark - Private Methods
+ (instancetype)sharedInstance {
    static DBConfigDefault *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)_managerContext {
    
    CGFloat dbVersion = [self appVersion];
    
    CGFloat appVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] doubleValue];
    
    if((appVersion != dbVersion) && (appVersion > dbVersion))
    {
        BOOL isUpdateDatabase = YES;

        // Lista os arquivos de update
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:bundlePath error:nil];
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'db-script-update-'"];
        NSArray *scriptsUpdate = [dirContents filteredArrayUsingPredicate:predicate];
        

        // verifica se há scripts de atualizações para esta versão
        __block NSMutableArray * scriptsForUpdate = [NSMutableArray new];
        
        CGFloat versions = dbVersion;
        
        NSInteger count = roundf(((appVersion - dbVersion) * 10));
        
        for (int i = 0; i < count; i++) {
            versions += .1;
            if([scriptsUpdate containsObject:[NSString stringWithFormat:@"db-script-update-v%.1f.sql", versions]]){
                [scriptsForUpdate addObject:[NSString stringWithFormat:@"db-script-update-v%.1f.sql", versions]];
            }
        }
        
        __block NSInteger numberOfScripts = scriptsForUpdate.count;
        
        if(scriptsForUpdate != nil && numberOfScripts > 0)
        {
            [scriptsForUpdate enumerateObjectsUsingBlock:^(NSString * scriptUpdate, NSUInteger idx, BOOL *stop) {
                
                // executa o script
                NSLog(@"Executando script de atualização SQL: %@", scriptUpdate);
                
                NSString *pathScriptUpdate = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:scriptUpdate];
                BOOL sucesso = [self executeScriptUpdate:pathScriptUpdate];
                
                if(sucesso){
                    NSLog(@"script de atualização '%@' executado com sucesso!", scriptUpdate);
                    numberOfScripts--;
                }
                else {
                    NSLog(@"ocorreu um erro ao executar o script '%@' de atualização!", scriptUpdate);
                }
            }];
            
            // verifica se executou com sucesso todos os scripts
            isUpdateDatabase = (numberOfScripts == 0);
        }
        
        if(isUpdateDatabase) {
            [self updateAppVersion:dbVersion newVersion:appVersion];
        }

        [self close];
    }
}

- (BOOL)executeBatch:(NSString *)sql error:(NSError**)error {
    
    char* errorOutput;
    int responseCode = sqlite3_exec([[self db] sqliteHandle], [sql UTF8String], NULL, NULL, &errorOutput);
    
    if (errorOutput != nil)
    {
        NSString * errorMsg = [NSString stringWithUTF8String:errorOutput];
        *error = [NSError errorWithDomain:@"DBConfigDefaultDomain"
                                     code:responseCode
                                 userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)executeScriptUpdate:(NSString*)scriptPath {
    
    NSString * fileString = [self readSQLfile:scriptPath];
    
    NSError * error;
    BOOL batchResult = [self executeBatch:fileString error:&error];
    
    if(error) {
        NSString * erroMessage = [error localizedDescription];
        if([erroMessage hasPrefix:@"duplicate column name"]){
            NSLog(@"%@", erroMessage);
            return YES;
        }
    }
    
    return batchResult;
}

- (NSString*)readSQLfile:(NSString*)pathScriptUpdate {
    
    NSString *fileString = [NSString stringWithContentsOfFile:pathScriptUpdate encoding:NSUTF8StringEncoding error:nil];
    
#if DEBUG
    NSLog(@"*************** INICIO DO ARQUIVO ***************************************");
    NSLog(@"\n\n%@\n", fileString);
    NSLog(@"*************** FIM DO ARQUIVO ******************************************\n\n");
#endif
    
    return fileString;
}

- (CGFloat)appVersion {
    
    CGFloat version = 0.0;
    
    FMResultSet * rs = [[self db] executeQuery:@" select ssc_vlr from configdefault where upper(ssc_dsc) like 'APP_VERSION' or 'VERSAO_APP' "];
    while ([rs next]) {
        version = [rs doubleForColumn:@"ssc_vlr"];
    }
    
    return version;
}

- (void)updateAppVersion:(CGFloat)oldVersion newVersion:(CGFloat)newVersion {
    
    NSString * appversion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSLog(@"Atualizando versão do banco: %@", appversion);
    
    if([[self db] executeUpdate:@" update configdefault set ssc_vlr = ? where upper(ssc_dsc) like 'APP_VERSION' ", appversion]){
        
        if([_delegate respondsToSelector:@selector(dbConfigDefaultDidUpdatedDatabase:newVersion:)]){
            [_delegate dbConfigDefaultDidUpdatedDatabase:oldVersion newVersion:newVersion];
        }
    }
}

@end
