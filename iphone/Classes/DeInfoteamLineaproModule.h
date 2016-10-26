/**
 * TiLineaPro
 *
 * Created by Hans Knoechel
 * Copyright (c) 2015-2016 infoteam GmbH. All rights reserved.
 */

#import "TiModule.h"
#import "DTDevices.h"
#import "EMVTags.h"
#import "EMVPrivateTags.h"

@interface DeInfoteamLineaproModule : TiModule
{
    DTDevices *linea;
}

- (NSDictionary*)firmwareInformation;

- (id)batteryCapacity;

- (id)charging;

- (void)setCharging:(id)charging;

- (id)barcodeScanMode;

- (void)setBarcodeScanMode:(id)mode;

- (void)setPassThroughSync:(id)value;

- (id)getPassThroughSync:(id)value;

- (id)isPresent:(id)unused;

- (void)connect:(id)unused;

- (void)disconnect:(id)unused;

- (void)startScanner:(id)unused;

- (void)stopScanner:(id)unused;

- (void)playSound:(id)args;

- (void)configureScanBeep:(id)args;

@end
