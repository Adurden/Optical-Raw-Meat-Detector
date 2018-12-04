//
//  OpenCVWrapper.m
//  OpenCVSwift
//
//  Created by Logan Jahnke on 11/28/18.
//  Copyright © 2018 Logan Jahnke. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCamera.h"

using namespace std;

@interface OpenCamera () <CvVideoCameraDelegate>
@end

@implementation OpenCamera
{
    int _total_cooked_pixels;
    int _total_uncooked_pixels;
    
    int _avg_red;
    int _avg_green;
    int _avg_blue;
    
    int _frame;
    
    UIViewController<OpenCameraDelegate> * delegate;
    UIImageView * imageView;
    CvVideoCamera * videoCamera;
    cv::Mat gtpl;
}

/**
 The total number of cooked pixels

 @return number of cooked pixels
 */
- (int)total_cooked_pixels {
    return _total_cooked_pixels;
}

/**
 The total number of uncooked pixels

 @return number of uncooked pixels
 */
- (int)total_uncooked_pixels {
    return _total_uncooked_pixels;
}

/**
 Average red value (Hu)

 @return average red value
 */
- (int)avg_red {
    return _avg_red;
}

/**
 Average green value (Hu)
 
 @return average green value
 */
- (int)avg_green {
    return _avg_green;
}

/**
 Average blue value (Hu)
 
 @return average blue value
 */
- (int)avg_blue {
    return _avg_blue;
}

/**
 Converts a Mat to UIImage

 @return the UIImage
 */
- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

/**
 Edge detector using Canny edge detection

 @param img the UIImage to detect edges on
 @return the edge map
 */
- (UIImage *)edges:(UIImage *)img {
    // Convert to Mat
    cv::Mat mat;
    UIImageToMat(img, mat);
    
    // Get edges
    cv::Mat edges;
    cv::Canny(mat, edges, 100, 200);
    cv::cvtColor(edges, edges, cv::COLOR_GRAY2BGR);
    
    return [self UIImageFromCVMat:edges];
}

/**
 The current thresholding technique for determining
 cooked from raw beef

 @param img the UIImage to threshold
 @return segmented UIImage
 */
- (UIImage *)threshold:(UIImage *)img {
    // MARK:- CHANGE ALGORITHM
    // Andrew and Logan's algorithm that reduces input
    // image to one channel (red) and segments from there.
    return [self customTest:img];
    
    // Mogol's algorithm finds the simple browning
    // ratio by comparing raw meat in a certain color range
    // to done meat in another color range.
//     return [self mogolTest:img];
    
    // Du's algorithm simply uses a pre-segmented image
    // (from Mogol) and then determines the mean redness
    // from the meat to determine the doneness.
//     return [self duTest:img];
}

/**
 Reduces input image to one channel (red) and performs
 segmentation on that channel in order to seperate the
 meat from its surroundings and the cooked from uncooked
 beef.

 @param img the UIImage to threshold
 @return the segmented image
 */
