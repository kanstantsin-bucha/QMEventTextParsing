#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LocationInfo.h"
#import "QMLocationInfoAppleConvertion.h"
#import "QMLocation.h"
#import "QMLocationInfo.h"
#import "LocationInfo.h"
#import "QMLocationInfoLuongConvertion.h"

FOUNDATION_EXPORT double LocationInfoVersionNumber;
FOUNDATION_EXPORT const unsigned char LocationInfoVersionString[];

