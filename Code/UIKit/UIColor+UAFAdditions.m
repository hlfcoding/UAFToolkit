//
//  UIColor+UAFAdditions.m
//  UAFToolkit
//
//  Created by Peng Wang on 7/23/12.
//  Copyright (c) 2012-2014 UseAllFive. See license.
//

#import "UIColor+UAFAdditions.h"

@interface NSString (UAFPrivateAdditions)
- (NSUInteger)_hexValue;
@end

@implementation NSString (UAFPrivateAdditions)
- (NSUInteger)_hexValue {
	NSUInteger result = 0;
	sscanf([self UTF8String], "%x", &result);
	return result;
}
@end

@implementation UIColor (UAFAdditions)

#pragma mark - Sam Soffes

+ (UIColor *)colorWithHexString:(NSString *)hex {
	// Remove `#`
	if ([[hex substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"#"]) {
		hex = [hex substringFromIndex:1];
	}
	
	// Invalid if not 3, 6, or 8 characters
	NSUInteger length = [hex length];
	if (length != 3 && length != 6 && length != 8) {
		return nil;
	}
	
	// Make the string 8 characters long for easier parsing
	if (length == 3) {
		NSString *r = [hex substringWithRange:NSMakeRange(0, 1)];
		NSString *g = [hex substringWithRange:NSMakeRange(1, 1)];
		NSString *b = [hex substringWithRange:NSMakeRange(2, 1)];
		hex = [NSString stringWithFormat:@"%@%@%@%@%@%@ff",
           r, r, g, g, b, b];
	} else if (length == 6) {
		hex = [hex stringByAppendingString:@"ff"];
	}
	
	CGFloat red = [[hex substringWithRange:NSMakeRange(0, 2)] _hexValue] / 255.0f;
	CGFloat green = [[hex substringWithRange:NSMakeRange(2, 2)] _hexValue] / 255.0f;
	CGFloat blue = [[hex substringWithRange:NSMakeRange(4, 2)] _hexValue] / 255.0f;
	CGFloat alpha = [[hex substringWithRange:NSMakeRange(6, 2)] _hexValue] / 255.0f;
  
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString *)hexValue {
	return [self hexValueWithAlpha:NO];
}

- (NSString *)hexValueWithAlpha:(BOOL)includeAlpha {
	CGColorRef color = self.CGColor;
	size_t count = CGColorGetNumberOfComponents(color);
	const CGFloat *components = CGColorGetComponents(color);
	
	static NSString *stringFormat = @"%02x%02x%02x";
	
	NSString *hex = nil;
	
	// Grayscale
	if (count == 2) {
		NSUInteger white = (NSUInteger)(components[0] * 255.0f);
		hex = [NSString stringWithFormat:stringFormat, white, white, white];
	}
	
	// RGB
	else if (count == 4) {
		hex = [NSString stringWithFormat:stringFormat, (NSUInteger)(components[0] * 255.0f),
           (NSUInteger)(components[1] * 255.0f), (NSUInteger)(components[2] * 255.0f)];
	}
	
	// Add alpha
	if (hex && includeAlpha) {
		hex = [hex stringByAppendingFormat:@"%02x", (NSUInteger)(self.alpha * 255.0f)];
	}
	
	// Unsupported color space
	return hex;
}

- (CGFloat)red {
	CGColorRef color = self.CGColor;
	if (CGColorSpaceGetModel(CGColorGetColorSpace(color)) != kCGColorSpaceModelRGB) {
		return -1.0f;
	}
	CGFloat const *components = CGColorGetComponents(color);
	return components[0];
}

- (CGFloat)green {
	CGColorRef color = self.CGColor;
	if (CGColorSpaceGetModel(CGColorGetColorSpace(color)) != kCGColorSpaceModelRGB) {
		return -1.0f;
	}
	CGFloat const *components = CGColorGetComponents(color);
	return components[1];
}

- (CGFloat)blue {
	CGColorRef color = self.CGColor;
	if (CGColorSpaceGetModel(CGColorGetColorSpace(color)) != kCGColorSpaceModelRGB) {
		return -1.0f;
	}
	CGFloat const *components = CGColorGetComponents(color);
	return components[2];
}

- (CGFloat)alpha {
	return CGColorGetAlpha(self.CGColor);
}

@end