- (UIImage *)customTest:(UIImage *)img {
    // Reset pixels
    _total_cooked_pixels = 0;
    _total_uncooked_pixels = 0;
    
    // Get original
    cv::Mat original;
    cv::Mat result;
    UIImageToMat(img, original);
    UIImageToMat(img, result);
    
    // Split into channels
    vector<cv::Mat> channels;
    cv::split(original, channels);
    
    // Segment based on red channel
    cv::Mat all_meat;
    cv::Mat uncooked;
    cv::Mat grayscale;
    
    // Convert image to result in grayscale
    cv::cvtColor(original, grayscale, cv::COLOR_RGB2GRAY);
    
    // Subtract blue and red channels to remove whites
    for (int y = 0; y < original.rows; y++) {
        for (int x = 0; x < original.cols; x++) {
            uchar &red = channels[0].at<uchar>(cv::Point(x,y));
            uchar green = channels[1].at<uchar>(cv::Point(x,y));
            uchar blue = channels[2].at<uchar>(cv::Point(x,y));
            
            // Subtract green and blue from red
//            int g = green * 0.5;
//            int b = blue * 0.5;
//
//            if ((g > 0) && (b > INT_MAX - g)) {
//                // Overflow
//                red = 0;
//            } else if ((g < 0) && (b < INT_MIN - g)) {
//                // Underflow, do nothing
//            } else if (green / 2 + blue / 2 > red) {
//                // g + b is more than red, resulting in underflow
//                red = 0;
//            } else {
//                red -= g + b;
//            }
            
            // Subtract blue from red
            if (red < green) {
                // Underflow
                red = 0;
            } else {
                red -= green;
            }
        }
    }
    
    // Create histogram
    float hranges[] = { 0, 256 };
    const float* ranges[] = { hranges };
    int c[] = {0};
    int bins[] = { 255 };
    cv::Mat histogram;
    cv::calcHist(&channels[0], 1, c, cv::Mat(), histogram, 1, bins, ranges, true, false);

    // Find all local mins
    NSMutableArray *local_mins = [[NSMutableArray alloc]init];
    for (int b = 1; b < histogram.rows - 1; b++) {
        float before = histogram.at<float>(cv::Point(0,b - 1));
        float current = histogram.at<float>(cv::Point(0,b));
        float after = histogram.at<float>(cv::Point(0,b + 1));
        if (current < before && current < after) {
            NSNumber *min = [NSNumber numberWithInt:b];
            [local_mins addObject:min];
        }
    }

    // Find local min closest to 50
    int min_difference = INT_MAX;
    int min_threshold = 0;
    for (int i = 0; i < [local_mins count]; i++) {
        NSNumber *current = local_mins[i];
        int difference = abs([current integerValue] - 50);
        if (difference < min_difference) {
            min_threshold = [current integerValue];
            min_difference = difference;
        }
    }
    
    // Threshold for all meat
    cv::threshold(channels[0], all_meat, min_threshold, 255, cv::THRESH_TOZERO);
    cv::threshold(all_meat, all_meat, 200, 255, cv::THRESH_TOZERO_INV);
    
    // Threshold for cooked meat
    cv::threshold(all_meat, uncooked, 80, 255, cv::THRESH_BINARY);
    
    // Convert colors
    cv::cvtColor(all_meat, all_meat, cv::COLOR_GRAY2RGB);
    cv::cvtColor(uncooked, uncooked, cv::COLOR_GRAY2RGB);
    
    // Manually merge beef colors
    // Anything not near an edge is NOT meat
    for (int y = 0; y < uncooked.rows; y++) {
        for (int x = 0; x < uncooked.cols; x++) {
            cv::Vec3b uncooked_color = uncooked.at<cv::Vec3b>(cv::Point(x,y));
            cv::Vec3b meat_color = all_meat.at<cv::Vec3b>(cv::Point(x,y));
            uchar original_color = grayscale.at<uchar>(cv::Point(x,y));
            cv::Vec4b &result_color = result.at<cv::Vec4b>(cv::Point(x,y));
            
            if (uncooked_color[0] > 0) {
                // Uncooked
                result_color[0] = 0;
                result_color[1] = 128;
                result_color[2] = 0;
                _total_uncooked_pixels++;
            } else if (meat_color[0] > 0) {
                // Cooked
                result_color[0] = 0;
                result_color[1] = 0;
                result_color[2] = 128;
                _total_cooked_pixels++;
            } else {
                // Black
                result_color[0] = original_color;
                result_color[1] = original_color;
                result_color[2] = original_color;
            }
        }
    }
    
    return [self UIImageFromCVMat:result];
}

/**
 Thresholds image based on Mogol's algorithm and then
 takes mean red value of the segmented image to determine
 the doneness.

 @param img the input image to threshold
 @return the segmented image
 */
- (UIImage *)duTest:(UIImage *)img {
    // Reset averages
    _avg_red = 0;
    _avg_green = 0;
    _avg_blue = 0;
    
    // Get original
    cv::Mat original;
    UIImageToMat(img, original);
    
    // Get segmented
    cv::Mat segmented;
    
    // Use Mogol
    UIImageToMat([self customTest:img], segmented);
    
    // Use Custom
//    UIImageToMat([self customTest:img], segmented);
    
    // Determine mean color of segmented pixels
    int number_of_pixels = 0;
    for (int y = 0; y < original.rows; y++) {
        for (int x = 0; x < original.cols; x++) {
            cv::Vec3b original_color = original.at<cv::Vec3b>(cv::Point(x,y));
            cv::Vec3b segmented_color = segmented.at<cv::Vec3b>(cv::Point(x,y));
            if ((segmented_color[0] == 0 && segmented_color[1] == 128 && segmented_color[2] == 0) ||
                (segmented_color[0] == 0 && segmented_color[1] == 0 && segmented_color[2] == 128)) {
                // This is meat according to our mogol algorithm
                _avg_red += original_color[0];
                _avg_green += original_color[1];
                _avg_blue += original_color[2];
                number_of_pixels += 1;
            }
        }
    }
    
    // Average
    _avg_red /= number_of_pixels;
    _avg_green /= number_of_pixels;
    _avg_blue /= number_of_pixels;
    
    return [self UIImageFromCVMat:segmented];
}

