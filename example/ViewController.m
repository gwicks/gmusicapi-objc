//
//  ViewController.m
//  GoogleMusic
//
//  Created by Wicks, Gregory on 7/23/15.
//  Copyright (c) 2015 Wicks, Gregory. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIAlertView *loginView = [[UIAlertView alloc] initWithTitle:@"Log In" message:@"Log in to Google Play" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Log In", nil];
    loginView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [loginView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) processSongs:(NSString*) data {
    [super processSongs:data];
    NSMutableArray *currentSongs = [self getSongs];
    NSLog(@"%@", currentSongs);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *uname = [[alertView textFieldAtIndex:0] text];
        NSString *pass = [[alertView textFieldAtIndex:1] text];
        
        [self loginWithUsername:uname withPassword:pass];
    }
}



@end
