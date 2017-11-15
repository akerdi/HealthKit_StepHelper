//
//  HealthKitHelper.h
//  HealthKitTest
//
//  Created by aKerdi on 2017/10/30.
//  Copyright © 2017年 XXT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HealthHelperData;
@interface HealthKitHelper : NSObject

/**
 判断是否authroize 健康
 
 @param callback YES 成功    NO 失败
 */
- (void)authroizeHealthStore:(void(^_Nullable)(BOOL authoized))callback;

/** 获取component 分段数据 30天*/
- (void)fetchApproximateStepDataWithCallback:(void(^_Nullable)(NSArray<HealthHelperData *> *_Nullable dataArray))callback;

@end

@interface HealthHelperData : NSObject

@property (nonatomic , copy) NSString * _Nonnull dateString;//时间戳，表示数据对应的时间 注意是整点数的时间戳，如2017-10-28 0:0:0
@property (nonatomic, strong) NSNumber * _Nonnull step;

@end

