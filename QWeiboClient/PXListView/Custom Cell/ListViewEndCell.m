//
//  ListViewEndCell.m
//  QWeiboClient
//
//  Created by  on 11-10-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ListViewEndCell.h"

@implementation ListViewEndCell

@synthesize indicator = _indicator;
@synthesize endImageView = _endImageView;

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
    
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    [RGBCOLOR(240,240,240) set];
    
    //Draw the border and background
	NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:0.0 yRadius:0.0];
	[roundedRect fill];
}

- (void)startAnimating 
{
    [self.endImageView setHidden:YES];
	[self.indicator startAnimation:nil];
}

- (void)stopAnimating 
{
    [self.endImageView setHidden:NO];
    [self.indicator stopAnimation:nil];
}

@end
