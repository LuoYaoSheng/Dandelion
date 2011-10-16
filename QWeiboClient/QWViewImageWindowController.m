//
//  QWViewImageWindowController.m
//  QWeiboClient
//
//  Created by Leon on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "QWViewImageWindowController.h"
#import "DragDropImageView.h"

@implementation QWViewImageWindowController

@synthesize imageView;

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

- (void)loadImage:(NSString *)imageURL
{
    self.imageView.image = nil;
    self.imageView.image = [[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]] autorelease];
    NSRect imageViewFrame = self.imageView.frame;
    imageViewFrame.size = self.imageView.image.size;
    self.imageView.frame = imageViewFrame;
    self.imageView.superview.frame = self.imageView.frame;
}

- (void)dealloc
{
    [super dealloc];
}

@end
