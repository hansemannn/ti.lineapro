/**
 * TiLineaPro
 *
 * Created by Hans Knoechel
 * Copyright (c) 2015-present infoteam GmbH. All rights reserved.
 */

#import "DeInfoteamLineaproModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import <KrollMethod.h>

@implementation DeInfoteamLineaproModule

#define DEFAULT_BEEP     \
  {                      \
    2200, 150, 2770, 150 \
  }

#pragma mark Internal

- (id)moduleGUID
{
  return @"df751577-610c-4379-9c2d-3609baf58835";
}

- (NSString *)moduleId
{
  return @"de.infoteam.lineapro";
}

#pragma mark Lifecycle

- (void)startup
{
  [super startup];
  NSLog(@"[DEBUG] %@ loaded", self);
}

- (DTDevices *)lineaInstance
{
  if (!_linea) {
    // Configure device
    _linea = [DTDevices sharedDevice];
    [_linea setDelegate:self];
  }

  return _linea;
}

#pragma mark Public APIs

- (void)setPassThroughSync:(id)value
{
  ENSURE_TYPE(value, NSNumber);

  NSError *error = nil;
  BOOL success = [[self lineaInstance] setPassThroughSync:[TiUtils boolValue:value] error:&error];

  if (success == NO) {
    NSLog(@"[ERROR] Ti.LineaPro: The pass-trough sync could not be set: %@", [TiUtils messageFromError:error]);
  }
}

- (NSNumber *)passThroughSync
{
  NSError *error = nil;
  BOOL enabled = NO;
  BOOL success = [[self lineaInstance] getPassThroughSync:&enabled error:&error];

  if (success == NO) {
    NSLog(@"[ERROR] Ti.LineaPro: The pass-trough sync could not be received: %@", [TiUtils messageFromError:error]);
  }

  return NUMBOOL(enabled);
}

- (id)isPresent:(id)unused
{
  return NUMBOOL([(DTDevices *)[self lineaInstance] isPresent:[TiUtils intValue:[self barcodeScanMode]]]);
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

  NSError *error = nil;
  BOOL success = [[self lineaInstance] barcodeStartScan:&error];

  if (success == NO) {
    NSLog(@"[ERROR] TiLineaPro: Scanner could not be started: %@", [TiUtils messageFromError:error]);
  }
}

- (void)stopScanner:(id)unused
{
  ENSURE_UI_THREAD(stopScanner, unused);

  NSError *error = nil;
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
  NSArray *data;

  ENSURE_ARG_OR_NIL_FOR_KEY(volume, args, @"volume", NSNumber);
  ENSURE_ARG_OR_NIL_FOR_KEY(data, args, @"data", NSArray);

  // Copy Obj-C NSArray to int[]
  // TODO: Move to own utility
  const int count = data ? (int)[data count] : 0;
  int *beepData = NULL;
  beepData = new int[count];
  int defaultBeepData[4] = DEFAULT_BEEP;

  for (int i = 0; i < count; ++i) {
    beepData[i] = [[data objectAtIndex:i] intValue];
  }

  // If there is no data, we re-assign it
  if (count == 0) {
    delete[] beepData;
  }

  BOOL success = [[self lineaInstance] playSound:[TiUtils doubleValue:volume def:50]
                                        beepData:count == 0 ? defaultBeepData : beepData
                                          length:sizeof(beepData)
                                           error:&error];

  if (!success) {
    NSLog(@"[ERROR] TiLineaPro: Sound could not be played: %@", [TiUtils messageFromError:error]);
  }
}

