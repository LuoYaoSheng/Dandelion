//
//  MyTextAttachmentCell.m
//  Dandelion
//
//  Created by  on 11-11-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MyTextAttachmentCell.h"

@implementation MyTextAttachmentCell

@synthesize faceText = _faceText;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [_faceText release];
    [super dealloc];
}

@end
