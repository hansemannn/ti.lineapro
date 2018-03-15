/**
 * TiLineaPro
 *
 * Created by Hans Knoechel
 * Copyright (c) 2015-present infoteam GmbH. All rights reserved.
 */

#import "DTDevices.h"
#import "EMVPrivateTags.h"
#import "EMVTags.h"
#import "TiModule.h"

@interface DeInfoteamLineaproModule : TiModule {
  DTDevices *_linea;
}

- (NSDictionary *)firmwareInformation;

- (id)batteryCapacity;

- (id)charging;

- (void)setCharging:(id)charging;

- (void)setAutoOffWhenIdle:(id)args;

- (id)barcodeScanMode;

- (void)setBarcodeScanMode:(id)mode;

- (id)passThroughSync;

- (void)setPassThroughSync:(id)value;

- (id)isPresent:(id)unused;

- (void)connect:(id)unused;

- (void)disconnect:(id)unused;

- (void)startScanner:(id)unused;

- (void)stopScanner:(id)unused;

- (void)playSound:(id)args;

- (void)configureScanBeep:(id)args;

@end