- (void)configureScanBeep:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);
  ENSURE_UI_THREAD(configureScanBeep, args);

  NSError *error = nil;
  NSNumber *enabled;
  NSNumber *volume;
  NSArray *data;

  ENSURE_ARG_FOR_KEY(enabled, args, @"enabled", NSNumber);
  ENSURE_ARG_OR_NIL_FOR_KEY(volume, args, @"volume", NSNumber);
  ENSURE_ARG_OR_NIL_FOR_KEY(data, args, @"data", NSArray);

  // Copy Obj-C NSArray to int[]
  // TODO: Move to own utility
  const int count = data ? (int)[data count] : 0;
  int *beepData = NULL;
  beepData = new int[count];
  int defaultBeepData[4] = DEFAULT_BEEP;

  for (int i = 0; i < count; ++i) {
    beepData[i] = [[data objectAtIndex:i] intValue];
  }

  // If there is no data, we re-assign it
  if (count == 0) {
    delete[] beepData;
  }

  BOOL success = [[self lineaInstance] barcodeSetScanBeep:[TiUtils boolValue:enabled def:YES]
                                                   volume:[TiUtils doubleValue:volume def:50]
                                                 beepData:count == 0 ? defaultBeepData : beepData
                                                   length:sizeof(beepData)
                                                    error:&error];

  if (!success) {
    NSLog(@"[ERROR] TiLineaPro: Scan beep could not be configured: %@", [error localizedDescription]);
  }
}

- (id)batteryCapacity
{
  NSError *error = nil;
  DTBatteryInfo *info = [[self lineaInstance] getBatteryInfo:&error];

  if (info != nil) {
    return @([info capacity]);
  } else {
    NSLog(@"[ERROR] TiLineaPro: Unable to get battery capacity: %@", [TiUtils messageFromError:error]);
    return @(-1);
  }
}

- (NSNumber *)charging
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

  NSError *error = nil;

  BOOL chargingValue = [TiUtils boolValue:charging def:NO];
  BOOL success = [[self lineaInstance] setCharging:chargingValue
                                             error:&error];

  if (success == NO) {
    NSLog(@"[ERROR] TiLineaPro: Charging could not be set: %@", [error localizedDescription]);
  }
}

- (id)barcodeScanMode
{
  __block NSError *error = nil;
  __block int mode = MODE_SINGLE_SCAN;
  __block BOOL success = NO;

  TiThreadPerformOnMainThread(^{
    success = [[self lineaInstance] barcodeGetScanMode:&mode
                                                 error:&error];
  },
      YES);

  if (success == YES) {
    return @(mode);
  } else {
    NSLog(@"[ERROR] TiLineaPro: Barcode scan mode could not be determined.");
    return @(-1);
  }
}
- (void)setBarcodeScanMode:(id)mode
{
  ENSURE_UI_THREAD(setBarcodeScanMode, mode);

  NSError *error = nil;
  BOOL success = [[self lineaInstance] barcodeSetScanMode:[TiUtils intValue:mode]
                                                    error:&error];

  if (success == NO) {
    NSLog(@"[ERROR] TiLineaPro: Barcode could not be set: %@", [TiUtils messageFromError:error]);
  }
}

- (id)firmwareInformation
{
  return @{
    @"firmwareRevision" : [[self lineaInstance] firmwareRevision] ?: [NSNull null],
    @"firmwareRevisionNumber" : @([[self lineaInstance] firmwareRevisionNumber]),
    @"devicModel" : [[self lineaInstance] deviceModel] ?: [NSNull null],
    @"deviceName" : [[self lineaInstance] deviceName] ?: [NSNull null]
  };
}

#pragma mark API Delegates

- (void)connectionState:(int)state
{
  NSString *type = nil;

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
    [self fireEvent:@"connectionStateChanged" withObject:@{ @"state" : @(state),
      @"description" : type }];
  }
}

- (void)barcodeData:(NSString *)barcode type:(int)type
{
  NSLog(@"[DEBUG] TiLineaPro: Barcode is: %@", barcode);

  if ([self _hasListeners:@"barcodeScanned"]) {
    [self fireEvent:@"barcodeScanned"
         withObject:@{
           @"barcode" : barcode,
           @"barcodeType" : @(type),
           @"barcodeTypeAsText" : [[self lineaInstance] barcodeType2Text:type]
         }];
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
