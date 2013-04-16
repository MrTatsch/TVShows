//
//  TSDDLFunctions.m
//  TVShows
//
//  Created by Julian Tatsch on 05.04.13.
//  Copyright (c) 2013 Víctor Pimentel. All rights reserved.
//

#import "TSDDLFunctions.h"

@implementation TSDDLFunctions

+ (BOOL)displayNotification:(NSString *)text{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"TVShows!";
    notification.informativeText = text;
    notification.soundName = NSUserNotificationDefaultSoundName;
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center setDelegate:[self self]];
    [center deliverNotification:notification];
    return TRUE;
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSRunAlertPanel([notification title], [notification informativeText], @"Ok", nil, nil);
}

+ (BOOL) downloadEpisode:(NSObject *)episode ofShow:(NSObject *)show
{
    NSString *episodeName = [episode valueForKey:@"episodeName"];
    NSString *showName = nil;
    NSString *episodeSeason = [episode valueForKey:@"episodeSeason"];
    NSString *episodeNumber = [episode valueForKey:@"episodeNumber"];
    
    // Choose the show name (it can be in two keys depending if the show is a preset or a subscription)
    if ([[show valueForKey:@"name"] rangeOfString:@"http"].location == NSNotFound) {
        showName = [show valueForKey:@"name"];
    } else {
        showName = [show valueForKey:@"displayName"];
    }
    NSString *queryString= [showName stringByReplacingOccurrencesOfString:@" " withString:@"."];
    queryString=[queryString stringByAppendingFormat:@".%@%@.hdtv-lol.mp4.html",episodeSeason,episodeNumber];
    queryString= [NSString stringWithFormat:@"(http://[^\\s]*%@)",queryString];
    
    NSURL *url=[NSURL URLWithString:@"http://feeds.feedburner.com/RlsSource"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url];
    NSError *error=nil;
    NSHTTPURLResponse *urlResponse = nil;
    NSString *page=nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest: request returningResponse: &urlResponse error: &error];
    if (urlResponse) {
        if ([urlResponse statusCode]==200) {
            page = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:queryString                options:NSRegularExpressionCaseInsensitive
                                                                                     error:nil];
            
            NSArray *matches = [regex matchesInString:page
                                              options:0
                                                range:NSMakeRange(0, [page length])];
            
            NSArray* reversedMatches = [[matches reverseObjectEnumerator] allObjects];
            
            for (NSTextCheckingResult *match in reversedMatches) {
                if (match){
                    NSRange matchRange = [match rangeAtIndex:1];
                    NSString *matchString = [page substringWithRange:matchRange];
                    NSString* escapedUrlString =
                    [matchString stringByAddingPercentEscapesUsingEncoding:
                     NSASCIIStringEncoding];
                    
                    NSString* urlString= [NSString stringWithFormat:@"http://192.168.179.1/cgi-bin/fritzload/gui_download.cgi?i=1&SET=1&showReverse=0&addLinks=%@",escapedUrlString];
                    
                    url = [NSURL URLWithString:urlString];
                    request = [[NSMutableURLRequest alloc] initWithURL: url];
                    responseData = [NSURLConnection sendSynchronousRequest: request returningResponse: &urlResponse error: &error];
                    
                    
                    
                    //or add to jDownloader
                    /*
                     NSString *path = @"/usr/bin/java";
                     NSArray *args = [NSArray arrayWithObjects: @"-jar", @"/Applications/JDownloader.app/Contents/Resources/app/JDownloader.jar",@"-a", matchString, nil];
                     [NSTask launchedTaskWithLaunchPath:path arguments:args];
                     */
                    
                }
            }
            if ([matches count]>0) {
                [self displayNotification:[episodeName stringByAppendingString:@" has been added to your downloader"]];
                return YES;
            }
        }
    }
    return NO;
}

@end
