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


    NSFileHandle *dataHandle = [NSFileHandle fileHandleForReadingFromURL:(__bridge NSURL * _Nonnull)(emiUrl) error:nil];
    NSData *emiData = [dataHandle readDataOfLength:10000];

//    emiData = [NSData dataWithContentsOfURL:(__bridge NSURL * _Nonnull)(emiUrl)];

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
    dataOffsetArray = malloc(sizeof(int)*serHeader.totalNumberElements);

    if (serHeader.seriesVersion >528){

        range.length = 8;
    }else{

        range.length = 4;
    }

    for (int i = 0; i<serHeader.totalNumberElements; i++) {

        [emiData getBytes: &dataOffsetArray[i] range:range];

        range.location +=range.length;
        
    }
    



}

//void CreateImageAndDrawEmiImageFromUrl(QLPreviewRequestRef *thePreview, CFURLRef emiUrl,CFDictionaryRef options){
//
//
//
//
//    CGImageRef image = GetFirstImageFromURL(emiUrl);
//
//    
//    //Draw the data
//    CGSize canvasSize;
//    canvasSize.height = CGImageGetHeight(image);
//    canvasSize.width = CGImageGetWidth(image);
//    CGContextRef cgContext = QLPreviewRequestCreateContext(*thePreview, canvasSize, TRUE,  options);
//
//    CGAffineTransform flipVertical = CGAffineTransformMake(
//                                                           1, 0, 0, -1, 0, canvasSize.height
//                                                           );
//    CGContextConcatCTM(cgContext, flipVertical);
//
//    // Copying context content
//    CGContextDrawImage(cgContext, CGRectMake(0,0, canvasSize.width, canvasSize.height), image);
//
//    if(serHeader.totalNumberElements>1){
//    // setup the size
//
//        CGRect circleRect;
//        float scale = 1.0;
//        CGContextSetLineWidth(cgContext, 5.0 * scale);
//
//        CGContextSetFillColorWithColor(cgContext, CGColorCreateGenericGray(1.0, 1.0));
//        float circleSize = canvasSize.width*0.03;
//        float vertPosition = canvasSize.height*0.9;
//
//        float position;
//        for (int j = -1 ; j<=1; j++) {
//            position = canvasSize.width*(0.5+j*.1);
//           circleRect  = CGRectMake(position, vertPosition, circleSize, circleSize);
//
//            CGContextFillEllipseInRect(cgContext, circleRect);
//            CGContextStrokeEllipseInRect(cgContext, circleRect);
//
//        }
//
//
//    }
//
//    //Release all the crap from memory, may help to prevent crashes
//    CGImageRelease(image);
//
//    QLPreviewRequestFlushContext(*thePreview, cgContext);
//    CFRelease(cgContext);
//
//
//}


void CreateImageAndDrawEmiImageFromUrl(QLPreviewRequestRef *thePreview, CFURLRef emiUrl,CFDictionaryRef options){
    
    
    CGImageRef image = GetImageFromURLAtIndex(emiUrl, 0);
    
    CGSize canvasSize;
    
    canvasSize.height = CGImageGetHeight(image);
    canvasSize.width = CGImageGetWidth(image);
    
//    if(canvasSize.height > 512 || canvasSize.width> 512){
//        scalingFactor = 2;
//     
//        canvasSize.height = CGImageGetHeight(image)/scalingFactor;
//        canvasSize.width = CGImageGetWidth(image)/scalingFactor;
//    }
    


    
    if(serHeader.totalNumberElements>1){
        // setup the size serHeader.totalNumberElements <= 20

        CGRect rect =CGRectMake(0, 0,  canvasSize.height,  canvasSize.width);
        
        CGContextRef pdf =  QLPreviewRequestCreatePDFContext(*thePreview, &rect , NULL, NULL);
        
        GetPDFSeriesPageFromURL(&pdf, emiUrl, options);
        QLPreviewRequestFlushContext(*thePreview, pdf);
        
        
        CGContextRelease(pdf);
        
        
    
            
    }else{
        
        
        //Draw the data
        


        CGContextRef cgContext = QLPreviewRequestCreateContext(*thePreview, canvasSize, TRUE,  options);
        
        CGAffineTransform flipVertical = CGAffineTransformMake(
                                                               1, 0, 0, -1, 0, canvasSize.height
                                                               );
        CGContextConcatCTM(cgContext, flipVertical);
        
        // Copying context content
        CGContextDrawImage(cgContext, CGRectMake(0,0, canvasSize.width, canvasSize.height), image);
        
        if(serHeader.totalNumberElements>1){
            
            
            
            CGRect circleRect;
            float scale = 1.0;
            CGContextSetLineWidth(cgContext, 5.0 * scale);
            
            CGContextSetFillColorWithColor(cgContext, CGColorCreateGenericGray(1.0, 1.0));
            float circleSize = canvasSize.width*0.03;
            float vertPosition = canvasSize.height*0.9;
            
            float position;
            for (int j = -1 ; j<=1; j++) {
                position = canvasSize.width*(0.5+j*.1);
                circleRect  = CGRectMake(position, vertPosition, circleSize, circleSize);
                
                CGContextFillEllipseInRect(cgContext, circleRect);
                CGContextStrokeEllipseInRect(cgContext, circleRect);
                
            }
        }

        
        
        QLPreviewRequestFlushContext(*thePreview, cgContext);
        CFRelease(cgContext);

    }
    
    //Release all the crap from memory, may help to prevent crashes
    

    
    CGImageRelease(image);

}


