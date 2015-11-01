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
#include "UtilityFunctions.h"

struct SADimension dimension;
struct SAImageParameters imageParameters;
struct SASerHeader serHeader;

int *dataOffsetArray;



void GetImageParametersWithURL(CFURLRef emiUrl){
    
    
    NSData *emiData;
    
    emiData = [NSData dataWithContentsOfURL:(__bridge NSURL * _Nonnull)(emiUrl)];
    
    //    emiData = CFURLCreateData(kCFAllocatorDefault, emiUrl, kCFStringEncodingUTF32, false);
    //
    //
    //    NULL, emiUrl,
    //                                             &emiData, NULL, NULL, NULL);
    //    // Get length of the file in bytes,
    // setup a search cursor to send through the file,
    // then find the end of the data with the cusor for the while loop
    
    
    // Loop to find the image data, ignores more than one image for the time being
    // will implement a frame in the graphics context when I can find the time
    // getting any more information than necessary would go against the purpose of QuickLook!!
    //    const void *dataBytes = [emiData bytes];
    
    
    NSRange range;
    
    range.length=2;
    range.location = 0;
    
    [emiData getBytes:&serHeader.byteOrder range:range];
    range.location +=sizeof(short);
    
    
    [emiData getBytes:&serHeader.seriesId range:range];
    range.location +=sizeof(short);
    
    [emiData getBytes:&serHeader.seriesVersion range:range];
    range.location +=sizeof(short);
    
    [emiData getBytes:&serHeader.dataTypeId range:range];
    range.location +=sizeof(int);
    
    [emiData getBytes:&serHeader.tagTypeId range:range];
    range.location +=sizeof(int);
    
    [emiData getBytes:&serHeader.totalNumberElements  range:range];
    range.location +=sizeof(int);
    
    [emiData getBytes: &serHeader.validNumberElements  range:range];
    range.location +=sizeof(int);
    
    [emiData getBytes:&serHeader.offsetArrayOffset range:range];
    range.location +=sizeof(int);
    
    
    [emiData getBytes: &serHeader.numberDimensions range:range
     ];
    
    
    
    
    
    //    %Get arrays containing byte offsets for data and tags
    //        fseek(FID,offsetArrayOffset,-1); %seek in the file to the offset arrays
    //    %Data offset array (the byte offsets of the individual data elements)
    
    
    range.location = serHeader.offsetArrayOffset;
    
    if (serHeader.seriesVersion >=528){
        dataOffsetArray = malloc(sizeof(long long)*serHeader.totalNumberElements);
        
        range.length = 8;
    }else{
        dataOffsetArray = malloc(sizeof(int)*serHeader.totalNumberElements);
        
        range.length = 4;
    }
    
    for (int i = 0; i<serHeader.totalNumberElements; i++) {
        
        [emiData getBytes: &dataOffsetArray[i] range:range];
        
        range.location +=range.length;
        
    }
    
    //    printf("%d", dataOffsetArray[0]);
    //    range.location = serHeader.offsetArrayOffset;
    
    
    
    
    
    //    while(cursor < end)
    //    {
    //        cursor++;
    //
    //        int *testIdent = (int *) cursor;
    //
    //        if(*testIdent == 0x01200060){
    //            //imageParameters.imagePosition = cursor;
    //            //imageParameters.imagePosition = imageIndex;
    //            hasImage = TRUE;
    //            imageIndex++;
    //            break;
    //        }else
    //            hasImage = FALSE;
    //        imageIndex++;
    //
    //
    //    }
    
    
    //    if(hasImage == TRUE){
    //        cursor = cursor+4;
    //        int *stringLength = (int *) cursor;
    //
    //        cursor = cursor + 19 + *stringLength;
    //        imageParameters.xDim = *((int *) cursor);
    //        imageParameters.yDim = *(((int*) cursor) +1);
    //        imageParameters.imagePosition = imageIndex+ 23 +*stringLength+2*sizeof(int);
    //        cursor = cursor + imageParameters.xDim * imageParameters.yDim * sizeof(short);
    //        //short firstValue = *((short *) cursor + )1;
    //
    //        while(cursor < end)
    //        {
    //            cursor = cursor++;
    //
    //            int *testIdent = (int *) cursor;
    //
    //            if(*testIdent == 83886176){
    //
    //                cursor = cursor+4;
    //                int *stringLength = (int *) cursor;
    //
    //                cursor = cursor + 4 + 23 + *stringLength;
    //
    //                imageParameters.minRange = *((double *) cursor);
    //                imageParameters.maxRange = *((double *) (cursor + 12));
    //                imageParameters.error = FALSE;
    //
    //                break;
    //            }
    //
    //        }
    //    }
    
}

