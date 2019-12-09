//
//  RUIExceptionCatcher.m
//  ReactantLiveUI
//
//  Created by Tadeas Kriz on 13/04/2018.
//

#import "RUIExceptionCatcher.h"

@implementation RUIExceptionCatcher

+(nullable id)catchExceptionIn:(__attribute__((noescape)) id _Nonnull (^_Nonnull)(void))block error:(NSError* _Nullable*_Nullable)errorPtr {
    @try {
        return block();
    }
    @catch (id exception) {
        NSError* error = [[NSError alloc] initWithDomain: @"org.brightify.reactantui"
                                                    code: 1
                                                userInfo: @{ @"exception": exception }];
        *errorPtr = error;
        return nil;
    }

}

@end
