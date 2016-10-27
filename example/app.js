/*
 * In order to communicate with the scanner, make sure to add the following
 * lines into the <ios> section of your tiapp.xml or in your custom Info.plist.

		<key>UISupportedExternalAccessoryProtocols</key>
	  <array>
	      <string>com.datecs.linea.pro.msr</string>
	      <string>com.datecs.linea.pro.bar</string>
	  </array>
		
 */

 var linea = require("de.infoteam.lineapro");
 var currentState = linea.CONNECTION_STATE_DISCONNECTED;

 linea.addEventListener("barcodeScanned", onScannedBarcode);
 linea.addEventListener("connectionStateChanged", onConnectionStateChange);

 initializeConnection();

 function initializeConnection() {
 	linea.connect();
 	linea.setPassThroughSync(false);
 }

 function onScannedBarcode(e) {
 	alert(e);
 }

 function configureScanBeep() {
 		linea.configureScanBeep({
 			enabled: true,
 			volume: 90,
 			data: [2200, 150, 2770, 150]
 		});
 }

 function onConnectionStateChange(e) {
 	alert("Connection state changed to: " + e.state + " (" + e.description.toUpperCase() + ")");
 	currentState = e.state;
 }

 function enableCharging() {
 	setCharging(true);
 }

 function disableCharging() {
 	setCharging(false);
 }

 function playSound() {
 	linea.playSound({
 		volume: 20,
 		data: [5200, 150, 1770, 150, 5200, 150]
 	});
 }

 function setCharging(value) {
 	linea.setCharging(value);
 }

 function getCharging() {
 	alert(linea.getCharging());
 }

 function setScanMode(value) {
 	var dia = Ti.UI.createOptionDialog({
 		title: "Select Scan Mode",
 		options: ["MODE_SINGLE_SCAN", "MODE_MULTI_SCAN", "MODE_MOTION_DETECT", "MODE_SINGLE_SCAN_RELEASE", "MODE_MULTI_SCAN_NO_DUPLICATES", "Cancel"],
 		cancel: 5
 	});
 	dia.show();
 	dia.addEventListener("click", function(e) {
 		var mode = linea.MODE_SINGLE_SCAN;
 		
 		switch(e.index) {
 			case 0: mode = linea.MODE_SINGLE_SCAN;
 			break;
 			case 1: mode = linea.MODE_MULTI_SCAN;
 			break;
 			case 2: mode = linea.MODE_MOTION_DETECT;
 			break;
 			case 3: mode = linea.MODE_SINGLE_SCAN_RELEASE;
 			break;
 			case 4: mode = linea.MODE_MULTI_SCAN_NO_DUPLICATES;
 			break;
 		}
 		
 		linea.setBarcodeScanMode(mode);
 	});
 }

 function getScanMode() {
 	alert(linea.getBarcodeScanMode());
 }

 function getFirmwareInformation() {
 	alert(linea.getFirmwareInformation());
 }

 function getBatteryCapacity() {
 	alert(linea.getBatteryCapacity());
 }

 function createButton(title, action) {
 	var button = Ti.UI.createButton({
 		title : title,
 		height : 40,
 		top : 30

 	});

 	button.addEventListener("click", action);

 	return button;
 }

 /* -- Demo UI -- */
 var win = Ti.UI.createWindow({
 	backgroundColor : "#fff",
 	layout : "vertical"
 });

 win.add(createButton("Set Scan Mode", setScanMode));
 win.add(createButton("Get Scan Mode", getScanMode));
 win.add(createButton("Enable Charging", enableCharging));
 win.add(createButton("Disable Charging", disableCharging));
 win.add(createButton("Get Charging State", getCharging));
 win.add(createButton("Get Firmware Infos", getFirmwareInformation));
 win.add(createButton("Get Battery Capacity", getBatteryCapacity));
 win.add(createButton("Play Sound", playSound));
 win.add(createButton("Configure Scan Beep", configureScanBeep));
 win.open();
