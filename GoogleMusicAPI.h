//
//  GoogleMusicAPI.h
//  gTunes
//
//  Created by Gregory Wicks on 10/3/13.
//  Copyright (c) 2013 Gregory Wicks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleMusicAPI : NSObject

-(void)loginWithUsername:(NSString*)username withPassword:(NSString*)password;
-(NSMutableArray*)getAllSongs;
-(NSString*)getStreamUrl:(NSString*)songID;

@end
