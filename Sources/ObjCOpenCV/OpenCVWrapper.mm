#import "OpenCVWrapper.h"

#ifdef __cplusplus
#undef NO
#undef YES
#import <opencv2/opencv.hpp>
#endif

#include <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>

#import <UIKit/UIKit.h>

@implementation OpenCVWrapper

using namespace cv;
using namespace std;

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *)processImage:(UIImage *)image {
    @try {
        return [OpenCVWrapper _processImageInternal:image];
    } @catch (...) {
        return nil;
    }
}

+ (UIImage *)_processImageInternal:(UIImage *)image{
    if (!image) {
        return nil;
    }
    
    UIImage *result = image;
    
    Mat src;
    UIImageToMat(image, src);
    
    int originalImageWidth = src.size().width;
    int originalImageHeight = src.size().height;
    
    // Method 1
    cv::Rect bounding_rect = [self imageProcessingMethod1:src];
    
    
    if (bounding_rect.width != 0 && bounding_rect.height != 0.0) {
        // Add margins to image
        
        // Left margin
        if (bounding_rect.x > 0) {
            int new_x = bounding_rect.x;
            for (int increment = 10; increment >= 0; increment--) {
                new_x = bounding_rect.x - increment;
                if (new_x >= 0) {
                    break;
                }
            }
            bounding_rect = cv::Rect(new_x, bounding_rect.y, bounding_rect.width + (bounding_rect.x - new_x), bounding_rect.height);
        }
        
        // Top margin
        if (bounding_rect.y > 0) {
            int new_y = bounding_rect.y;
            for (int increment = 10; increment >= 0; increment--) {
                new_y = bounding_rect.y - increment;
                if (new_y >= 0) {
                    break;
                }
            }
            bounding_rect = cv::Rect(bounding_rect.x, new_y, bounding_rect.width, bounding_rect.height + (bounding_rect.y - new_y));
        }
        
        // Right margin
        if (bounding_rect.x + bounding_rect.width < originalImageWidth) {
            int new_width = bounding_rect.width;
            for (int increment = 10; increment >= 0; increment--) {
                new_width = bounding_rect.width + increment;
                if (bounding_rect.x + new_width <= originalImageWidth) {
                    break;
                }
            }
            bounding_rect = cv::Rect(bounding_rect.x, bounding_rect.y, new_width, bounding_rect.height);
        }
        
        // Bottom margin
        if (bounding_rect.y + bounding_rect.height < originalImageHeight) {
            int new_height = bounding_rect.height;
            for (int increment = 10; increment >= 0; increment--) {
                new_height = bounding_rect.height + increment;
                if (bounding_rect.y + new_height <= originalImageHeight) {
                    break;
                }
            }
            bounding_rect = cv::Rect(bounding_rect.x, bounding_rect.y, bounding_rect.width, new_height);
        }
        
        // Crop original image to bounding_rect
        src = Mat(src, bounding_rect).clone();
        
    }else{
        return image;
    }
    
    result = MatToUIImage(src);
    
    return result;
}

