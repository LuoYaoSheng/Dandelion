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
#import "PXListView+UserInteraction.h"

@interface MyListViewCell()

- (void)_reloadImage:(id)object;

@end

@implementation MyListViewCell

@synthesize headButton = _headButton;
@synthesize nameLabel = _nameLabel;
@synthesize timeLabel = _timeLabel;
@synthesize textLabel = _textLabel;
@synthesize imageButton = _imageButton;
@synthesize toolbarView = _toolbarView;
@synthesize scrollView = _scrollView;
@synthesize progessIndicator = _progessIndicator;
@synthesize message = _message;

#pragma mark - Init/Dealloc

- (id)initWithReusableIdentifier: (NSString*)identifier
{
	if((self = [super initWithReusableIdentifier:identifier])) {
       
	}
	return self;
}

- (void)awakeFromNib
{
    [self.toolbarView setAlphaValue:0];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    if (self.trackingAreas.count > 0)
        [self removeTrackingArea:[self.trackingAreas objectAtIndex:0]];
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                                                                  owner:self
                                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)dealloc
{
    [_message removeObserver:self forKeyPath:ATEntityPropertyNamedThumbnailImage];
    [_message release];
	[super dealloc];
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    self.headButton.image = nil;
	self.textLabel.string = @"";
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.isNew) {
		[RGBCOLOR(230,243,248) set];
    } else if([self isSelected]) {
		[RGBCOLOR(220, 220, 220) set];
	} else {
        [RGBCOLOR(240,240,240) set];
    }

    //Draw the border and background
	NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:0.0 yRadius:0.0];
	[roundedRect fill];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.07f];
    [[self.timeLabel animator] setAlphaValue:0];
    [[self.toolbarView animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.07f];
    [[self.timeLabel animator] setAlphaValue:1];
    [[self.toolbarView animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];  
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
		return [self.textLabel string];
	}
    
	if([attribute isEqualToString:NSAccessibilityEnabledAttribute])
	{
		return [NSNumber numberWithBool:YES];
	}

    return [super accessibilityAttributeValue:attribute];
}

- (IBAction)retweetClicked:(id)sender 
{
    [[self listView] handleRetweetCickedInCell:self];
}

- (IBAction)addFavoriteClicked:(id)sender 
{
    [[self listView] handleAddFavoriteClickedInCell:self];
}

- (IBAction)imageClicked:(id)sender 
{
    [[self listView] handleImageClickedInCell:self];
}

- (IBAction)headClicked:(id)sender 
{
    [[self listView] handleHeadClickedInCell:self];
}

- (void)loadImageForMessage:(QWMessage *)message
{
    [self.message removeObserver:self forKeyPath:ATEntityPropertyNamedThumbnailImage];
    self.message = message;
    [message addObserver:self forKeyPath:ATEntityPropertyNamedThumbnailImage options:0 context:NULL];
    
    [self.progessIndicator setHidden:NO];
    [self.progessIndicator startAnimation:nil];
    [self.imageButton setHidden:YES];
    if (message.thumbnailImage) {
        self.imageButton.image = message.thumbnailImage;
        [self.imageButton setHidden:NO];
        [self.progessIndicator setHidden:YES];
        
        NSRect imageButtonFrame = self.imageButton.frame;
        float widthDiff = imageButtonFrame.size.width - self.imageButton.image.size.width;
        imageButtonFrame = NSMakeRect(imageButtonFrame.origin.x+widthDiff/2, imageButtonFrame.origin.y, self.imageButton.image.size.width, self.imageButton.image.size.height);
        self.imageButton.frame = imageButtonFrame;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ATEntityPropertyNamedThumbnailImage]) {
        [self performSelectorOnMainThread:@selector(_reloadImage:) withObject:object waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
}

- (void)_reloadImage:(id)object 
{
    QWMessage *message = (QWMessage *)object;
    // Fade the imageView in, and fade the progress indicator out
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.8];
    [self.imageButton setAlphaValue:0];
    self.imageButton.image = message.thumbnailImage;
    [self.imageButton setHidden:NO];
    [[self.imageButton animator] setAlphaValue:1.0];
    [self.progessIndicator setHidden:YES];
    [NSAnimationContext endGrouping];
    
    NSRect imageButtonFrame = self.imageButton.frame;
    float widthDiff = imageButtonFrame.size.width - self.imageButton.image.size.width;
    imageButtonFrame = NSMakeRect(imageButtonFrame.origin.x+widthDiff/2, imageButtonFrame.origin.y, self.imageButton.image.size.width, self.imageButton.image.size.height);
    self.imageButton.frame = imageButtonFrame;
}

@end
