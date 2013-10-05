//
//  GoogleMusicAPI.h
//  gTunes
//
//  Created by Gregory Wicks on 10/3/13.
//  Copyright (c) 2013 Carney Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleMusicAPI : NSObject

-(void)loginWithUsername:(NSString*)username withPassword:(NSString*)password;
-(void)readSongs;
-(NSMutableArray*)getAllSongs;
-(NSString*)getStreamUrl:(NSString*)songID;

@end