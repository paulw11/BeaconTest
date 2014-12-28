//
//  IBTViewController.m
//  IBeaconTest
//
//  Created by Paul Wilkinson on 26/04/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import "IBTViewController.h"
#import "IBTAppDelegate.h"
#import "IBTBeaconTableViewCell.h"

@interface IBTViewController ()

@property (strong,nonatomic) CLBeaconRegion *beaconRegion;
@property (strong,nonatomic) NSMutableArray *regionArray;
@property (strong,nonatomic) NSMutableArray *beaconsArray;
@property (weak, nonatomic) IBOutlet UISwitch *regionMonitoringSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *regionRangingSwitch;
@property (strong,nonatomic) NSMutableDictionary *beaconDictionary;
@property (weak,nonatomic) IBOutlet UITableView *tableView;
@property (assign) CLRegionState prevState;
@property (strong,nonatomic) CLBeaconRegion *oldRegion;

@end

@implementation IBTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.regionArray=[NSMutableArray new];
    self.beaconsArray=[NSMutableArray new];
    self.prevState=CLRegionStateUnknown;
    self.beaconDictionary=[NSMutableDictionary new];
}

-(void) viewDidAppear:(BOOL)animated
{
    IBTAppDelegate *app=(IBTAppDelegate *)[UIApplication sharedApplication].delegate;
    if (app.locationManager != nil) {
        app.locationManager.delegate=self;
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kBeaconID];
        // Setup a new region with that UUID and same identifier as the broadcasting beacon
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                               identifier:@"me.wilko.beaconRegion"];
        self.beaconRegion.notifyEntryStateOnDisplay = YES;
        
        [self rangingSwitched:self.regionRangingSwitch];
        [self monitoringSwitched:self.regionMonitoringSwitch];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location monitoring not available" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)rangingSwitched:(UISwitch *)sender {
    IBTAppDelegate *app=(IBTAppDelegate *)[UIApplication sharedApplication].delegate;
    if (sender.isOn) {
        [app.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    else {
        [app.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
}

- (IBAction)monitoringSwitched:(UISwitch *)sender {
    IBTAppDelegate *app=(IBTAppDelegate *)[UIApplication sharedApplication].delegate;
    if (sender.isOn) {
        [app.locationManager startMonitoringForRegion:self.beaconRegion];
    }
    else {
        [app.locationManager stopMonitoringForRegion:self.beaconRegion];
    }
}

#pragma mark -
#pragma UITableViewDelegate



#pragma mark -
#pragma mark UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.regionArray.count;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *beaconArray=self.beaconsArray[section];
    return beaconArray.count;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CLBeaconRegion *region=self.regionArray[section];
    return region.identifier;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID=@"BeaconCell";
    IBTBeaconTableViewCell *cell = (IBTBeaconTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    NSArray *beaconArray=self.beaconsArray[indexPath.section];
    NSString *beaconID=(NSString *)beaconArray[indexPath.row];
    CLBeacon *beacon=(CLBeacon *)self.beaconDictionary[beaconID];
    cell.beaconLabel.text=beacon.proximityUUID.UUIDString;
    cell.beaconDetailLabel.text=[NSString stringWithFormat:@"Major %@ Minor %@",beacon.major,beacon.minor];
    NSString *proximity=@"";
    switch (beacon.proximity) {
        case CLProximityFar:
            proximity=@"Far";
            break;
        case CLProximityNear:
            proximity=@"Near";
            break;
        case CLProximityImmediate:
            proximity=@"Immediate";
            break;
        case CLProximityUnknown:
            break;
    }
    cell.proximityLabel.text=proximity;
    
    return cell;
    
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entered region %@",region.identifier);
    
    NSInteger regionIndex=[self.regionArray indexOfObject:region];
    
    if (regionIndex == NSNotFound) {
        NSMutableArray *beaconArray=[NSMutableArray new];
        [self.regionArray addObject:region];
        [self.beaconsArray addObject:beaconArray];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.regionArray.count-1] withRowAnimation:UITableViewRowAnimationAutomatic];
        if ([UIApplication sharedApplication].applicationState!=UIApplicationStateActive) {
            
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            if (localNotif == nil)
                return;
            localNotif.fireDate = nil;
            
            localNotif.alertBody = [NSString stringWithFormat:@"Entered region %@", region.identifier];
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
            
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exited region %@",region.identifier);
    NSInteger regionIndex=[self.regionArray indexOfObject:region];
    
    if (regionIndex != NSNotFound) {
        NSArray *beaconArray=self.beaconsArray[regionIndex];
        for (NSString *beaconID in beaconArray) {
            [self.beaconDictionary removeObjectForKey:beaconID];
        }
        [self.beaconsArray removeObjectAtIndex:regionIndex];
        [self.regionArray removeObjectAtIndex:regionIndex];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:regionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)locationManager:(CLLocationManager*)manager
didRangeBeacons:(NSArray*)beacons
inRegion:(CLBeaconRegion*)region
{
    NSInteger regionIndex=[self.regionArray indexOfObject:region];
    
    NSMutableArray *beaconArray=nil;
    
    [self.tableView beginUpdates];
    
    if (regionIndex == NSNotFound) {
        beaconArray=[NSMutableArray new];
        [self.regionArray addObject:region];
        [self.beaconsArray addObject:beaconArray];
        regionIndex=self.regionArray.count-1;
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:regionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        beaconArray=self.beaconsArray[regionIndex];
    }
    
    for (CLBeacon *beacon in beacons) {
        
        NSInteger beaconIndex=[beaconArray indexOfObject:beacon.proximityUUID.UUIDString];
    
        if (beaconIndex==NSNotFound) {
            [beaconArray addObject:beacon.proximityUUID.UUIDString];
            self.beaconDictionary[beacon.proximityUUID.UUIDString]= beacon;
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:beaconArray.count-1 inSection:regionIndex]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:beaconIndex inSection:regionIndex]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
    [self.tableView endUpdates];
    
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([UIApplication sharedApplication].applicationState!=UIApplicationStateActive) {
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        localNotif.fireDate = nil;
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        CLBeaconRegion *br=(CLBeaconRegion *)region;
        
        if(state == CLRegionStateInside) {
            NSLog(@"locationManager didDetermineState INSIDE for %@", region.identifier);
            localNotif.alertBody = [NSString stringWithFormat:@"locationManager didDetermineState INSIDE for %@", br.identifier];
        }
        else if(state == CLRegionStateOutside) {
            localNotif.alertBody = [NSString stringWithFormat:@"locationManager didDetermineState OUTSIDE for %@", br.identifier];
        }
        else {
            localNotif.alertBody = [NSString stringWithFormat:@"locationManager didDetermineState OTHER for %@", br.identifier];
        }
        if (self.prevState != state) {
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
        }
        
        self.prevState=state;
    }
    
}




@end