/**
 Mogol's algorithm tries to find the simple browning
 ratio by comparing raw meat in a certain color range
 to done meat in another color range.

 @param img the input image to threshold
 @return the segmented image
 */
- (UIImage *)mogolTest:(UIImage *)img {
    // Reset pixel count
    _total_uncooked_pixels = 0;
    _total_cooked_pixels = 0;
    
    // Convert to Mat
    cv::Mat mat;
    UIImageToMat(img, mat);
    
    // Convert to HSV
    cv::Mat hsv;
    cv::Mat grayscale;
    cv::cvtColor(mat, hsv, cv::COLOR_RGB2HSV);
    cv::cvtColor(mat, grayscale, cv::COLOR_RGB2GRAY);
    
    // Threshold the HSV image, keep only the red pixels
    cv::Mat uncooked_binary_lower;
    cv::Mat uncooked_binary_upper;
    cv::Mat uncooked_binary;
    cv::Mat uncooked;
    cv::inRange(hsv, cv::Scalar(0, 64, 64), cv::Scalar(2, 255, 255), uncooked_binary_lower);
    cv::inRange(hsv, cv::Scalar(173, 64, 64), cv::Scalar(180, 255, 255), uncooked_binary_upper);
    
    // Merge lower and upper and convert to color
    cv::addWeighted(uncooked_binary_lower, 1, uncooked_binary_upper, 1, 0, uncooked_binary);
    cv::cvtColor(uncooked_binary, uncooked, cv::COLOR_GRAY2BGR);
    
    // Modify color of uncooked beef
    for (int y=0; y < uncooked.rows; y++) {
        for (int x=0; x < uncooked.cols; x++) {
            cv::Vec3b &color = uncooked.at<cv::Vec3b>(cv::Point(x,y));
            if (color[0] == 255) {
                color[0] = 255;
                color[1] = 255;
                color[2] = 0;
            } else {
                color[0] = 0;
                color[1] = 0;
                color[2] = 0;
            }
        }
    }
    
    // Threshold the HSV image, keep only the brown pixels
    cv::Mat cooked_binary;
    cv::Mat cooked;
    cv::inRange(hsv, cv::Scalar(5, 90, 100), cv::Scalar(12, 255, 180), cooked_binary);
    
    // Convert to color
    cv::cvtColor(cooked_binary, cooked, cv::COLOR_GRAY2BGR);
    
    // Modify color of cooked beef
    for (int y=0; y < cooked.rows; y++) {
        for (int x=0; x < cooked.cols; x++) {
            cv::Vec3b &color = cooked.at<cv::Vec3b>(cv::Point(x,y));
            if (color[0] == 255) {
                color[0] = 0;
                color[1] = 0;
                color[2] = 255;
            } else {
                color[0] = 0;
                color[1] = 0;
                color[2] = 0;
            }
        }
    }
    
    cv::Mat meat;
    meat = cooked;
    
    // Manually merge beef colors
    // Anything not near an edge is NOT meat
    for (int y=0; y < meat.rows; y++) {
        for (int x=0; x < meat.cols; x++) {
            cv::Vec3b uncooked_color = uncooked.at<cv::Vec3b>(cv::Point(x,y));
            cv::Vec3b cooked_color = cooked.at<cv::Vec3b>(cv::Point(x,y));
            cv::Vec3b &color = meat.at<cv::Vec3b>(cv::Point(x,y));
            uchar original = grayscale.at<uchar>(cv::Point(x,y));
            
            if (uncooked_color[0] == 255 && cooked_color[2] == 0) {
                // Uncooked
                color[0] = 0;
                color[1] = 128;
                color[2] = 0;
                _total_uncooked_pixels++;
            } else if (uncooked_color[0] == 0 && cooked_color[2] == 255) {
                // Cooked
                color[0] = 0;
                color[1] = 0;
                color[2] = 128;
                _total_cooked_pixels++;
            } else if (uncooked_color[0] == 255 && cooked_color[2] == 255) {
                // Tie
                color[0] = 255;
                color[1] = 255;
                color[2] = 255;
                _total_uncooked_pixels++;
                _total_cooked_pixels++;
            } else {
                // Black
                color[0] = original;
                color[1] = original;
                color[2] = original;
            }
        }
    }
    
    return [self UIImageFromCVMat:meat];
}