+ (cv::Rect)imageProcessingMethod1:(Mat)src{
    int LOW_THRESHOLD  = 0;
    int HIGH_THRESHOLD = 100;
    
    Mat hsvSpace, edges, threshold, temp_mat;
    medianBlur(src, threshold, 9);
    cvtColor(threshold, threshold, COLOR_BGR2GRAY);
    
    GaussianBlur(threshold, threshold, cv::Size(3,3), 0, 0);
    
    Canny(threshold, edges, LOW_THRESHOLD, HIGH_THRESHOLD);
    
    if (!(countNonZero(edges) > 0)) {
        return cv::Rect(0, 0, 0, 0);
    }
    
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(edges, contours, RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    if (contours.size() == 0) {
        return cv::Rect(0, 0, 0, 0);
    }
    
    cv::Rect bounding_rect = cv::Rect(0, 0, 0, 0);
    int min_x = INT_MAX;
    int min_y = INT_MAX;
    int max_x = 0;
    int max_y = 0;
    
    for( int i = 0; i < contours.size(); i++ )
    {
        cv::Rect rect = boundingRect(contours[i]);
        
        if (rect.width == 1 || rect.height == 1) {
            continue;
        }
        
        min_x = MIN(rect.x, min_x);
        min_y = MIN(rect.y, min_y);
        max_x = MAX(rect.x + rect.width, max_x);
        max_y = MAX(rect.y + rect.height, max_y);
    }
    
    bounding_rect = cv::Rect(min_x, min_y, max_x - min_x, max_y - min_y);
    
    return bounding_rect;
}

+ (cv::Rect)imageProcessingMethod2:(Mat)src{
    int LOW_THRESHOLD  = 0;
    int HIGH_THRESHOLD = 100;
    
    int originalImageWidth = src.size().width;
    int originalImageHeight = src.size().height;
    
    Mat hsvSpace, edges, threshold, temp_mat;
    cvtColor(src, threshold, COLOR_BGR2HSV);   // RGB to HSV color space transformation
    
    erode (threshold, threshold, getStructuringElement( MORPH_RECT, cv::Size(3,3)));
    dilate(threshold, threshold, getStructuringElement( MORPH_RECT, cv::Size(3,3)));
    
    dilate(threshold, threshold, getStructuringElement( MORPH_RECT, cv::Size(3,3)));
    erode (threshold, threshold, getStructuringElement( MORPH_RECT, cv::Size(3,3)));
    
    GaussianBlur(threshold, threshold, cv::Size(3,3), 0, 0);
    
    Canny(threshold, edges, LOW_THRESHOLD, HIGH_THRESHOLD);
    
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(edges, contours, RETR_TREE, CHAIN_APPROX_SIMPLE);
    cv::Rect bounding_rect = cv::Rect(0, 0, 0, 0);
    int min_x = originalImageWidth / 2;
    int min_y = originalImageHeight / 2;
    int max_x = originalImageWidth / 2;
    int max_y = originalImageHeight / 2;
    
    for( int i = 0; i < contours.size(); i++ )
    {
        cv::Rect rect = boundingRect(contours[i]);
        double area = contourArea(contours[i]);
        if (area > 10) {
            // Ignore small rects
            min_x = MIN(rect.x, min_x);
            min_y = MIN(rect.y, min_y);
            max_x = MAX(rect.x + rect.width, max_x);
            max_y = MAX(rect.y + rect.height, max_y);
        }
    }
    
    bounding_rect = cv::Rect(min_x, min_y, max_x - min_x, max_y - min_y);
    
    return bounding_rect;
}

+ (cv::Rect)imageProcessingMethod3:(Mat)src{
    
    const int channels[] = {0, 1, 2};
    const int histSize[] = {32, 32, 32};
    const float rgbRange[] = {0, 256};
    const float* ranges[] = {rgbRange, rgbRange, rgbRange};
    
    int originalImageWidth = src.size().width;
    int originalImageHeight = src.size().height;
    
    Mat hist;
    Mat im32fc3, backpr32f, backpr8u, backprBw, kernel;
    
    src.convertTo(im32fc3, CV_32FC3);
    calcHist(&im32fc3, 1, channels, Mat(), hist, 3, histSize, ranges, true, false);
    calcBackProject(&im32fc3, 1, channels, hist, backpr32f, ranges);
    
    double minval, maxval;
    minMaxIdx(backpr32f, &minval, &maxval);
    threshold(backpr32f, backpr32f, maxval/32, 255, THRESH_TOZERO);
    backpr32f.convertTo(backpr8u, CV_8U, 255.0/maxval);
    threshold(backpr8u, backprBw, 10, 255, THRESH_BINARY);
    
    kernel = getStructuringElement(MORPH_ELLIPSE, cv::Size(3, 3));
    
    dilate(backprBw, backprBw, kernel);
    morphologyEx(backprBw, backprBw, MORPH_CLOSE, kernel, cv::Point(-1, -1), 2);
    
    backprBw = 255 - backprBw;
    
    morphologyEx(backprBw, backprBw, MORPH_OPEN, kernel, cv::Point(-1, -1), 2);
    erode(backprBw, backprBw, kernel);
    
    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(backprBw, contours, RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    cv::Rect bounding_rect = cv::Rect(0, 0, 0, 0);
    int min_x = originalImageWidth / 2;
    int min_y = originalImageHeight / 2;
    int max_x = originalImageWidth / 2;
    int max_y = originalImageHeight / 2;
    
    for( int i = 0; i < contours.size(); i++ )
    {
        cv::Rect rect = boundingRect(contours[i]);
        
        double area = contourArea(contours[i]);
        if (area > 10) {
            // Ignore small rects
            min_x = MIN(rect.x, min_x);
            min_y = MIN(rect.y, min_y);
            max_x = MAX(rect.x + rect.width, max_x);
            max_y = MAX(rect.y + rect.height, max_y);
        }
    }
    
    bounding_rect = cv::Rect(min_x, min_y, max_x - min_x, max_y - min_y);
    
    return bounding_rect;
}

@end
