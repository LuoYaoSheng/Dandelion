//
//  MyListViewCell.h
//  PXListView
//
//  Created by Alex Rozanski on 29/05/2010.
//  Copyright 2010 Alex Rozanski. http://perspx.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXListViewCell.h"
#import <QWeiboSDK/QWMessage.h>

@interface MyListViewCell : PXListViewCell
{
    NSScrollView *_scrollView;
}

@property (assign) IBOutlet NSButton *headButton;
@property (assign) IBOutlet NSTextField *nameLabel;
@property (assign) IBOutlet NSTextField *timeLabel;
@property (assign) IBOutlet NSTextView *textLabel;
@property (assign) IBOutlet NSButton *imageButton;
@property (assign) IBOutlet NSView *toolbarView;
@property (assign) IBOutlet NSScrollView *scrollView;
@property (assign) IBOutlet NSProgressIndicator *progessIndicator;
@property (retain) QWMessage *message;

- (IBAction)retweetClicked:(id)sender;
- (IBAction)addFavoriteClicked:(id)sender;
- (IBAction)imageClicked:(id)sender;
- (IBAction)headClicked:(id)sender;
- (void)loadImageForMessage:(QWMessage *)message;

@end
