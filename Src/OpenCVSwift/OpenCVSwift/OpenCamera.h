//
//  OpenCVWrapper.h
//  OpenCVSwift
//
//  Created by Logan Jahnke on 11/28/18.
//  Copyright © 2018 Logan Jahnke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Protocol for callback action
@protocol OpenCameraDelegate <NSObject>
- (void)updatePercentage;
@end

// Public interface for camera. ViewController only needs to init, start and stop.
@interface OpenCamera : NSObject

@property(readonly) int total_cooked_pixels;
@property(readonly) int total_uncooked_pixels;

@property(readonly) int avg_red;
@property(readonly) int avg_green;
@property(readonly) int avg_blue;

- (UIImage *)edges:(UIImage *)img;
- (UIImage *)threshold:(UIImage *)img;
- (id) initWithController: (UIViewController<OpenCameraDelegate>*)c andImageView: (UIImageView*)iv;
- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
