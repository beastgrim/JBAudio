//
//  JBFlacSupport.h
//  Over Task
//
//  Created by Евгений Богомолов on 19.03.15.
//  Copyright (c) 2015 Евгений Богомолов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JBFlacSupport : NSObject

+ (NSURL *) wavToFlac:(NSURL *)wavPath;

@end
