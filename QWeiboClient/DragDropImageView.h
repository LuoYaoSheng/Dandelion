/*
     File: DragDropImageView.h
 Abstract: Custom subclass of NSImageView with support for drag and drop operations.
  Version: 1.1
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface DragDropImageView : NSImageView <NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>
{
    //highlight the drop zone
    BOOL highlight;
}

@property (assign) BOOL allowDrag;
@property (assign) BOOL allowDrop;

- (id)initWithCoder:(NSCoder *)coder;

@end