/**
 Initializes a new connection between Swift and
 the OpenCV C++ code.

 @param c the view controller
 @param iv the image view for the camera
 @return itself
 */
- (id)initWithController:(UIViewController<OpenCameraDelegate>*)c andImageView:(UIImageView*)iv
{
    delegate = c;
    imageView = iv;
    
    _frame = 0;
    
    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack; // Use the back camera
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; // Ensure proper orientation
    videoCamera.rotateVideo = YES; // Ensure proper orientation
    videoCamera.defaultFPS = 30; // How often 'processImage' is called, adjust based on the amount/complexity of images
    videoCamera.delegate = self;
    
    // Convert UIImage to Mat
    UIImage *tplImg = [UIImage imageNamed:@"item1"];
    cv::Mat tpl;
    UIImageToMat(tplImg, tpl);
    
    return self;
}

/**
 Called every frame
 */
- (void)processImage:(cv::Mat &)img {
    [self mogol:img];
    
    // Only update percentages once per second
    _frame += 1;
    if (_frame % 30 == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->delegate updatePercentage];
        });
        _frame = 1;
    }
}

/**
 Used to start the camera
 */
- (void)start
{
    [videoCamera start];
}

/**
 Used to stop the camera
 */
- (void)stop
{
    [videoCamera stop];
}

/**
 Reduces frame to one channel (red) and performs
 segmentation on that channel in order to seperate the
 meat from its surroundings and the cooked from uncooked
 beef.
 
 @param img the frame from the camera
 */
