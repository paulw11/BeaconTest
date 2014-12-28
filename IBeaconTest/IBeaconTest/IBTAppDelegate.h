//
//  IBTAppDelegate.h
//  IBeaconTest
//
//  Created by Paul Wilkinson on 26/04/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface IBTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
