# LineaPro in Appcelerator Titanium

## Requirements

- Titanium SDK 6.3.0+ (5.5.1+ for 1.x)
- iOS 9.0+ (iOS 8 for 1.x)
- Configured accessory protocols:
```xml
<ios>
  <plist>
    <dict>
      <!-- REQUIRED -->
      <key>UISupportedExternalAccessoryProtocols</key>
      <array>
        <string>com.datecs.linea.pro.msr</string>
        <string>com.datecs.linea.pro.bar</string>
      </array>
      <!-- / REQUIRED -->
    </dict>
  </plist>
</ios>
```
## Example

Please check out the example for a brief API documentation!

## License

MIT

## Build from Source

`appc run -p ios --build-only`

## Author
Hans Knöchel ([@hansemannnn](https://twitter.com/hansemannnn) / [Web](http://hans-knoechel.de))
