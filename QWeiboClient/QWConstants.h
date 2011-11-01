//
//  QWConstants.h
//  QWeiboClient
//
//  Created by  on 11-9-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#define RGBCOLOR(R,G,B)                                     [NSColor colorWithDeviceRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
#define LINK_COLOR                                          RGBCOLOR(0,64,128)

#define APP_KEY                                             @"c3fc7da94f594e219f92ee68c1eaf06b"
#define APP_SECRET                                          @"658fb582a1c44f2ae47ce7a27c3a7aed"
#define REQUEST_TOKEN_KEY                                   @"REQUEST_TOKEN_KEY"
#define REQUEST_TOKEN_SECRET_KEY                            @"REQUEST_TOKEN_SECRET_KEY"
#define ACCESS_TOKEN_KEY                                    @"ACCESS_TOKEN_KEY"
#define ACCESS_TOKEN_SECRET_KEY                             @"ACCESS_TOKEN_SECRET_KEY"

#define LISTVIEW_RESIZED_NOTIFICATION                       @"LISTVIEW_RESIZED_NOTIFICATION"
#define GET_TIMELINE_NOTIFICATION                           @"GET_TIMELINE_NOTIFICATION"
#define GET_METHIONS_NOTIFICATION                           @"GET_METHIONS_NOTIFICATION"
#define GET_MESSAGES_NOTIFICATION                           @"GET_MESSAGES_NOTIFICATION"
#define GET_FAVORITES_NOTIFICATION                          @"GET_FAVORITES_NOTIFICATION"
#define GET_USER_INFO_NOTIFICATION                          @"GET_USER_INFO_NOTIFICATION"
#define PUBLISH_MESSAGE_NOTIFICATION                        @"PUBLISH_MESSAGE_NOTIFICATION"
#define LOGOUT_NOTIFICATION                                 @"LOGOUT_NOTIFICATION"
#define GET_UPDATE_COUNT_NOTIFICATION                       @"GET_UPDATE_COUNT_NOTIFICATION"

#define VERIFY_URL                                          @"http://open.t.qq.com/cgi-bin/authorize?oauth_token="

#define GROWL_NOTIFICATION_TIMELINE                         @"Timeline"
#define GROWL_NOTIFICATION_MENTHIONS                        @"Mentions"
#define GROWL_NOTIFICATION_MESSAGES                         @"Messages"
#define GROWL_NOTIFICATION_FOLLOWERS                        @"Followers"

#define UPDATE_INTERVAL_TIMELINE                            60
#define UPDATE_INTERVAL_MENTHIONS                           120
#define UPDATE_INTERVAL_MESSAGES                            300

