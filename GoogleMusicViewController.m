//
//  GoogleMusicViewController.m
//  GoogleMusic
//
//  Created by Wicks, Gregory on 7/23/15.
//  Copyright (c) 2015 Wicks, Gregory. All rights reserved.
//

#import "GoogleMusicViewController.h"

@interface GoogleMusicViewController ()

@end

NSString *xtCookie;
UIWebView *webView;
int runCount = 0;
NSMutableArray *mSongArr;
NSString *passw;

@implementation GoogleMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void) loginWithUsername:(NSString*)uname withPassword:(NSString*) pass {
    NSString *username = uname;
    passw = pass;
    
    NSString *post = [NSString stringWithFormat:@"&Email=%@&Passwd=%@&service=sj&continue=https://play.google.com/music/listen",username, passw];
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    [webView setDelegate:self];
    mSongArr = [[NSMutableArray alloc] init];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: @"https://accounts.google.com/ServiceLoginAuth"] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10.0f];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) getStreamUrl:(NSString*) songID {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://play.google.com/music/play?u=0&songid=%@&xt=%@&pt=e",songID, xtCookie]]];
    [request setHTTPMethod:@"GET"];
    
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *resp = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *test = [[NSString alloc] initWithData:resp encoding:NSUTF8StringEncoding];
    NSData *jsonData = [test dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *urlDict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:nil];
    
    
    return urlDict[@"url"];
}

-(void) processSongs:(NSString*) data {
    NSString *mfinalResponse = data;
    NSRange range = [mfinalResponse rangeOfString:@"<script type='text/javascript'>\nwindow.parent['slat_process'](["];
    mfinalResponse = [mfinalResponse substringFromIndex:NSMaxRange(range)];
    NSRange endRange = [mfinalResponse rangeOfString:@");\nwindow.parent['slat_progress']"];
    mfinalResponse = [mfinalResponse substringToIndex:endRange.location];
    
    
    
    mfinalResponse = [NSString stringWithFormat:@"{\"playlist\":%@}",mfinalResponse];
    mfinalResponse = [mfinalResponse stringByReplacingOccurrencesOfString:@",," withString:@","];
    while ([mfinalResponse rangeOfString:@",,"].location != NSNotFound)
    {
        mfinalResponse = [mfinalResponse stringByReplacingOccurrencesOfString:@",," withString:@",\"\","];
    }
    NSRange lastComma = [mfinalResponse rangeOfString:@"," options:NSBackwardsSearch];
    mfinalResponse = [mfinalResponse substringToIndex:lastComma.location];
    mfinalResponse = [NSString stringWithFormat:@"%@}",mfinalResponse];
    
    NSError *localerror;
    NSData *jsonData = [mfinalResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *songDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&localerror];

    if (localerror)
    {
        NSLog(@"%@",[localerror description]);
    }
    else
    {
        NSArray *songArray = songDict[@"playlist"];
        NSDictionary *tempDict;
        for (NSArray *song in songArray)
        {
            if ([[song objectAtIndex:2] length] > 0)
            {
                tempDict = @{@"id":[song objectAtIndex:0],@"title":[song objectAtIndex:1],@"artist":[song objectAtIndex:3],@"album":[song objectAtIndex:4],@"genre":[song objectAtIndex:8],@"year":@"",@"durationMillis":[song objectAtIndex:9],@"albumArtUrl":[song objectAtIndex:2]};
            }
            else
            {
                tempDict = @{@"id":[song objectAtIndex:0],@"title":[song objectAtIndex:1],@"artist":[song objectAtIndex:3],@"album":[song objectAtIndex:4],@"genre":@"",@"year":@"",@"durationMillis":[song objectAtIndex:9]};
            }
            [mSongArr addObject:tempDict];
        }
        NSLog(@"%lu songs loaded",(unsigned long)[mSongArr count]);
        
    }
    
}

- (NSMutableArray*) getSongs {
    return mSongArr;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString * cookie=[webView stringByEvaluatingJavaScriptFromString:@"document.cookie"];
    if (runCount < 1) {
        // Hah, thought changing the login method could stop me Google? Nope!
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByName('Passwd')[0].value = '%@';",passw]];
        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('signIn')[0].click();"];
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        //Nab the almighty xt cookie's data, it's important
        for (NSHTTPCookie *cookie in [cookieJar cookies])
        {
            
            if ([[cookie name] isEqualToString:@"xt"])
            {
                xtCookie = [cookie value];
            }
        }
        if (xtCookie)
        {
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://play.google.com/music/services/streamingloadalltracks?u=0&xt=%@==&format=jsarray",xtCookie]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            NSError *error;
            NSURLResponse *response;
            NSData *respon = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *mfinalResponse = [[NSString alloc] initWithData:respon encoding:NSUTF8StringEncoding];
            [self processSongs:mfinalResponse];
            runCount += 1;
        }
    }
}

@end
