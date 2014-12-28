//
//  IBTViewController.h
//  IBeaconTest
//
//  Created by Paul Wilkinson on 26/04/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kBeaconID @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"

@interface IBTViewController : UIViewController <CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate>


@end
