//
//  GoogleMusicViewController.h
//  GoogleMusic
//
//  Created by Wicks, Gregory on 7/23/15.
//  Copyright (c) 2015 Wicks, Gregory. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoogleMusicViewController : UIViewController <UIWebViewDelegate>

-(NSMutableArray*) getSongs;
-(void) loginWithUsername:(NSString*)uname withPassword:(NSString*) pass;
-(void) processSongs:(NSString*) data;
-(NSString*) getStreamUrl:(NSString*) songID;

@end
