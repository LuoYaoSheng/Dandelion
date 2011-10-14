//
//  MyListViewCell.h
//  PXListView
//
//  Created by Alex Rozanski on 29/05/2010.
//  Copyright 2010 Alex Rozanski. http://perspx.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PXListViewCell.h"

@interface MyListViewCell : PXListViewCell
{
}

@property (assign) IBOutlet NSButton *headButton;
@property (assign) IBOutlet NSTextField *nameLabel;
@property (assign) IBOutlet NSTextField *timeLabel;
@property (assign) IBOutlet NSTextField *textLabel;
@property (assign) IBOutlet NSImageView *imageView;

@end
