var linea = require("de.infoteam.lineapro");

linea.addEventListener("barcodeScanned", onScannedBarcode);
linea.addEventListener("connectionStateChanged", onConnectionStateChange);

function onScannedBarcode(e) {
	alert(e);
}

function onConnectionStateChange(e) {
	alert("Connection state changed to: " + e.state);
}

function enableCharging() {
	setCharging(true);
}

function disableCharging() {
	setCharging(false);
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

win.open();