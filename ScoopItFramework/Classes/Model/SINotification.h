//
//  SINotification.h
//  ScoopItFramework
//
//  Created by Vincent Demay on 04/07/11.
//  Copyright 2011 Goojet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIModel.h"

typedef enum types {
    NotificationTopicNewComment = 0,
    NotificationTopicSubscription,
    NotificationUserPostThanked,
    NotificationUserWelcomeMessage,
    NotificationUserSnsContact,
    NotificationUserSnsTopicCreated,
    NotificationUserSuggestionAccepted,
    NotificationUserNewCommentResponse,
    NotificationUserNewUserSuggestion,
    NotificationTopicCuratorNewUserSuggestion,
    NotificationPendingUserSuggestionReminder,
    NotificationUnknown
} NotificationType;

//TODO : implement
@interface SINotification : SIModel {
    
}

@end