void CreateImageAndDrawEmiImageFromUrl(QLPreviewRequestRef *thePreview, CFURLRef emiUrl,CFDictionaryRef options){
    
    
    

    
    
    NSData *emiData;
    emiData = [NSData dataWithContentsOfURL:(__bridge NSURL * _Nonnull)(emiUrl)];
    NSRange range;
    
    if (serHeader.dataTypeId >= 16674) {
        
        range.location =dataOffsetArray[0];
        range.length = 8;
        
        double calibrationOffsetX, calibrationDeltaX; int calibrationElementX;
        double calibrationOffsetY, calibrationDeltaY; int calibrationElementY;
        
        [emiData getBytes:&calibrationOffsetX range:range ]; //calibration at element calibrationElement along x
        range.location +=8;
        
        [emiData getBytes:&calibrationDeltaX range:range ]; //calibration at element calibrationElement along x
        range.location +=8;
        
        range.length =4;
        [emiData getBytes:&calibrationElementX range:range ]; //calibration at element calibrationElement along x
        range.location +=4;
        
        range.length =8;
        [emiData getBytes:&calibrationOffsetY range:range ]; //calibration at element calibrationElement along x
        range.location +=8;
        
        [emiData getBytes:&calibrationDeltaY range:range ]; //calibration at element calibrationElement along x
        range.location +=8;
        
        range.length =4;
        [emiData getBytes:&calibrationElementY range:range ]; //calibration at element calibrationElement along x
        range.location +=4;
        
        
        short dataType;
        
        range.length =sizeof(short);
        [emiData getBytes:&dataType range:range]; //calibration at element calibrationElement along x
        range.location +=sizeof(short);
        
        
        //        Type = getType(dataType);
        
        range.length =sizeof(int);
        
        int arraySizeX, arraySizeY;
        
        [emiData getBytes:&arraySizeX range:range]; //calibration at element calibrationElement along x
        range.location +=sizeof(int);
        [emiData getBytes:&arraySizeY range:range ]; //calibration at element calibrationElement along x
        range.location +=sizeof(int);
        
        
        
        
        if (dataType == 2) {
            int imageSize =arraySizeX*arraySizeY;
            range.length = imageSize*sizeof(unsigned short);
            
            unsigned short *image = malloc(range.length);
            [emiData getBytes:image range:range];
            
            unsigned short max = 0;
            unsigned short min = 65535;
            
            unsigned short temp  = 0;
            for(int i = 0; i < arraySizeX*arraySizeY; i++){
                
                temp = image[i];
                
                if(temp >max)
                    max = temp;
                else if(temp < min)
                    min = temp;
                
                
            }
            
            unsigned short maxmin = max - min;
            
            for(int i = 0; i < arraySizeX*arraySizeY; i++){
                
                temp = (unsigned short) round(((double) (image[i]-min) / (double) maxmin) * (double) 65536);
                
                if(temp > 65000)
                    image[i] = 65000;
                else if(temp < 0)
                    image[i] = 0;
                else
                    image[i] = temp;
                
                
                
                
            }
            
            
            CFDataRef imageData = CFDataCreate(NULL, (UInt8 *) image, range.length);
            
            
            //Spread the values in the image across the appropriate image range
            //Contrast-Brightness values should be able to bias this accordingly
            //
            //                temp = ((double) (*myPointer-imageParameters.minRange) / (double) rangeDif) * (double) 65536;
            //
            //                if(temp > 65000)
            //                    *myPointer = 65000;
            //                else if(temp < 0)
            //                    *myPointer = 0;
            //                else
            //                    *myPointer = temp;
            //
            //
            //                myPointer++;
            //            }
            
            
            
            
            //Create an image provider and image from the given data
            CGDataProviderRef imageProvider = CGDataProviderCreateWithCFData(imageData);
            
            CGImageRef emiImage = CGImageCreate(arraySizeX, arraySizeY, 16, 16, sizeof(short)*arraySizeX, CGColorSpaceCreateWithName(kCGColorSpaceGenericGray), kCGBitmapByteOrder16Little, imageProvider, NULL, TRUE, kCGRenderingIntentDefault);
            
            //Draw the data
            CGSize canvasSize;
            canvasSize.height = arraySizeY;
            canvasSize.width = arraySizeX;
            CGContextRef cgContext = QLPreviewRequestCreateContext(*thePreview, canvasSize, TRUE,  options);
            
            CGAffineTransform flipVertical = CGAffineTransformMake(
                                                                   1, 0, 0, -1, 0, arraySizeY
                                                                   );
            CGContextConcatCTM(cgContext, flipVertical);
            
            // Copying context content
            CGContextDrawImage(cgContext, CGRectMake(0,0, arraySizeX, arraySizeY), emiImage);
            
            //Release all the crap from memory, may help to prevent crashes
            CGImageRelease(emiImage);
            CGDataProviderRelease(imageProvider);
            
            QLPreviewRequestFlushContext(*thePreview, cgContext);
            CFRelease(cgContext);
            
            
        }
        
    }
    

    
}

