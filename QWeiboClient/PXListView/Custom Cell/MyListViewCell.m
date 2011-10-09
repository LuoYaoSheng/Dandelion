//
//  MyListViewCell.m
//  PXListView
//
//  Created by Alex Rozanski on 29/05/2010.
//  Copyright 2010 Alex Rozanski. http://perspx.com. All rights reserved.
//

#import "MyListViewCell.h"
#import <iso646.h>
#import "PXListViewConstants.h"


@implementation MyListViewCell


@synthesize headButton = _headButton;
@synthesize nameLabel = _nameLabel;
@synthesize timeLabel = _timeLabel;
@synthesize textLabel = _textLabel;

#pragma mark - Init/Dealloc

- (id)initWithReusableIdentifier: (NSString*)identifier
{
	if((self = [super initWithReusableIdentifier:identifier]))
	{
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    self.headButton.image = nil;
	self.textLabel.stringValue = @"";
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	if([self isSelected]) {
		[RGBCOLOR(220, 220, 220) set];
	}
	else {
		[RGBCOLOR(240,240,240) set];
    }

    //Draw the border and background
	NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:0.0 yRadius:0.0];
	[roundedRect fill];
}

#pragma mark - Accessibility

- (NSArray*)accessibilityAttributeNames
{
	NSMutableArray*	attribs = [[[super accessibilityAttributeNames] mutableCopy] autorelease];
	
	[attribs addObject: NSAccessibilityRoleAttribute];
	[attribs addObject: NSAccessibilityDescriptionAttribute];
	[attribs addObject: NSAccessibilityTitleAttribute];
	[attribs addObject: NSAccessibilityEnabledAttribute];
	
	return attribs;
}

- (BOOL)accessibilityIsAttributeSettable:(NSString *)attribute
{
	if( [attribute isEqualToString: NSAccessibilityRoleAttribute]
		or [attribute isEqualToString: NSAccessibilityDescriptionAttribute]
		or [attribute isEqualToString: NSAccessibilityTitleAttribute]
		or [attribute isEqualToString: NSAccessibilityEnabledAttribute] )
	{
		return NO;
	}
	else
		return [super accessibilityIsAttributeSettable: attribute];
}

- (id)accessibilityAttributeValue:(NSString*)attribute
{
	if([attribute isEqualToString:NSAccessibilityRoleAttribute])
	{
		return NSAccessibilityButtonRole;
	}
	
    if([attribute isEqualToString:NSAccessibilityDescriptionAttribute]
			or [attribute isEqualToString:NSAccessibilityTitleAttribute])
	{
		return [self.textLabel stringValue];
	}
    
	if([attribute isEqualToString:NSAccessibilityEnabledAttribute])
	{
		return [NSNumber numberWithBool:YES];
	}

    return [super accessibilityAttributeValue:attribute];
}

@end
