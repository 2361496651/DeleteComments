//
//  main.m
//  DeleteComments(删除注释)
//
//  Created by zengchunjun on 2018/4/26.
//  Copyright © 2018年 曾春军. All rights reserved.
//

#import <Foundation/Foundation.h>


void deleteComments(NSString *directory);//删除注释

BOOL regularReplacement(NSMutableString *originalString, NSString *regularExpression, NSString *newString);//正则替换

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        NSString *srcPath = @"/Users/zengchunjun/Desktop/testComments/testComments";//源代码路径文件夹
        
        deleteComments(srcPath);
        
        NSLog(@"delete comments success");
        
    }
    return 0;
}


void deleteComments(NSString *directory){
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *fileName in files) {
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory) {
            deleteComments(filePath);
            continue;
        }
        if (![fileName hasSuffix:@".h"] && ![fileName hasSuffix:@".m"] && ![fileName hasSuffix:@".swift"] && ![fileName hasSuffix:@".mm"] && ![fileName hasSuffix:@".cpp"]) continue;
        NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        regularReplacement(fileContent, @"([^:/])//.*",             @"\\1"); //.m文件中方法实现里的 //注释
        regularReplacement(fileContent, @"^//.*",                   @""); //头部注释部分
        regularReplacement(fileContent, @"/\\*{1,2}[\\s\\S]*?\\*/", @""); //方法注释
//        regularReplacement(fileContent, @"^\\s*\\n",                @""); //去除换行
        [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
}


BOOL regularReplacement(NSMutableString *originalString, NSString *regularExpression, NSString *newString) {
    __block BOOL isChanged = NO;
    BOOL isGroupNo1 = [newString isEqualToString:@"\\1"];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnixLineSeparators error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:originalString options:0 range:NSMakeRange(0, originalString.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!isChanged) {
            isChanged = YES;
        }
        if (isGroupNo1) {
            NSString *withString = [originalString substringWithRange:[obj rangeAtIndex:1]];
            [originalString replaceCharactersInRange:obj.range withString:withString];
        } else {
            [originalString replaceCharactersInRange:obj.range withString:newString];
        }
    }];
    return isChanged;
}
