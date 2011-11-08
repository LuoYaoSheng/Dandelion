//
//  MenuItemViewController.m
//  CocoaTest
//
//  Created by  on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuItemViewController.h"
#import "ImagePickerMenuItemView.h"

@implementation MenuItemViewController

@synthesize faces = _faces;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)loadView
{
//    [super loadView];
   
    self.view = [[ImagePickerMenuItemView alloc] init];
  
    /* Setup a mutable dictionary as the view controller's represeted object so we can bind the custom view to it.
     */
    NSMutableDictionary *pickerMenuData = [NSMutableDictionary dictionaryWithCapacity:2];
    [pickerMenuData setObject:self.faces forKey:@"faces"];
    [pickerMenuData setObject:[NSNull null] forKey:@"selectedFace"]; // need a blank entry to start with
    self.representedObject = pickerMenuData;
    
    // Bind the custom view to the image URLs array.
    [self.view bind:@"faces" toObject:self withKeyPath:@"representedObject.faces" options:nil];
    /* selectedImageUrl from the view is read only, so bind the data dictinary to the selectedImageUrl instead of the other way around.
     */
    [self.representedObject bind:@"selectedFace" toObject:self.view withKeyPath:@"selectedFace" options:nil];
}

- (void)dealloc
{
    [_faces release];
    [super dealloc];
}

@end
