//
//  IBTBeaconTableViewCell.h
//  IBeaconTest
//
//  Created by Paul Wilkinson on 28/12/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IBTBeaconTableViewCell : UITableViewCell

@property (weak,nonatomic) IBOutlet UILabel *beaconLabel;
@property (weak,nonatomic) IBOutlet UILabel *beaconDetailLabel;
@property (weak,nonatomic) IBOutlet UILabel *proximityLabel;

@end
