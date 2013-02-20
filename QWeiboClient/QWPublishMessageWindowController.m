//
//  QWPublishMessageWindowController.m
//  QWeiboClient
//
//  Created by Leon on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QWPublishMessageWindowController.h"
#import "MenuItemViewController.h"
#import "MyTextAttachmentCell.h"

@interface QWPublishMessageWindowController()

- (void)setupImagesMenu;
- (NSString *)plainTextFromAttachmentAttributedString:(NSAttributedString *)attrString;

@end

@implementation QWPublishMessageWindowController

@synthesize messageTextView = _messageTextView;
@synthesize orgMessage = _orgMessage;
@synthesize imageView = _imageView;
@synthesize imageLabel = _imageLabel;
@synthesize deleteImageButton = _deleteImageButton;
@synthesize atLabel = _atLabel;
@synthesize filePath = _filePath;
@synthesize publishButton = _publishButton;
@synthesize imagePicker = _imagePicker;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        api = [[QWeiboAsyncApi alloc] init];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self setupImagesMenu];
    
    self.messageTextView.font = [NSFont systemFontOfSize:13];
    self.imageView.allowDrag = NO;
    self.imageView.delegate = self;
    if (self.orgMessage) {
        [self.publishButton setEnabled:YES];
        self.atLabel.stringValue = [NSString stringWithFormat:@"@%@", self.orgMessage.nick];
        self.imageView.allowDrop = NO;
        self.imageLabel.stringValue = @"不能添加图片";
        [self.deleteImageButton setHidden:YES];
    } else {
        [self.publishButton setEnabled:NO];
        self.imageView.allowDrop = YES;
        self.imageLabel.stringValue = @"拖动图片到这里";
        [self.deleteImageButton setHidden:NO];
    }
}

- (void)dealloc
{
    [api release];
    [_orgMessage release];
    [_filePath release];
    [super dealloc];
}

- (IBAction)publishClicked:(id)sender {
    NSString *messageText = [self plainTextFromAttachmentAttributedString:self.messageTextView.attributedString];
    if (self.orgMessage)
        [api retweet:self.orgMessage content:messageText];
    else {
        if (self.filePath && ![self.filePath isEqualToString:@""])
            [api publishMessage:messageText withPicture:self.filePath];
        else
            [api publishMessage:messageText];
    }
        
    [NSApp endSheet:self.window];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if ([menuItem action] == @selector(publishClicked:)) 
        return self.publishButton.isEnabled;
    return YES;
}

- (IBAction)cacelClicked:(id)sender {
    [NSApp endSheet:self.window];    
}

- (IBAction)deleteImageClicked:(id)sender 
{    
    self.imageView.image = nil;
    [self.imageLabel setHidden:NO];
}

- (void)dropComplete:(NSString *)filePath
{
    [self.imageLabel setHidden:YES];
    self.filePath = filePath;
}

- (void)textViewDidChangeSelection:(NSNotification *)notification
{
    if ((self.messageTextView.string && ![self.messageTextView.string isEqualToString:@""]) || (self.atLabel.stringValue && ![self.atLabel.stringValue isEqualToString:@""]))
        [self.publishButton setEnabled:YES];
    else
        [self.publishButton setEnabled:NO];
}

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pb
{
    NSArray *types = [pb types]; 
    if ([types containsObject:NSStringPboardType]) { 
        NSString *value = [pb stringForType:NSStringPboardType]; 
        self.messageTextView.string = value;
        return YES; 
    } 
    
    return NO; 
}

- (void)writeToPasteboard:(NSPasteboard *)pb withString:string
{ 
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self]; 
    [pb setString:string forType:NSStringPboardType]; 
} 

