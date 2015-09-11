/**
 * TiLineaPro
 *
 * Created by Hans Knoechel
 * Copyright (c) 2015 infoteam GmbH. All rights reserved.
 */

#import "TiModule.h"
#import "DTDevices.h"
#import "EMVTags.h"
#import "EMVPrivateTags.h"

@interface DeInfoteamLineaproModule : TiModule
{
    NSString *current_barcode;
    NSString *current_tracks;
    
    DTDevices *linea;
}

- (NSDictionary*) firmwareInformation;
- (int) batteryCapacity;

- (BOOL) charging;
- (void) setCharging: (id) charging;

- (int) barcodeScanMode;
- (void) setBarcodeScanMode: (id) mode;

@end
