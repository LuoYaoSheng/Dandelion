//
//  QWViewImageWindowController.m
//  QWeiboClient
//
//  Created by Leon on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "QWViewImageWindowController.h"
#import "DragDropImageView.h"

@interface QWViewImageWindowController()

- (void)_reloadImage:(id)object;

@end

@implementation QWViewImageWindowController

@synthesize imageView;
@synthesize progessIndicator = _progessIndicator;
@synthesize message = _message;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    ((DragDropImageView *)self.imageView).allowDrag = YES;
    ((DragDropImageView *)self.imageView).allowDrop = NO;
}

- (void)loadImageForMessage:(QWMessage *)message
{
    [self.message removeObserver:self forKeyPath:ATEntityPropertyNamedFullImage];
    self.message = message;
    [message addObserver:self forKeyPath:ATEntityPropertyNamedFullImage options:0 context:NULL];
    
    [self.progessIndicator setHidden:NO];
    [self.progessIndicator startAnimation:nil];
    [self.imageView setHidden:YES];
    if (message.fullImage) {
        self.imageView.image = message.fullImage;
        [self.imageView setHidden:NO];
        [self.progessIndicator setHidden:YES];
        NSRect imageViewFrame = self.imageView.frame;
        NSImageRep *imageRep = [[self.imageView.image representations] lastObject];
        imageViewFrame.size = NSMakeSize(imageRep.pixelsWide, imageRep.pixelsHigh);
        self.imageView.frame = imageViewFrame;
        self.imageView.superview.frame = self.imageView.frame;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ATEntityPropertyNamedFullImage]) {
        [self performSelectorOnMainThread:@selector(_reloadImage:) withObject:object waitUntilDone:NO modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
}

- (void)_reloadImage:(id)object 
{
    QWMessage *message = (QWMessage *)object;
    // Fade the imageView in, and fade the progress indicator out
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.8];
    [self.imageView setAlphaValue:0];
    self.imageView.image = message.fullImage;
    [self.imageView setHidden:NO];
    [[self.imageView animator] setAlphaValue:1.0];
    [self.progessIndicator setHidden:YES];
    [NSAnimationContext endGrouping];
    
    NSRect imageViewFrame = self.imageView.frame;
    imageViewFrame.size = self.imageView.image.size;
    self.imageView.frame = imageViewFrame;
    self.imageView.superview.frame = self.imageView.frame;
}

- (void)dealloc
{
    [_message removeObserver:self forKeyPath:ATEntityPropertyNamedFullImage];
    [_message release];
    [super dealloc];
}

@end