void CreateThumbnailFromUrl(QLThumbnailRequestRef *theThumbnail, CFURLRef emiUrl, CFDictionaryRef options){


    
    
    CGImageRef image = GetImageFromURLAtIndex(emiUrl, 0);
    
    
    //Draw the data
    CGSize canvasSize;
    canvasSize.height = CGImageGetHeight(image);
    canvasSize.width = CGImageGetWidth(image);

              CGContextRef cgContext = QLThumbnailRequestCreateContext(*theThumbnail, canvasSize, TRUE,  options);

    
    CGAffineTransform flipVertical = CGAffineTransformMake(
                                                           1, 0, 0, -1, 0, canvasSize.height
                                                           );
    CGContextConcatCTM(cgContext, flipVertical);
    
    // Copying context content
    CGContextDrawImage(cgContext, CGRectMake(0,0, canvasSize.width, canvasSize.height), image);
    
    if(serHeader.totalNumberElements > 1){
        // setup the size
        
        CGRect circleRect;
        float scale = 1.0;
        CGContextSetLineWidth(cgContext, 5.0 * scale);
        
        CGContextSetFillColorWithColor(cgContext, CGColorCreateGenericGray(1.0, 1.0));
        float circleSize = canvasSize.width*0.03;
        float vertPosition = canvasSize.height*0.5;
        
        float position;
        for (int j = -1 ; j<=1; j++) {
            position = canvasSize.width*(0.5+j*.1);
            circleRect  = CGRectMake(position, vertPosition, circleSize, circleSize);
            
            CGContextFillEllipseInRect(cgContext, circleRect);
            CGContextStrokeEllipseInRect(cgContext, circleRect);
            
        }
        
        
    }
    

    //Release all the crap from memory, may help to prevent crashes

    CGImageRelease(image);

    QLThumbnailRequestFlushContext(*theThumbnail, cgContext);
    CFRelease(cgContext);


}

void GetPDFSeriesPageFromURL(CGContextRef *pdfDocument, CFURLRef seriesURL, CFDictionaryRef options){
    
    CFMutableDictionaryRef pageDictionary = NULL;
    CFDataRef boxData = NULL;
   
    pageDictionary = CFDictionaryCreateMutable(NULL, 0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks); // 6

    CGRect box;
    CGPoint origin;
    origin.x = 0;
    origin.y = 0;
    CGSize canvasSize;
    
    box.origin = origin;
    
    int imageCount = serHeader.totalNumberElements;
    int cutoff = 20;
    if (serHeader.totalNumberElements > cutoff) {
        imageCount = cutoff;
    }
    
    for (int i=0; i < imageCount; i++) {
        
        CGImageRef image = NULL;

        image = GetImageFromURLAtIndex(seriesURL, i);
     
        canvasSize.height = CGImageGetHeight(image);
        canvasSize.width = CGImageGetWidth(image);
        box.size = canvasSize;
        
        boxData = CFDataCreate(NULL,(const UInt8 *)&box, sizeof (CGRect));
        
        CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
        

        CGPDFContextBeginPage(*pdfDocument, pageDictionary);
        
        CGContextDrawImage(*pdfDocument, CGRectMake(0,0, canvasSize.width, canvasSize.height), image);
        
        if (i == cutoff-1 && serHeader.totalNumberElements >cutoff) {
            
            
            CGRect circleRect;
            float scale = 1.0;

            CGContextSetLineWidth(*pdfDocument, 5.0 * scale);
            CGContextSetFillColorWithColor(*pdfDocument, CGColorCreateGenericGray(1.0, 1.0));
            
            float circleSize = canvasSize.width*0.03;
            float vertPosition = canvasSize.height*0.5;
            
            float position;
            for (int j = -1 ; j<=1; j++) {
                position = canvasSize.width*(0.5+j*.1);
                circleRect  = CGRectMake(position, vertPosition, circleSize, circleSize);
                
                CGContextFillEllipseInRect(*pdfDocument, circleRect);
                CGContextStrokeEllipseInRect(*pdfDocument, circleRect);
                
            }


            CGImageRelease(image);
            CFRelease(boxData);
        

    }
    
    
        
        CGPDFContextEndPage(*pdfDocument);
        
    }
    
    CFRelease(pageDictionary);


    
}


CGImageRef GetImageFromURLAtIndex(CFURLRef emiUrl, int index){
    
    NSFileHandle *dataHandle = [NSFileHandle fileHandleForReadingFromURL:(__bridge NSURL * _Nonnull)(emiUrl) error:nil];
    long long offset;
    
    offset = dataOffsetArray[index];
    
    [dataHandle seekToFileOffset: offset];
    
    NSData *emiData = [dataHandle readDataOfLength:400];
    
    
    CGImageRef serImage;
    
    
    //    NSData *emiData;
    //    emiData = [NSData dataWithContentsOfURL:(__bridge NSURL * _Nonnull)(emiUrl)];
    NSRange range;
    
    if (serHeader.dataTypeId >= 16674) {
        
        range.location =0;
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
            
            [dataHandle seekToFileOffset: offset+range.location];
            
            range.location=0;
            
            int imageSize =arraySizeX*arraySizeY;
            range.length = imageSize*sizeof(unsigned short);
            
            emiData = [dataHandle readDataOfLength:range.length];
            
            
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
            
        
            
            //Create an image provider and image from the given data
            CGDataProviderRef imageProvider = CGDataProviderCreateWithCFData(imageData);
            
            serImage = CGImageCreate(arraySizeX, arraySizeY, 16, 16, sizeof(short)*arraySizeX, CGColorSpaceCreateWithName(kCGColorSpaceGenericGray), kCGBitmapByteOrder16Little, imageProvider, NULL, false, kCGRenderingIntentDefault);

            CGDataProviderRelease(imageProvider);
            CFRelease(imageData);
            
            free(image);


            
            
        }
    }
    
    

    return serImage;
}

