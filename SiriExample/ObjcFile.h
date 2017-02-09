//
//  ObjcFile.h
//  PassDemo
//
//  Created by Parth Dubal on 1/24/17.
//  Copyright © 2017 Parth Dubal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObjcFileProtocol <NSObject>



@end

@interface ObjcFile : NSObject


- (void)doSomethingForClass:(Class<ObjcFileProtocol>)codingClass;


@end
