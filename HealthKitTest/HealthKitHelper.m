//
//  HealthKitHelper.m
//  HealthKitTest
//
//  Created by aKerdi on 2017/10/30.
//  Copyright © 2017年 XXT. All rights reserved.
//

#import "HealthKitHelper.h"

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

#ifdef DEBUG

#else
#define NSLog(...)
#endif

static NSInteger _farFromToday = 30;
@interface HealthKitHelper () {
    HKHealthStore *_healthStore;
}

@end

@implementation HealthKitHelper

- (instancetype)init {
    if (self=[super init]) {
        if ([HKHealthStore isHealthDataAvailable]) {
            NSLog(@"%@",@"healthDataAvailable");
            _healthStore = [HKHealthStore new];
        }
    }
    return self;
}

- (void)authroizeHealthStore:(void(^)(BOOL authoized))callback {
    if (!_healthStore) {
        if (callback) callback(NO);
        return;
    }
    HKObjectType *objectType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSet *readObjectTypes = [NSSet setWithObjects:objectType, nil];
    [_healthStore requestAuthorizationToShareTypes:nil readTypes:readObjectTypes completion:^(BOOL success, NSError * _Nullable error) {
        if (success&&!error) {
            NSLog(@"%@",@"requestAuthorization: success");
            BOOL realSuccess = [self anyPermissionIsGiven];
            if (callback) callback(realSuccess);
        }else{
            NSLog(@"%@",error.description);
            if (callback) callback(NO);
        }
    }];
}

- (void)fetchApproximateStepDataWithCallback:(void(^)(NSArray<HealthHelperData *> *_Nullable dataArray))callback {
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = 1;
    NSDate *anchorDate = [HealthKitHelper farfromTodayByAddingDays:-_farFromToday];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startDate > %@",anchorDate];
    HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum|HKStatisticsOptionSeparateBySource anchorDate:anchorDate intervalComponents:dateComponents];
    collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery * _Nonnull query, HKStatisticsCollection * _Nullable result, NSError * _Nullable error) {
        if (result&&!error) {
            NSMutableArray *datas = [NSMutableArray arrayWithCapacity:0];
            for (HKStatistics *statistic in result.statistics) {
                NSLog(@"\n%@ 至 %@",statistic.startDate, statistic.endDate);
                for (HKSource *source in statistic.sources) {
                    if ([source.name isEqualToString:[UIDevice currentDevice].name]) {
                        HealthHelperData *helperData = [HealthHelperData new];
                        helperData.dateString = [HealthKitHelper formatDate:statistic.startDate];
                        helperData.step = @([[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]]);
                        NSLog(@"%@,%s",helperData,__FILE__);
                        [datas addObject:helperData];
                    }
                }
            }
            if (callback) callback(datas);
        }
    };
    [_healthStore executeQuery:collectionQuery];
}

#pragma mark - Permission Helper

- (BOOL)anyPermissionIsGiven {
    NSMutableArray * authArray = [[NSMutableArray alloc]init];
    
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySodium]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFiber]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminA]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminB6]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminC]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminE]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryVitaminK]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCalcium]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryThiamin]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFolate]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPhosphorus]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryMagnesium]];
    [authArray addObject:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryPotassium]];
    
    BOOL anyPermissionGiven = NO;
    for (HKQuantityType * quantityType in authArray) {
        if([_healthStore authorizationStatusForType:quantityType] == HKAuthorizationStatusSharingAuthorized) {
            anyPermissionGiven = YES;
            break;
        }
    }
    
    return anyPermissionGiven;
}

#pragma mark - date Helper

+ (NSDate *)farfromTodayByAddingDays:(NSInteger)dDays {
    NSDateComponents *dateComponents = [NSDateComponents new];
    [dateComponents setDay:dDays];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    newDate = [[NSCalendar currentCalendar] dateBySettingHour:0 minute:0 second:0 ofDate:newDate options:0];
    return newDate;
}

+ (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *dateformat = [NSDateFormatter new];
    [dateformat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [dateformat stringFromDate:date];
    return dateString;
}

@end



@implementation HealthHelperData

- (NSString *)description {
    return [NSString stringWithFormat:@"%@   %@",self.dateString,self.step];
}
@end

#ifdef DEBUG

#else
#undef NSLog
#endif
