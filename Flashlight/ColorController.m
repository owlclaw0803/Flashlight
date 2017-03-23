//
//  ColorController.m
//  Flashlight
//
//  Created by kangZhe on 2/4/15.
//  Copyright (c) 2015 com.tinykeyboard.customkeyboard. All rights reserved.
//

#import "ColorController.h"

@interface ColorController ()

@end

@implementation ColorController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeBackgroundColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onclickClose:(id)sender {
    [UIView animateWithDuration:0.4 animations:^{
        self.m_btnclose.alpha = 0.3;
        self.m_imgAdjust.alpha = 0.3;
        self.m_imgDot.alpha = 0.3;
    } completion:^(BOOL finished) {
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (BOOL) isinRound:(CGPoint) pt
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGRect rt = self.m_imgAdjust.frame;
    float ox = rt.origin.x+rt.size.width/2;
    float oy = rt.origin.y+rt.size.height;
    float radius = 121.0f;
    if(pt.y > oy)
        return NO;
    if((pt.x-ox)*(pt.x-ox)+(pt.y-oy)*(pt.y-oy) < radius*radius)
        return YES;
    return NO;
}

- (void) changeDotPosition:(CGPoint) pt
{
    CGRect rt = self.m_imgDot.frame;
    rt.origin.x = pt.x-rt.size.width/2;
    rt.origin.y = pt.y-rt.size.height/2;
    self.m_imgDot.frame = rt;
}

-(void)changeBackgroundColor
{
    CGRect rt = self.m_imgDot.frame;
    CGPoint pt;
    pt.x = rt.origin.x+rt.size.width/2;
    pt.y = rt.origin.y+rt.size.height/2;
    
    CGRect rt1 = self.m_imgAdjust.frame;
    pt.x -= rt1.origin.x;
    pt.y -= rt1.origin.y;
    UIColor *color = [self getPixelColorAtLocation:pt];
    [self.view setBackgroundColor:color];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self.view];
    if([self isinRound:touchLocation])
    {
        [self changeDotPosition:touchLocation];
        [self changeBackgroundColor];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInView:self.view];
    if([self isinRound:touchLocation])
    {
        [self changeDotPosition:touchLocation];
        [self changeBackgroundColor];
    }
}

- (UIColor*) getPixelColorAtLocation:(CGPoint)point
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    UIColor* color = nil;
    
    CGImageRef inImage;
    
    inImage = self.m_imgAdjust.image.CGImage;
    
    
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil; /* error */ }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    
    float scale = w/size.width;
    point.x *= scale;
    point.y *= scale;
    
    CGRect rect = {{0,0},{w,h}};
    
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    // When finished, release the context
    //CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@end
