//
//  TSDDLFunctions.h
//  TVShows
//
//  Created by Julian Tatsch on 05.04.13.
//  Copyright (c) 2013 Víctor Pimentel. All rights reserved.
//

@interface TSDDLFunctions : NSObject <NSUserNotificationCenterDelegate>  {
}
+ (BOOL) downloadEpisode:(NSObject *)episode ofShow:(NSObject *)show;
@end