- (void)custom:(cv::Mat &)img {
    // Reset pixels
    _total_cooked_pixels = 0;
    _total_uncooked_pixels = 0;
    
    // Get original
    cv::Mat result;
    img.copyTo(result);
    
    // Split into channels
    vector<cv::Mat> channels;
    cv::split(img, channels);
    
    // Segment based on red channel
    cv::Mat all_meat;
    cv::Mat uncooked;
    cv::Mat grayscale;
    
    // Convert image to result in grayscale
    cv::cvtColor(img, grayscale, cv::COLOR_BGR2GRAY);
    
    // Subtract blue and red channels to remove whites
    for (int y = 0; y < img.rows; y++) {
        for (int x = 0; x < img.cols; x++) {
            uchar &red = channels[0].at<uchar>(cv::Point(x,y));
            uchar green = channels[1].at<uchar>(cv::Point(x,y));
            uchar blue = channels[2].at<uchar>(cv::Point(x,y));
            
            // Subtract green and blue from red
            //            int g = green * 0.5;
            //            int b = blue * 0.5;
            //
            //            if ((g > 0) && (b > INT_MAX - g)) {
            //                // Overflow
            //                red = 0;
            //            } else if ((g < 0) && (b < INT_MIN - g)) {
            //                // Underflow, do nothing
            //            } else if (green / 2 + blue / 2 > red) {
            //                // g + b is more than red, resulting in underflow
            //                red = 0;
            //            } else {
            //                red -= g + b;
            //            }
            
            // Subtract blue from red
            if (red < green) {
                // Underflow
                red = 0;
            } else {
                red -= green;
            }
        }
    }
    
    // Create histogram
    float hranges[] = { 0, 256 };
    const float* ranges[] = { hranges };
    int c[] = {0};
    int bins[] = { 255 };
    cv::Mat histogram;
    cv::calcHist(&channels[0], 1, c, cv::Mat(), histogram, 1, bins, ranges, true, false);
    
    // Find all local mins
    NSMutableArray *local_mins = [[NSMutableArray alloc]init];
    for (int b = 1; b < histogram.rows - 1; b++) {
        float before = histogram.at<float>(cv::Point(0,b - 1));
        float current = histogram.at<float>(cv::Point(0,b));
        float after = histogram.at<float>(cv::Point(0,b + 1));
        if (current < before && current < after) {
            NSNumber *min = [NSNumber numberWithInt:b];
            [local_mins addObject:min];
        }
    }
    
    // Find local min closest to 50
    int min_difference = INT_MAX;
    int min_threshold = 0;
    for (int i = 0; i < [local_mins count]; i++) {
        NSNumber *current = local_mins[i];
        int difference = abs([current integerValue] - 50);
        if (difference < min_difference) {
            min_threshold = [current integerValue];
            min_difference = difference;
        }
    }
    
    // Threshold for all meat
    cv::threshold(channels[0], all_meat, min_threshold, 255, cv::THRESH_TOZERO);
    cv::threshold(all_meat, all_meat, 200, 255, cv::THRESH_TOZERO_INV);
    
    // Threshold for cooked meat
    cv::threshold(all_meat, uncooked, 80, 255, cv::THRESH_BINARY);
    
    // Convert colors
    cv::cvtColor(all_meat, all_meat, cv::COLOR_GRAY2RGB);
    cv::cvtColor(uncooked, uncooked, cv::COLOR_GRAY2RGB);
    
    // Manually merge beef colors
    // Anything not near an edge is NOT meat
    for (int y = 0; y < uncooked.rows; y++) {
        for (int x = 0; x < uncooked.cols; x++) {
            cv::Vec3b uncooked_color = uncooked.at<cv::Vec3b>(cv::Point(x,y));
            cv::Vec3b meat_color = all_meat.at<cv::Vec3b>(cv::Point(x,y));
            uchar original_color = grayscale.at<uchar>(cv::Point(x,y));
            cv::Vec4b &result_color = img.at<cv::Vec4b>(cv::Point(x,y));
            
            if (uncooked_color[0] > 0) {
                // Uncooked
                result_color[0] = 0;
                result_color[1] = 128;
                result_color[2] = 0;
                _total_uncooked_pixels++;
            } else if (meat_color[0] > 0) {
                // Cooked
                result_color[0] = 128;
                result_color[1] = 0;
                result_color[2] = 0;
                _total_cooked_pixels++;
            } else {
                // Black
                result_color[0] = original_color;
                result_color[1] = original_color;
                result_color[2] = original_color;
            }
        }
    }
}

/**
 Thresholds frame based on Mogol's algorithm and then
 takes mean red value of the segmented image to determine
 the doneness.
 
 @param img the frame from the camera
 */
- (void)du:(cv::Mat &)img {
    // Reset averages
    _avg_red = 0;
    _avg_green = 0;
    _avg_blue = 0;
    
    // Get original
    cv::Mat original;
    img.copyTo(original);
    
    // Get segmented
    [self mogol:img];
    
    // Determine mean color of segmented pixels
    int number_of_pixels = 0;
    for (int y = 0; y < original.rows; y++) {
        for (int x = 0; x < original.cols; x++) {
            cv::Vec3b original_color = original.at<cv::Vec3b>(cv::Point(x,y));
            cv::Vec3b segmented_color = img.at<cv::Vec3b>(cv::Point(x,y));
            if ((segmented_color[0] == 0 && segmented_color[1] == 128 && segmented_color[2] == 0) ||
                (segmented_color[0] == 0 && segmented_color[1] == 0 && segmented_color[2] == 128)) {
                // This is meat according to our mogol algorithm
                _avg_red += original_color[0];
                _avg_green += original_color[1];
                _avg_blue += original_color[2];
                number_of_pixels += 1;
            }
        }
    }
    
    // Average
    _avg_red /= number_of_pixels;
    _avg_green /= number_of_pixels;
    _avg_blue /= number_of_pixels;
}

/**
 Mogol's algorithm tries to find the simple browning
 ratio by comparing raw meat in a certain color range
 to done meat in another color range.
 
 @param img the frame from the camera
 */
