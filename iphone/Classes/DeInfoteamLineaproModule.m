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
    [linea setDelegate:self];

    [self connect:nil];
    [self setPassThroughSync:0];
    
	NSLog(@"[INFO] %@ loaded",self);
}

#pragma mark Public APIs

-(void)setPassThroughSync:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    
    NSError *error = nil;
    BOOL success = [linea setPassThroughSync:[TiUtils boolValue:value] error:&error];
    
    if (success == NO) {
        NSLog(@"[ERROR] Ti.LineaPro: The pass-trough sync could not be set: %@", [TiUtils messageFromError:error]);
    }
}

- (NSNumber*)getPassThroughSync:(id)arg
{
    ENSURE_TYPE(arg, NSArray);
    
    id value = [arg objectAtIndex:0];
    ENSURE_TYPE(value, NSNumber);
    
    NSError *error = nil;
    BOOL success = [linea getPassThroughSync:[TiUtils boolValue:value] error:&error];
    
    if (success == NO) {
        NSLog(@"[ERROR] Ti.LineaPro: The pass-trough sync could not be received: %@", [TiUtils messageFromError:error]);
    }

    return NUMBOOL(success);
}

- (NSNumber*)isPresent:(id)unused
{
    return NUMBOOL([linea isPresent:[self barcodeScanMode]]);
}

- (void)connect:(id)unused
{
    [linea connect];
}

- (void)disconnect:(id)unused
{
    [linea disconnect];
}

- (void)startScanner:(id)unused
{
    ENSURE_UI_THREAD(startScanner, unused);
    
    NSError* error = nil;
    BOOL success = [linea barcodeStartScan:&error];
    
    if (success == NO) {
        NSLog(@"[ERROR] TiLineaPro: Scanner could not be started: %@",[TiUtils messageFromError:error]);
    }
}

- (void)stopScanner:(id)unused
{
    ENSURE_UI_THREAD(stopScanner, unused);
    
    NSError* error = nil;
    BOOL success = [linea barcodeStopScan:&error];
    
    if (success == NO) {
        NSLog(@"[ERROR] TiLineaPro: Scanner could not be stopped: %@",[TiUtils messageFromError:error]);
    }
}

-(int)batteryCapacity
{
    NSError* error = nil;
    DTBatteryInfo *info = [linea getBatteryInfo:&error];
    
    if (info != nil) {
        return [info capacity];
    } else {
        NSLog(@"[ERROR] TiLineaPro: Unable to get battery capacity: %@", [TiUtils messageFromError:error]);
        return -1;
    }
}

- (NSNumber*)charging
{
    BOOL chargingValue = NO;
    BOOL success = [linea getCharging:&chargingValue error:nil];
    
    if (success == YES) {
        return NUMBOOL(chargingValue);
    } else {
        return NUMBOOL(NO);
    }
}

- (void)setCharging:(id)charging
{
    ENSURE_UI_THREAD(setCharging, charging);
    
    [charging retain];
    
    BOOL chargingValue = [TiUtils boolValue:charging def:NO];
    BOOL success = [linea setCharging:chargingValue error:nil];
    
    [charging release];
    
    if (success == NO) {
        NSLog(@"[ERROR] TiLineaPro: Charging could not be set.");
    }
}

- (int)barcodeScanMode
{
    int mode = MODE_SINGLE_SCAN;
    NSError *error = nil;
    
    BOOL success = [linea barcodeGetScanMode:&mode error:&error];
    
    if (success == YES) {
        return mode;
    } else {
        NSLog(@"[ERROR] TiLineaPro: Barcode scan mode could not be determined: %@",[TiUtils messageFromError:error]);
        return -1;
    }
}
- (void)setBarcodeScanMode:(id)mode
{
    ENSURE_UI_THREAD(setBarcodeScanMode,mode);
    
    NSError* error = nil;
    BOOL success = [linea barcodeSetScanMode:[TiUtils intValue:mode] error:&error];
    
    if (success == NO) {
        NSLog(@"[ERROR] TiLineaPro: Barcode could not be set: %@",[TiUtils messageFromError:error]);
    }
}

- (NSDictionary*)firmwareInformation
{
    return @{
        @"firmwareRevision": [linea firmwareRevision],
        @"firmwareRevisionNumber": NUMINT([linea firmwareRevisionNumber]),
        @"devicModel": [linea deviceModel],
        @"deviceName": [linea deviceName]
    };
}

#pragma mark API Delegates

- (void)connectionState:(int)state
{
    int beepData[] = {2200, 150, 2770, 150};
    NSString* type = nil;
    
    switch (state) {
        case CONN_DISCONNECTED:
            type = @"disconnected";
            NSLog(@"[DEBUG] TiLineaPro: ConnectionState = DISCONNECTED");
            break;
        case CONN_CONNECTING:
            type = @"connecting";
            NSLog(@"[DEBUG] TiLineaPro: ConnectionState = CONNECTING");
            break;
        case CONN_CONNECTED:
            type = @"connected";
            NSLog(@"[DEBUG] TiLineaPro: ConnectionState = CONNECTED");
            [linea barcodeSetScanBeep:YES volume:50 beepData:beepData length:sizeof(beepData) error:nil];
            break;
        default:
            type = @"undefined";
            NSLog(@"[ERROR] TiLineaPro: ConnectionState could not be determined!");
            break;
    }
    
    if ([self _hasListeners:@"connectionStateChanged"]) {
        [self fireEvent:@"connectionStateChanged" withObject:@{@"state": NUMINT(state), @"description": type}];
    }
}

- (void)barcodeData:(NSString*)barcode type:(int)type
{
    NSLog(@"[DEBUG] TiLineaPro: Barcode is: %@",barcode);
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                           barcode,@"barcode",
                           [NSString stringWithFormat:@"%d", type],@"barcodeType",
                           [linea barcodeType2Text:type],@"barcodeTypeAsText",
                           nil];
    
    if ([self _hasListeners:@"barcodeScanned"]) {
        [self fireEvent:@"barcodeScanned" withObject:event];
    }
}

MAKE_SYSTEM_PROP(MODE_SINGLE_SCAN, MODE_SINGLE_SCAN);
MAKE_SYSTEM_PROP(MODE_SINGLE_SCAN_RELEASE, MODE_SINGLE_SCAN_RELEASE);
MAKE_SYSTEM_PROP(MODE_MULTI_SCAN, MODE_MULTI_SCAN);
MAKE_SYSTEM_PROP(MODE_MULTI_SCAN_NO_DUPLICATES, MODE_MULTI_SCAN_NO_DUPLICATES);
MAKE_SYSTEM_PROP(MODE_MOTION_DETECT, MODE_MOTION_DETECT);

MAKE_SYSTEM_PROP(CONNECTION_STATE_CONNECTED, CONN_CONNECTED);
MAKE_SYSTEM_PROP(CONNECTION_STATE_CONNECTING, CONN_CONNECTING);
MAKE_SYSTEM_PROP(CONNECTION_STATE_DISCONNECTED, CONN_DISCONNECTED);

@end
