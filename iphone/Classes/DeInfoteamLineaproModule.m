/**
 * TiLineaPro
 *
 * Created by Hans Knoechel
 * Copyright (c) 2015-2016 infoteam GmbH. All rights reserved.
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
	NSLog(@"[DEBUG] %@ loaded",self);
}

- (DTDevices*)lineaInstance
{
    if (!linea) {
        // Configure device
        linea = [DTDevices sharedDevice];
        [linea setDelegate:self];
        
        // Preconnect
        [self connect:nil];
        [self setPassThroughSync:@0];
    }
    
    return linea;
}

#pragma mark Public APIs

-(void)setPassThroughSync:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    
    NSError *error = nil;
    BOOL success = [[self lineaInstance] setPassThroughSync:[TiUtils boolValue:value] error:&error];
    
    if (success == NO) {
        NSLog(@"[ERROR] Ti.LineaPro: The pass-trough sync could not be set: %@", [TiUtils messageFromError:error]);
    }
}

- (NSNumber*)getPassThroughSync:(id)value
{
    ENSURE_SINGLE_ARG(value, NSNumber);
    ENSURE_UI_THREAD(getPassThroughSync, value);
    
    NSError *error = nil;
    BOOL success = [[self lineaInstance] getPassThroughSync:[TiUtils boolValue:value] error:&error];
    
    if (success == NO) {
        NSLog(@"[ERROR] Ti.LineaPro: The pass-trough sync could not be received: %@", [TiUtils messageFromError:error]);
    }

    return NUMBOOL(success);
}

- (NSNumber*)isPresent:(id)unused
{
    return NUMBOOL([[self lineaInstance] isPresent:[self barcodeScanMode]]);
}

- (void)connect:(id)unused
{
    [[self lineaInstance] connect];
}

- (void)disconnect:(id)unused
{
    [[self lineaInstance] disconnect];
}

- (void)startScanner:(id)unused
{
    ENSURE_UI_THREAD(startScanner, unused);
    
    NSError* error = nil;
    BOOL success = [[self lineaInstance] barcodeStartScan:&error];
    
    if (success == NO) {
        NSLog(@"[ERROR] TiLineaPro: Scanner could not be started: %@", [TiUtils messageFromError:error]);
    }
}

- (void)stopScanner:(id)unused
{
    ENSURE_UI_THREAD(stopScanner, unused);
    
    NSError* error = nil;
    BOOL success = [[self lineaInstance] barcodeStopScan:&error];
    
    if (success == NO) {
        NSLog(@"[ERROR] TiLineaPro: Scanner could not be stopped: %@", [TiUtils messageFromError:error]);
    }
}

- (void)playSound:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    ENSURE_UI_THREAD(playSound, args);

    NSError *error = nil;
    NSNumber *volume;
    
    ENSURE_ARG_OR_NIL_FOR_KEY(volume, args, @"volume", NSNumber);

    int *data = [DeInfoteamLineaproModule integerArrayFromNative:[args objectForKey:@"data"]];
    
    BOOL success = [[self lineaInstance] playSound:[TiUtils doubleValue:volume def:50]
                                          beepData:data
                                            length:sizeof(data)
                                             error:&error];
    
    if (!success) {
        NSLog(@"[ERROR] TiLineaPro: Sound could not be played: %@", [TiUtils messageFromError:error]);
    }
}

- (void)configureScanBeep:(id)args
{
    ENSURE_SINGLE_ARG(args, NSArray);
    ENSURE_UI_THREAD(configureScanBeep, args);

    NSNumber *enabled;
    NSNumber *volume;
    NSArray *data;
    NSError *error = nil;

    ENSURE_ARG_FOR_KEY(enabled, args, @"enabled", NSNumber);
    ENSURE_ARG_OR_NIL_FOR_KEY(volume, args, @"volume", NSNumber);
    ENSURE_ARG_OR_NIL_FOR_KEY(data, args, @"data", NSArray);
    
    int *beepData = [DeInfoteamLineaproModule integerArrayFromNative:[args objectForKey:@"data"]];

    BOOL success = [[self lineaInstance] barcodeSetScanBeep:[TiUtils boolValue:enabled def:YES]
                                                     volume:[TiUtils doubleValue:volume def:50]
                                                   beepData:beepData
                                                     length:sizeof(beepData)
                                                      error:&error];
    
    if (!success) {
        NSLog(@"[ERROR] TiLineaPro: Scan beep could not be configured: %@",[TiUtils messageFromError:error]);
    }
}

-(int)batteryCapacity
{
    NSError* error = nil;
    DTBatteryInfo *info = [[self lineaInstance] getBatteryInfo:&error];
    
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
    BOOL success = [[self lineaInstance] getCharging:&chargingValue
                                               error:nil];
    
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
    BOOL success = [[self lineaInstance] setCharging:chargingValue
                                               error:nil];
    
    [charging release];
    
    if (success == NO) {
        NSLog(@"[ERROR] TiLineaPro: Charging could not be set.");
    }
}

- (int)barcodeScanMode
{
    __block NSError *error = nil;
    __block int mode = MODE_SINGLE_SCAN;
    __block BOOL success = NO;
    
    TiThreadPerformOnMainThread(^{
        success = [[self lineaInstance] barcodeGetScanMode:&mode
                                                     error:&error];
    }, YES);
    
    if (success == YES) {
        return mode;
    } else {
        NSLog(@"[ERROR] TiLineaPro: Barcode scan mode could not be determined: %@", [TiUtils messageFromError:error]);
        return -1;
    }
}
- (void)setBarcodeScanMode:(id)mode
{
    ENSURE_UI_THREAD(setBarcodeScanMode,mode);
    
    NSError* error = nil;
    BOOL success = [[self lineaInstance] barcodeSetScanMode:[TiUtils intValue:mode]
                                                      error:&error];
    
    if (success == NO) {
        NSLog(@"[ERROR] TiLineaPro: Barcode could not be set: %@", [TiUtils messageFromError:error]);
    }
}

- (NSDictionary*)firmwareInformation
{
    return @{
        @"firmwareRevision": [[self lineaInstance] firmwareRevision],
        @"firmwareRevisionNumber": NUMINT([[self lineaInstance] firmwareRevisionNumber]),
        @"devicModel": [[self lineaInstance] deviceModel],
        @"deviceName": [[self lineaInstance] deviceName]
    };
}

#pragma mark API Delegates

- (void)connectionState:(int)state
{
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
    
    if ([self _hasListeners:@"barcodeScanned"]) {
        [self fireEvent:@"barcodeScanned" withObject:@{
            @"barcode": barcode,
            @"barcodeType": NUMINT(type),
            @"barcodeTypeAsText": [[self lineaInstance] barcodeType2Text:type]
        }];
    }
}

+ (int*)integerArrayFromNative:(NSArray*)arr
{
    if (!arr || arr && [arr count] == 0) {
        int data[] = {2200, 150, 2770, 150};
        return *data;
    }

    int data[] = {};
  
    for (id beep in arr) {
        ENSURE_TYPE(beep, NSNumber);
        data[[arr indexOfObject:beep]] = NUMINT(beep);
    }
    
    return *data;
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
