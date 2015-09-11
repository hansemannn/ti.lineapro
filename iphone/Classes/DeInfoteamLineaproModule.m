/**
 * TiLineaPro
 *
 * Created by Hans Knoechel
 * Copyright (c) 2015 infoteam GmbH. All rights reserved.
 */

#import "DeInfoteamLineaproModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import <KrollMethod.h>

@implementation DeInfoteamLineaproModule

#pragma mark Internal

-(id)moduleGUID
{
	return @"df751577-610c-4379-9c2d-3609baf58835";
}

-(NSString*)moduleId
{
	return @"de.infoteam.lineapro";
}

#pragma mark Lifecycle

-(void)startup
{
	[super startup];

    linea = [DTDevices sharedDevice];
    [linea addDelegate:self];
    [linea connect];

    [linea setPassThroughSync:false error:nil];
    
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma mark Public APIs

-(int)batteryCapacity
{
    DTBatteryInfo *info = [linea getBatteryInfo:nil];
    
    if(info) {
        return [info capacity];
    } else {
        NSLog(@"[LINEA] Unable to get battery capacity!!");
        return -1;
    }
}

-(BOOL)charging
{
    BOOL chargingValue;
    BOOL success = [linea getCharging:&chargingValue error:nil];
    
    if(success) {
        return chargingValue;
    } else {
        return NO;
    }
}

-(void)setCharging:(id)charging
{
    ENSURE_UI_THREAD_1_ARG(charging);
    
    [charging retain];
    
    BOOL chargingValue = [TiUtils boolValue:charging def:NO];
    BOOL success = [linea setCharging:chargingValue error:nil];
    
    [charging release];
    
    if(success == NO) {
        NSLog(@"[LINEA] Charging could not be set.");
    }
}

- (int)barcodeScanMode
{
    int mode = MODE_SINGLE_SCAN;
    BOOL success = [linea barcodeGetScanMode:&mode error:nil];
    
    if(success == YES) {
        return mode;
    } else {
        return -1;
    }
}
- (void)setBarcodeScanMode: (id) mode
{
    ENSURE_UI_THREAD_1_ARG(mode);
    
    NSError* error = nil;
    BOOL success = [linea barcodeSetScanMode:[TiUtils intValue:mode] error:&error];
    
    if(success == NO) {
        NSLog(@"[ERROR] Barcode could not be set: %s",[TiUtils messageFromError:error]);
    }
}

-(NSDictionary*)firmwareInformation
{
    NSDictionary* infos = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [linea firmwareRevision],@"firmwareRevision",
                                   [NSString stringWithFormat:@"%d", [linea firmwareRevisionNumber]],@"firmwareRevisionNumber",
                                   [linea deviceModel],@"deviceModel",
                                   [linea deviceName],@"deviceName",
                                   nil];
    
    return infos;
}

#pragma mark API Delegates

-(void)connectionState:(int)state
{
    int beepData[] = {2200, 150, 2770, 150};
    NSString* type;
    
    switch (state) {
        case CONN_DISCONNECTED:
            type = @"disconnected";
            NSLog(@"[LINEA] Linea connectionState = DISCONNECTED");
            break;
        case CONN_CONNECTING:
            type = @"connecting";
            NSLog(@"[LINEA] Linea connectionState = CONNECTING");
            break;
        case CONN_CONNECTED:
            type = @"connected";
            NSLog(@"[LINEA] Linea connectionState = CONNECTED");
            [linea barcodeSetScanBeep:YES volume:50 beepData:beepData length:sizeof(beepData) error:nil];
            break;
    }
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys: type, @"state", nil];

    if([self _hasListeners:@"connectionStateChanged"]) {
        [self fireEvent:@"connectionStateChanged" withObject:event];
    }
}

-(void)barcodeData:(NSString*)barcode type:(int)type
{
    NSLog(@"[LINEA] Linea barcodeData");
    NSLog(@"[INFO] barcode is: %@",barcode);
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                           barcode,@"barcode",
                           [NSString stringWithFormat:@"%d", type],@"barcodeType",
                           [linea barcodeType2Text:type],@"barcodeTypeAsText",
                           nil];
    
    if([self _hasListeners:@"barcodeScanned"]) {
        [self fireEvent:@"barcodeScanned" withObject:event];
    }
}

MAKE_SYSTEM_PROP(MODE_SINGLE_SCAN, MODE_SINGLE_SCAN);
MAKE_SYSTEM_PROP(MODE_SINGLE_SCAN_RELEASE, MODE_SINGLE_SCAN_RELEASE);
MAKE_SYSTEM_PROP(MODE_MULTI_SCAN, MODE_MULTI_SCAN);
MAKE_SYSTEM_PROP(MODE_MULTI_SCAN_NO_DUPLICATES, MODE_MULTI_SCAN_NO_DUPLICATES);
MAKE_SYSTEM_PROP(MODE_MOTION_DETECT, MODE_MOTION_DETECT);

@end
