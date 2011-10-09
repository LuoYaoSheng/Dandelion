//
//  ListViewEndCell.h
//  QWeiboClient
//
//  Created by  on 11-10-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXListViewCell.h"

@interface ListViewEndCell : PXListViewCell {

}

@property (assign) IBOutlet NSProgressIndicator *indicator;
@property (assign) IBOutlet NSImageView *endImageView;

- (void)startAnimating;
- (void)stopAnimating;

@end
