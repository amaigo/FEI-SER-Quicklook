//
//  UtilityFunctions.c
//  FEI Ser Quicklook
//
//  Created by James LeBeau on 10/30/15.
//  Copyright © 2015 Subangstrom. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#import <Cocoa/Cocoa.h>
#include <QuickLook/QuickLook.h>



struct SAImageParameters {
    short xDim;
    short yDim;
    int imagePosition;
    double minRange;
    double maxRange;
    bool error;
};


struct SADimension{
    int dimensionSize;
    Float64 calibrationOffset;
    Float64 calibrationDelta;
    int calibrationElement;
    int descriptionLength;
    char *description;
    int unitsLength;
    char *units;
};

struct SASerHeader {
    short byteOrder;
    short seriesId;
    short seriesVersion;
    int dataTypeId;
    int tagTypeId;
    int totalNumberElements;
    int validNumberElements;
    int offsetArrayOffset;
    int numberDimensions;
};

CGImageRef GetFirstImageFromURL(CFURLRef emiUrl);

void GetImageParametersWithURL(CFURLRef emiUrl);
void CreateImageAndDrawEmiImageFromUrl(QLPreviewRequestRef *thePreview, CFURLRef emiUrl, CFDictionaryRef options);
void CreateThumbnailFromUrl(QLThumbnailRequestRef *theThumbnail, CFURLRef emiUrl, CFDictionaryRef options);

