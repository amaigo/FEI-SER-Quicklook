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
struct SAImageParameters imageParameters;

void readImageData(int * startPtr);
void GetImageParametersWithURL(CFURLRef url);
void CreateImageAndDrawEmiImageFromUrl(CGContextRef theContext, CFURLRef emiUrl);

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    
//    GetImageParametersWithURL(url);
    CGSize canvasSize;
    canvasSize.width = 512;
    canvasSize.height = 512;
    
    CGContextRef cgContext = QLPreviewRequestCreateContext(preview, canvasSize, TRUE,  options);
    
    if(cgContext){
        
        CreateImageAndDrawEmiImageFromUrl(cgContext, url);
        
        QLPreviewRequestFlushContext(preview, cgContext);
        CFRelease(cgContext);
    }
//    
//    if(imageParameters.error == FALSE)
//    {
//        
//        CGSize canvasSize;
//        canvasSize.width = imageParameters.xDim;
//        canvasSize.height = imageParameters.yDim;
//        
//        
//        CGContextRef cgContext = QLPreviewRequestCreateContext(preview, canvasSize, TRUE,  options);
//        
//        if(cgContext){
//            
//            CreateImageAndDrawEmiImageFromUrl(cgContext, url);
//            
//            QLPreviewRequestFlushContext(preview, cgContext);
//            CFRelease(cgContext);
//        }
//        
//    }
    
    return noErr;
}


void GetImageParametersWithURL(CFURLRef emiUrl){
    
    
    CFDataRef emiData;
    int imageIndex = 0;
    bool hasImage;
    
    emiData = (__bridge CFDataRef)([NSData dataWithContentsOfURL:(__bridge NSURL * _Nonnull)(emiUrl)]);
    
    
   
    emiData = CFURLCreateData(kCFAllocatorDefault, emiUrl, kCFStringEncodingUTF32, false);
//    
//    
//    NULL, emiUrl,
//                                             &emiData, NULL, NULL, NULL);
//    // Get length of the file in bytes,
    // setup a search cursor to send through the file,
    // then find the end of the data with the cusor for the while loop
    
    int lengthOfFile = (int) CFDataGetLength(emiData);
    char *cursor = (char *) CFDataGetBytePtr(emiData);
    char *end = cursor + lengthOfFile;
    
    // Loop to find the image data, ignores more than one image for the time being
    // will implement a frame in the graphics context when I can find the time
    // getting any more information than necessary would go against the purpose of QuickLook!!
    
    while(cursor < end)
    {
        cursor++;
        
        int *testIdent = (int *) cursor;
        
        if(*testIdent == 0x01200060){
            //imageParameters.imagePosition = cursor;
            //imageParameters.imagePosition = imageIndex;
            hasImage = TRUE;
            imageIndex++;
            break;
        }else
            hasImage = FALSE;
        imageIndex++;
        
        
    }
    
    
    if(hasImage == TRUE){
        cursor = cursor+4;
        int *stringLength = (int *) cursor;
        
        cursor = cursor + 19 + *stringLength;
        imageParameters.xDim = *((int *) cursor);
        imageParameters.yDim = *(((int*) cursor) +1);
        imageParameters.imagePosition = imageIndex+ 23 +*stringLength+2*sizeof(int);
        cursor = cursor + imageParameters.xDim * imageParameters.yDim * sizeof(short);
        //short firstValue = *((short *) cursor + )1;
        
        while(cursor < end)
        {
            cursor = cursor++;
            
            int *testIdent = (int *) cursor;
            
            if(*testIdent == 83886176){
                
                cursor = cursor+4;
                int *stringLength = (int *) cursor;
                
                cursor = cursor + 4 + 23 + *stringLength;
                
                imageParameters.minRange = *((double *) cursor);
                imageParameters.maxRange = *((double *) (cursor + 12));
                imageParameters.error = FALSE;
                
                break;
            }
            
        }
    }
    
}

void CreateImageAndDrawEmiImageFromUrl(CGContextRef theContext, CFURLRef emiUrl){
    
    
    CFDataRef emiData;
    short xDim = imageParameters.xDim;
    short yDim = imageParameters.yDim;
    int bufferSize = xDim * yDim * sizeof(short);
    short *funBuffer = (short *) malloc(bufferSize);
    int i;
    float temp;
    
    //Take the file data and convert it into a CFData
    
    emiData = CFURLCreateData(kCFAllocatorDefault, emiUrl, kCFStringEncodingUTF32, false);

    
    //Need to extract out only the image
    
    CFDataGetBytes(emiData, CFRangeMake(imageParameters.imagePosition, bufferSize),(UInt8 *) funBuffer);
    
    unsigned short *myPointer = (unsigned short *) funBuffer;
    double rangeDif = imageParameters.maxRange-imageParameters.minRange;
    
    for(i = 0; i < xDim*yDim; i++){
        
        //Spread the values in the image across the appropriate image range
        //Contrast-Brightness values should be able to bias this accordingly
        
        temp = ((double) (*myPointer-imageParameters.minRange) / (double) rangeDif) * (double) 65536;
        
        if(temp > 65000)
            *myPointer = 65000;
        else if(temp < 0)
            *myPointer = 0;
        else
            *myPointer = temp;
        
        
        myPointer++;
    }
    
    CFDataRef imageData = CFDataCreate(NULL, (UInt8 *) funBuffer, bufferSize);
    
    free(funBuffer); 
    
    
    //Create an image provider and image from the given data
    CGDataProviderRef imageProvider = CGDataProviderCreateWithCFData(imageData);
    
    CGImageRef emiImage = CGImageCreate(xDim, yDim, 16, 16, 2*xDim, CGColorSpaceCreateWithName(kCGColorSpaceGenericGray), kCGBitmapByteOrder16Little, imageProvider, NULL, TRUE, kCGRenderingIntentDefault);
    
    //Draw the data
    
    CGContextDrawImage(theContext, CGRectMake(0,0, xDim, yDim), emiImage);
    
    //Release all the crap from memory, may help to prevent crashes 'o plenty 
    CGImageRelease(emiImage);
    CGDataProviderRelease(imageProvider);
    
}


void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