- (void)setupImagesMenu 
{
	NSMenu *menu = [self.imagePicker menu];
    
    //    // Look for existing ImagePickerMenuItemView menu items that are no longer valid and remove them.
    //	while ((menuItem = [menu itemWithTag:1001])) {
    //		[menu removeItem:menuItem];
    //	}
	
    // Find the prototype menu item. We want to keep it as the prototype for future rebuilds so we don't want to actually use it. Instead, make it hidden so the user never sees it.
	NSMenuItem *masterImagesMenuItem = [[self.imagePicker menu] itemWithTag:1000];
	[masterImagesMenuItem setHidden:YES];
	
	// Find all the entires in the _baseURL directory.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
	NSArray *faceArray = [NSArray arrayWithContentsOfFile:path];
	
    // Only 4 images per menu item are allowed by the view. Use this index to keep track of that
	NSInteger idx = 0;
    
    // ImagePickerMenuItemView uses an array of URLS. This is that array.
    NSMutableArray *faces;
    
    // Loop over each entry looking for image files
	for (NSDictionary *dict in faceArray) {
        if	(idx == 0) {
            // Starting a new set of 4 images. Setup a new menu item and URL array
            faces = [NSMutableArray arrayWithCapacity:FACE_LINE_SIZE];
            
            // Duplicate the prototype menu item
            NSMenuItem *imagesMenuItem = [masterImagesMenuItem copy];
            
            // Load the custom view from its nib
            MenuItemViewController *viewController = [[MenuItemViewController alloc] init];
            viewController.faces = faces;

            // transform the duplicated menu item prototype to a proper custom instance
            [imagesMenuItem setRepresentedObject:viewController];
            [imagesMenuItem setView:viewController.view];
            [imagesMenuItem setTag:1001]; // set the tag to 1001 so we can remove this instance on rebuild (see above)
            [imagesMenuItem setHidden:NO];
            [imagesMenuItem setTitle:@""];
            
            // Insert the custom menu item
            [menu insertItem:imagesMenuItem atIndex:[menu numberOfItems] - 1];
            
            // Cleanup memory
            [imagesMenuItem release];
            [viewController release];
        }
        
        /* Add the image URL to the mutable array stored in the view controller's representedObject dictionary. Since imageUrlArray is mutable, we can just modify it in place.
         */
        [faces addObject:dict];
        
        // Update our index. We can only put 4 images per custom menu item. Reset after every fourth image file.
        idx++;
        if (idx > (FACE_LINE_SIZE-1)) idx = 0; // with a 0 based index, when idx > 3 we'll have completed 4 passes.
	}
}

- (IBAction)takeImageFrom:(id)sender {
    NSViewController *viewController = [sender representedObject];
    NSDictionary *menuItemData = [viewController representedObject];
    id face = [menuItemData objectForKey:@"selectedFace"];
    NSImage * pic = [NSImage imageNamed:[face objectForKey:@"image"]];
    MyTextAttachmentCell *attachmentCell = [[MyTextAttachmentCell alloc] initImageCell:pic];
    attachmentCell.faceText = [face objectForKey:@"text"];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell: attachmentCell];
    NSAttributedString *imageString = [NSAttributedString  attributedStringWithAttachment: attachment];
    [self.messageTextView insertText:imageString];
}

- (NSString *)plainTextFromAttachmentAttributedString:(NSAttributedString *)attrString
{
    NSMutableString *plainText = [NSMutableString stringWithString:@""];
    for(int i =0;i<[attrString length];i++) {
        NSDictionary *attr= [attrString attributesAtIndex:i effectiveRange:NULL];
        
        //Check whether attribute contains NSAttachment or not
        if ([attr objectForKey:@"NSAttachment"] != nil) {
            NSString *faceText = ((MyTextAttachmentCell *)[[attr objectForKey:@"NSAttachment"] attachmentCell]).faceText;
            [plainText appendString:faceText];
        } else {
            //Add character to plain text
            [plainText appendFormat:@"%C", [[attrString string] characterAtIndex:i]];
        }
    }
    return plainText;
}

@end
