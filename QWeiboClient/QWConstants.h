//
//  QWConstants.h
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#define APP_KEY     @"c3fc7da94f594e219f92ee68c1eaf06b"
#define APP_SECRET  @"658fb582a1c44f2ae47ce7a27c3a7aed"
#define AppTokenKey		@"tokenKey"
#define AppTokenSecret	@"tokenSecret"
#define VERIFY_URL @"http://open.t.qq.com/cgi-bin/authorize?oauth_token="
#define LISTVIEW_RESIZED_NOTIFICATION @"LISTVIEW_RESIZED_NOTIFICATION"
#define RGBCOLOR(R,G,B) [NSColor colorWithDeviceRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]

#define GET_HOME_MESSAGE_NOTIFICATION   @"GET_HOME_MESSAGE_NOTIFICATION"
#define PUBLISH_MESSAGE_NOTIFICATION    @"PUBLISH_MESSAGE_NOTIFICATION"
#define GET_USER_INFO_NOTIFICATION      @"GET_USER_INFO_NOTIFICATION"

#define GET_HOME_MESSAGE_URL    @"http://open.t.qq.com/api/statuses/home_timeline"
#define PUBLISH_MESSAGE_URL     @"http://open.t.qq.com/api/t/add"
#define PUBLISH_IMAGE_URL       @"http://open.t.qq.com/api/t/add_pic"
#define GET_USER_INFO_URL       @"http://open.t.qq.com/api/user/info"