//
//  ViewController.m
//  wAC
//
//  Created by W. Aaron Waychoff on 7/22/15.
//  Copyright (c) 2015 W. Aaron Waychoff. All rights reserved.
//

#import "ViewController.h"
#import "Spark-SDK.h"

//#define nologin 1

#define default_threshold 800
#define loopMax 20

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *windSpeed;
@property (nonatomic, strong) SparkDevice *myPhoton;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (strong, nonatomic) UIColor *onColor;
@property (strong, nonatomic) UIColor *offColor;
@property (nonatomic, assign) BOOL isOn;
@property (strong, nonatomic) NSNumber *lastReading;
@property (strong, nonatomic) NSNumber *currentReading;
@property (strong, nonatomic) UIView *animatedView;
@property (nonatomic, assign) BOOL isAnimating;
@property (strong, nonatomic) NSTimer *speedChecker;
@property (strong, nonatomic) NSTimer *incrementalChecker;
@property (nonatomic, assign) BOOL desiredToggleState;
@property (nonatomic, assign) int loopCounter;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (nonatomic, assign) BOOL firstUpdate;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *bringToFront;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (assign, nonatomic) NSInteger threshold;
@property (assign, nonatomic) NSString *deviceName;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Set up some UI stuff
    self.firstUpdate = YES;
    self.isOn = NO;
    self.isAnimating = NO;
    self.onColor = [UIColor colorWithRed:124.0/255.0 green:214.0/255.0 blue:252.0/255.0 alpha:1.0];
    self.offColor = [UIColor colorWithRed:252.0/255.0 green:124.0/255.0 blue:124.0/255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.toggleButton.layer.cornerRadius = self.toggleButton.frame.size.width/2;
    self.toggleButton.clipsToBounds = YES;
    self.toggleButton.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
    [self.toggleButton setTitle:@"" forState:UIControlStateNormal];
    
    //load settings
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.username = [standardUserDefaults objectForKey:@"username"];
    self.password = [standardUserDefaults objectForKey:@"password"];
    self.deviceName = [standardUserDefaults objectForKey:@"device"];
    NSString *tempVal = [standardUserDefaults objectForKey:@"threshold"];
    self.threshold = [tempVal integerValue];
    if (self.threshold == 0)
    {
        self.threshold = default_threshold;
    }
    
    //Check that required settings have been defined
    if ([self.username isEqualToString:@""] || [self.password isEqualToString:@""]||[self.deviceName isEqualToString:@""] ) {
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Check Settings" message:@"Not all required settings have been defined. Please visit the iOS Settings to correct." preferredStyle:UIAlertControllerStyleAlert];
        
        //This really needs to actually do something, like re-check settings
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alertVC addAction:defaultAction];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }

    
#ifndef nologin
    [[SparkCloud sharedInstance] loginWithUser:self.username password:self.password completion:^(NSError *error) {
        if (!error)
            NSLog(@"Logged in to cloud");
        else
            NSLog(@"Wrong credentials or no internet connectivity, please try again");
    }];
    
    
    [[SparkCloud sharedInstance] getDevices:^(NSArray *sparkDevices, NSError *error) {
        NSLog(@"%@",sparkDevices.description); // print all devices claimed to user
        
        // search for a specific device by name
        for (SparkDevice *device in sparkDevices)
        {
            NSLog(@"Device: %@\r\n",device.name);
            
            if ([device.name isEqualToString:self.deviceName])
                self.myPhoton = device;
        }
    }];
    
    
#else
    [self startAnimating];
#endif
    

    if (!self.myPhoton) {
        self.windSpeed.text = @"---";
    }


    [self startIncrementalTimer];
    
}

-(void)setMyPhoton:(SparkDevice *)myPhoton
{
    _myPhoton = myPhoton;
    [self refreshButtonPressed:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)toggleButtonPressed:(id)sender {
    
    if (self.myPhoton) {
        self.desiredToggleState = !self.isOn;
        [self startAnimating];
        [self.myPhoton callFunction:@"toggle" withArguments:nil completion:^(NSNumber *resultCode, NSError *error) {
        if (!error)
        {
            NSLog(@"Toggle sent");
        }
    }];
    }
}
- (IBAction)refreshButtonPressed:(id)sender {
    
    
    // reading a variable
    if (self.myPhoton) {

    [self.myPhoton getVariable:@"windValue" completion:^(id result, NSError *error) {
        if (!error)
        {
            self.lastReading = self.currentReading;
            self.currentReading = (NSNumber *)result;
            NSLog(@"Wind sensor reading %f degrees",self.currentReading.floatValue);


            [self updatedSpeed];
        }
        else
        {
            NSLog(@"Failed reading speed from Photon device");
            self.windSpeed.text = @"---";

        }
    }];
    }
}

-(void) updatedSpeed
{
    self.windSpeed.text = [self.currentReading stringValue];
    BOOL prev = self.isOn;
    if (self.currentReading.integerValue > self.threshold) {
        self.isOn = YES;
    }
    else
    {
        self.isOn = NO;
    }
    if ((!prev==self.isOn && !self.isAnimating) || self.firstUpdate) {
        UIColor *destColor = self.offColor;
        self.firstUpdate = NO;
        if (self.isOn) {
            destColor = self.onColor;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.view.backgroundColor = destColor;
        }];

    }
}

-(void)startAnimating
{
    self.loopCounter = 0;
    self.animatedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];

    if (self.isOn) {
        self.animatedView.backgroundColor = self.offColor;
    } else{
        self.animatedView.backgroundColor = self.onColor;
    }
    self.speedChecker = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshButtonPressed:) userInfo:nil repeats:YES];
    self.isAnimating = YES;

    self.animatedView.bounds = CGRectMake(0, 0, 20, 20);
    self.animatedView.center = self.toggleButton.center;
    self.animatedView.layer.cornerRadius = self.animatedView.frame.size.height/2;
    self.animatedView.clipsToBounds = YES;
    [self.view addSubview:self.animatedView];
    for (UIView *aView in self.bringToFront) {
        [self.view bringSubviewToFront:aView];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.animatedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 5, 5);


    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            self.animatedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 5.2, 5.2);

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.animatedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 5, 5);

            } completion:^(BOOL finished) {
                [self updateAnimation];
            }];
        }];
    }];
}

-(void)updateAnimation
{
    BOOL breakBool = self.desiredToggleState;
    self.loopCounter++;
    if (self.loopCounter > loopMax) {
        [self stopAnimating];
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.animatedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 5.2, 5.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.animatedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 5.0, 5.0);

        } completion:^(BOOL finished) {
            if (self.isOn == breakBool) {
                [self stopAnimating];
            } else {
                [self updateAnimation];
            }
        }];
    }];

}

-(void)stopAnimating
{
    [self.speedChecker invalidate];
    [self.view bringSubviewToFront:self.toggleButton];
    [UIView animateWithDuration:0.5 animations:^{
        self.animatedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 50, 50);

    } completion:^(BOOL finished) {
        self.isAnimating = NO;

        if (self.isOn) {
            self.view.backgroundColor = self.onColor;
        }
        else {
            self.view.backgroundColor = self.offColor;
        }
        [self.animatedView removeFromSuperview];
    }];

    
}
-(void)startIncrementalTimer
{
    self.incrementalChecker = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refreshButtonPressed:) userInfo:nil repeats:YES];
}

-(void)goingInactive
{
    [self.incrementalChecker invalidate];
}

-(void)comingBack
{
    [self startIncrementalTimer];
}

@end
