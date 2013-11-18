//
//  GoogleMusicAPI.m
//  gTunes
//
//  Created by Gregory Wicks on 10/3/13.
//  Copyright (c) 2013 Gregory Wicks. All rights reserved.
//

#import "GoogleMusicAPI.h"

@implementation GoogleMusicAPI

NSString *authToken = @"";
NSString *xtToken = @"";
NSMutableArray *mSongArr;
NSString *mfinalResponse = @"";
NSString *urlResponse = @"";

NSString *usename = @"";
NSString *pwd = @"";

int stage = 0;

-(void)loginWithUsername:(NSString*)username withPassword:(NSString*)password
{
    usename = username;
    pwd = password;
    NSString *post = [NSString stringWithFormat:@"&Email=%@&Passwd=%@&service=sj",username,password];
    
    
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/accounts/ClientLogin"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    if (stage == -1)
    {
        urlResponse = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        NSLog(urlResponse);
        
    }
    else if (stage == 0)
    {
        NSString *response = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        //NSLog(response);
        NSArray *respArray = [response componentsSeparatedByString:@"\n"];
        response = [respArray objectAtIndex:2];
        response = [response stringByReplacingOccurrencesOfString:@"Auth=" withString:@""];
        //NSLog(response);
        authToken = response;
        
    }
    else if (stage == 1)
    {
        NSString *response = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        //Nab the almighty xt cookie's data, it's important
        for (NSHTTPCookie *cookie in [cookieJar cookies])
        {
            
            if ([[cookie name] isEqualToString:@"xt"])
            {
                xtToken = [cookie value];
                //NSLog(@"xt cookie: %@",xtToken);
            }
        }
        
    }
    else if (stage == 2)
    {
        NSString *response = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
        //NSLog(response);
        mfinalResponse = [mfinalResponse stringByAppendingString:response];
        
    }
}

-(void)contRequest
{
    stage = 1;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://play.google.com/music/listen?u=0"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",authToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

-(void)readSongs
{
    stage = 2;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://play.google.com/music/services/loadalltracks?u=0&xt=%@",xtToken]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",authToken] forHTTPHeaderField:@"Authorization"];
    
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[challenge sender] useCredential:[NSURLCredential
                                       credentialWithUser:usename
                                       password:pwd
                                       persistence:NSURLCredentialPersistencePermanent] forAuthenticationChallenge:challenge];
    
}

-(NSMutableArray*)getAllSongs
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://play.google.com/music/services/loadalltracks?u=0&xt=%@",xtToken]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",authToken] forHTTPHeaderField:@"Authorization"];
    
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    NSURLResponse *response;
    NSData *respon = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    mfinalResponse = [[NSString alloc] initWithData:respon encoding:NSUTF8StringEncoding];
    NSError *localerror;
    NSData *jsonData = [mfinalResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSString *pString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *songDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&localerror];
    if (localerror)
    {
        NSLog(@"%@",[localerror description]);
    }
    else
    {
        mSongArr = [[NSMutableArray alloc] init];
        NSLog(@"Successfully parsed");
        NSArray *songArray = songDict[@"playlist"];
        NSLog(@"%d",[songArray count]);
        for (NSDictionary *song in songArray)
        {
            [mSongArr addObject:song];
        }
        NSLog(@"%d",[mSongArr count]);
        
    }
    return mSongArr;
}

-(NSString*)getStreamUrl:(NSString*)songID
{
    stage = -1;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://play.google.com/music/play?u=0&songid=%@&pt=e",songID]]];
    [request setHTTPMethod:@"GET"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",authToken] forHTTPHeaderField:@"Authorization"];
    
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *resp = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *test = [[NSString alloc] initWithData:resp encoding:NSUTF8StringEncoding];
    NSData *jsonData = [test dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *urlDict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:nil];
    
    
    return urlDict[@"url"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Finished Loading");
    if (stage == -1)
    {
        stage = -2;
        
    }
    else if (stage == 0)
    {
        stage = 1;
        [self contRequest];
        
    }
    else if (stage == 1)
    {
        //stage = 2;
        //[self readSongs];
    }
    else if (stage == 2)
    {
        NSError *localerror;
        NSData *jsonData = [mfinalResponse dataUsingEncoding:NSUTF8StringEncoding];
        NSString *pString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSDictionary *songDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&localerror];
        if (localerror)
        {
            NSLog(@"%@",[localerror description]);
        }
        else
        {
            mSongArr = [[NSMutableArray alloc] init];
            NSLog(@"Successfully parsed");
            NSArray *songArray = songDict[@"playlist"];
            NSLog(@"%d",[songArray count]);
            for (NSDictionary *song in songArray)
            {
                [mSongArr addObject:song];
            }
            NSLog(@"%d",[mSongArr count]);
            
        }
    }
}

@end