void CreateThumbnailFromUrl(QLThumbnailRequestRef *theThumbnail, CFURLRef emiUrl, CFDictionaryRef options){
    
    
    NSData *emiData;
    emiData = [NSData dataWithContentsOfURL:(__bridge NSURL * _Nonnull)(emiUrl)];
    NSRange range;
    
    if (serHeader.dataTypeId >= 16674) {
        
        range.location =dataOffsetArray[0];
        range.length = 8;
        
        double calibrationOffsetX, calibrationDeltaX; int calibrationElementX;
        double calibrationOffsetY, calibrationDeltaY; int calibrationElementY;
        
        [emiData getBytes:&calibrationOffsetX range:range ]; //calibration at element calibrationElement along x
        range.location +=8;
        
        [emiData getBytes:&calibrationDeltaX range:range ]; //calibration at element calibrationElement along x
        range.location +=8;
        
        range.length =4;
        [emiData getBytes:&calibrationElementX range:range ]; //calibration at element calibrationElement along x
        range.location +=4;
        
        range.length =8;
        [emiData getBytes:&calibrationOffsetY range:range ]; //calibration at element calibrationElement along x
        range.location +=8;
        
        [emiData getBytes:&calibrationDeltaY range:range ]; //calibration at element calibrationElement along x
        range.location +=8;
        
        range.length =4;
        [emiData getBytes:&calibrationElementY range:range ]; //calibration at element calibrationElement along x
        range.location +=4;
        
        
        short dataType;
        
        range.length =sizeof(short);
        [emiData getBytes:&dataType range:range]; //calibration at element calibrationElement along x
        range.location +=sizeof(short);
        
        
        //        Type = getType(dataType);
        
        range.length =sizeof(int);
        
        int arraySizeX, arraySizeY;
        
        [emiData getBytes:&arraySizeX range:range]; //calibration at element calibrationElement along x
        range.location +=sizeof(int);
        [emiData getBytes:&arraySizeY range:range ]; //calibration at element calibrationElement along x
        range.location +=sizeof(int);
        
        
        
        
        if (dataType == 2) {
            int imageSize =arraySizeX*arraySizeY;
            range.length = imageSize*sizeof(unsigned short);
            
            unsigned short *image = malloc(range.length);
            [emiData getBytes:image range:range];
            
            unsigned short max = 0;
            unsigned short min = 65535;
            
            unsigned short temp  = 0;
            for(int i = 0; i < arraySizeX*arraySizeY; i++){
                
                temp = image[i];
                
                if(temp >max)
                    max = temp;
                else if(temp < min)
                    min = temp;
                
                
            }
            
            unsigned short maxmin = max - min;
            
            for(int i = 0; i < arraySizeX*arraySizeY; i++){
                
                temp = (unsigned short) round(((double) (image[i]-min) / (double) maxmin) * (double) 65536);
                
                if(temp > 65000)
                    image[i] = 65000;
                else if(temp < 0)
                    image[i] = 0;
                else
                    image[i] = temp;
                
                
                
                
            }
            
            
            CFDataRef imageData = CFDataCreate(NULL, (UInt8 *) image, range.length);
            
            
            //Spread the values in the image across the appropriate image range
            //Contrast-Brightness values should be able to bias this accordingly
            //
            //                temp = ((double) (*myPointer-imageParameters.minRange) / (double) rangeDif) * (double) 65536;
            //
            //                if(temp > 65000)
            //                    *myPointer = 65000;
            //                else if(temp < 0)
            //                    *myPointer = 0;
            //                else
            //                    *myPointer = temp;
            //
            //
            //                myPointer++;
            //            }
            
            
            
            
            //Create an image provider and image from the given data
            CGDataProviderRef imageProvider = CGDataProviderCreateWithCFData(imageData);
            
            CGImageRef emiImage = CGImageCreate(arraySizeX, arraySizeY, 16, 16, sizeof(short)*arraySizeX, CGColorSpaceCreateWithName(kCGColorSpaceGenericGray), kCGBitmapByteOrder16Little, imageProvider, NULL, TRUE, kCGRenderingIntentDefault);
            
            //Draw the data
            CGSize canvasSize;
            canvasSize.height = arraySizeY;
            canvasSize.width = arraySizeX;
            CGContextRef cgContext = QLThumbnailRequestCreateContext(*theThumbnail, canvasSize, TRUE,  options);
            
            CGAffineTransform flipVertical = CGAffineTransformMake(
                                                                   1, 0, 0, -1, 0, arraySizeY
                                                                   );
            CGContextConcatCTM(cgContext, flipVertical);
            
            // Copying context content
            CGContextDrawImage(cgContext, CGRectMake(0,0, arraySizeX, arraySizeY), emiImage);
            
            //Release all the crap from memory, may help to prevent crashes
            CGImageRelease(emiImage);
            CGDataProviderRelease(imageProvider);
            
            QLThumbnailRequestFlushContext(*theThumbnail, cgContext);
            CFRelease(cgContext);
            
            
        }
        
    }
    
    
}