- (void)mogol:(cv::Mat &)img {
    // Reset pixel count
    _total_uncooked_pixels = 0;
    _total_cooked_pixels = 0;
    
    // Convert to Mat
    cv::Mat mat;
    mat = img;
    
    // Convert to HSV
    cv::Mat hsv;
    cv::Mat grayscale;
    cv::cvtColor(mat, hsv, cv::COLOR_BGR2HSV);
    cv::cvtColor(mat, grayscale, cv::COLOR_BGR2GRAY);
    
    // Threshold the HSV image, keep only the red pixels
    cv::Mat uncooked_binary_lower;
    cv::Mat uncooked_binary_upper;
    cv::Mat uncooked_binary;
    cv::Mat uncooked;
    cv::inRange(hsv, cv::Scalar(0, 64, 64), cv::Scalar(2, 255, 255), uncooked_binary_lower);
    cv::inRange(hsv, cv::Scalar(173, 64, 64), cv::Scalar(180, 255, 255), uncooked_binary_upper);
    
    // Merge lower and upper and convert to color
    cv::addWeighted(uncooked_binary_lower, 1, uncooked_binary_upper, 1, 0, uncooked_binary);
    cv::cvtColor(uncooked_binary, uncooked, cv::COLOR_GRAY2BGR);
    
    // Modify color of uncooked beef
    for (int y=0; y < uncooked.rows; y++) {
        for (int x=0; x < uncooked.cols; x++) {
            cv::Vec3b &color = uncooked.at<cv::Vec3b>(cv::Point(x,y));
            if (color[0] == 255) {
                color[0] = 255;
                color[1] = 255;
                color[2] = 0;
            } else {
                color[0] = 0;
                color[1] = 0;
                color[2] = 0;
            }
        }
    }
    
    // Threshold the HSV image, keep only the brown pixels
    cv::Mat cooked_binary;
    cv::Mat cooked;
    cv::inRange(hsv, cv::Scalar(5, 90, 100), cv::Scalar(12, 255, 180), cooked_binary);
    
    // Convert to color
    cv::cvtColor(cooked_binary, cooked, cv::COLOR_GRAY2BGR);
    
    // Modify color of cooked beef
    for (int y=0; y < cooked.rows; y++) {
        for (int x=0; x < cooked.cols; x++) {
            cv::Vec3b &color = cooked.at<cv::Vec3b>(cv::Point(x,y));
            if (color[0] == 255) {
                color[0] = 0;
                color[1] = 0;
                color[2] = 255;
            } else {
                color[0] = 0;
                color[1] = 0;
                color[2] = 0;
            }
        }
    }
    
    cv::Mat meat;
    meat = cooked;
    
    // Manually merge beef colors
    // Anything not near an edge is NOT meat
    for (int y=0; y < meat.rows; y++) {
        for (int x=0; x < meat.cols; x++) {
            cv::Vec3b uncooked_color = uncooked.at<cv::Vec3b>(cv::Point(x,y));
            cv::Vec3b cooked_color = cooked.at<cv::Vec3b>(cv::Point(x,y));
            cv::Vec3b &color = meat.at<cv::Vec3b>(cv::Point(x,y));
            uchar original = grayscale.at<uchar>(cv::Point(x,y));
            
            if (uncooked_color[0] == 255 && cooked_color[2] == 0) {
                // Uncooked
                color[0] = 0;
                color[1] = 128;
                color[2] = 0;
                _total_uncooked_pixels++;
            } else if (uncooked_color[0] == 0 && cooked_color[2] == 255) {
                // Cooked
                color[0] = 0;
                color[1] = 0;
                color[2] = 128;
                _total_cooked_pixels++;
            } else if (uncooked_color[0] == 255 && cooked_color[2] == 255) {
                // Tie
                color[0] = 255;
                color[1] = 255;
                color[2] = 255;
                _total_uncooked_pixels++;
                _total_cooked_pixels++;
            } else {
                // Black
                color[0] = original;
                color[1] = original;
                color[2] = original;
            }
        }
    }
    
    img = meat;
}

/**
 Edge detector using Canny edge detection
 
 @param img the UIImage to detect edges on
 @return the edge map
 */
- (void)edge:(cv::Mat &)img {
    // Get edges
    cv::Mat edges;
    cv::Canny(img, edges, 100, 200);
    cv::cvtColor(edges, edges, cv::COLOR_GRAY2BGR);
    img = edges;
}
@end
