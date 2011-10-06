/*
     File: SpecialProtocol.m 
 Abstract: Our custom NSURLProtocol. 
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "SpecialProtocol.h"



@implementation SpecialProtocol

-(UIImage *)imageFromString:(NSString *)string
{
        /* set the font for rendering the string */
    UIFont *font = [UIFont fontWithName:@"Zapfino" size:20.0];
    
        /* calculate the size of the rendered string */
    CGSize size  = [string sizeWithFont:font];
    
        /* hack: Zapfino requires more width for certain ligatures */
    size.width += 30;
    
        /* check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+) */
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    } else {
        /* iOS is < 4.0 */
        UIGraphicsBeginImageContext(size);
    }
    
        /* add text shadow - to avoid clipping the shadow the context size should be bigger */ 
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    
        /* draw the string in context */
    [string drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
    
        /* transfer image */
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    
    return image;
}


	/* our own class method.  Here we return the NSString used to mark
	urls handled by our special protocol. */
+ (NSString*) specialProtocolScheme {
	return @"widget";
}


	/* our own class method.  We call this routine to handle registration
	of our special protocol.  You should call this routine BEFORE any urls
	specifying your special protocol scheme are presented to webkit. */
+ (void) registerSpecialProtocol {
	static BOOL inited = NO;
	if ( ! inited ) {
		[NSURLProtocol registerClass:[SpecialProtocol class]];
		inited = YES;
	}
}

 
	/* class method for protocol called by webview to determine if this
	protocol should be used to load the request. */
+ (BOOL)canInitWithRequest:(NSURLRequest *)theRequest {

	NSLog(@"%@ received %@ with url='%@' and scheme='%@'", 
			self, NSStringFromSelector(_cmd),
			[[theRequest URL] absoluteString], [[theRequest URL] scheme]);
	
		/* get the scheme from the URL */
	NSString *theScheme = [[theRequest URL] scheme];
	
		/* return true if it matches the scheme we're using for our protocol. */
	return ([theScheme caseInsensitiveCompare: [SpecialProtocol specialProtocolScheme]] == NSOrderedSame );
}


	/* if canInitWithRequest returns true, then webKit will call your
	canonicalRequestForRequest method so you have an opportunity to modify
	the NSURLRequest before processing the request */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {

	NSLog(@"%@ received %@", self, NSStringFromSelector(_cmd));
	
	/* we don't do any special processing here, though we include this
	method because all subclasses must implement this method. */
	
    return request;
}


	/* our main loading routine.  This is where we do most of our processing
	for our class.  In this case, all we are doing is taking the path part
	of the url and rendering it in 36 point system font as a png file.  The
	interesting part is that we create the png entirely in memory and return
	it back for rendering in the webView.  */
- (void)startLoading {
	NSLog(@"%@ received %@ - start", self, NSStringFromSelector(_cmd));
	
		/* retrieve the current request. */
    NSURLRequest *request = [self request];
    
		/* Since the scheme is free to encode the url in any way it chooses, here
		we are using the url text to identify files names in our resources folder
		that we would like to display. */
		
		/* get the path component from the url */
	NSString *theString = [[[request URL] path] substringFromIndex:1];
	
        /* create UIImage from text */
	UIImage *myImage = [self imageFromString:theString];
    
		/* retrieve the png data for the image */
	NSData *data = UIImagePNGRepresentation(myImage);

		/* create the response record, set the mime type to png */
	NSURLResponse *response = 
		[[NSURLResponse alloc] initWithURL:[request URL] 
			MIMEType:@"image/png" 
			expectedContentLength:-1 
			textEncodingName:nil];
	
		/* get a reference to the client so we can hand off the data */
    id<NSURLProtocolClient> client = [self client];

		/* turn off caching for this response data */ 
	[client URLProtocol:self didReceiveResponse:response
			cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	
		/* set the data in the response to our jfif data */ 
	[client URLProtocol:self didLoadData:data];
	
		/* notify that we completed loading */
	[client URLProtocolDidFinishLoading:self];
	
		/* we can release our copy */
	[response release];
		
		/* if an error occured during our load, here is the code we would
		execute to send that information back to webKit.  We're not using it here,
		but you will probably want to use this code for proper error handling.  */
	if (0) { /* in case of error */
        int resultCode;
        resultCode = NSURLErrorResourceUnavailable;
        [client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain
			code:resultCode userInfo:nil]];
	}

		/* added the extra log statement here so you can see that stopLoading is called
		by the underlying machinery before we leave this routine. */
	NSLog(@"%@ received %@ - end", self, NSStringFromSelector(_cmd));
}

		/* called to stop loading or to abort loading.  We don't do anything special
		here. */
- (void)stopLoading
{
	NSLog(@"%@ received %@", self, NSStringFromSelector(_cmd));
}


@end

