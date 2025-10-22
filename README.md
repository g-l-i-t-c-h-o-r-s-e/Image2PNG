Image2PNG
====

Quartz Composer Plugin which exports Image and Video frames as PNG.

## Description
Quartz Composer doesn't have standard plugin which exports some Image to local storage.
This patch has "Enable", "Input Image" and "Destination Path."
You can connect some Image to "Input Image" and send bang to "Enable", Image will be exported to "Destination Path" as Portable Network Graphics(PNG).

## Developer's Environment
~~Quartz Composer 4.61(Framework Version 5.1)~~ <br>
~~Xcode 7.1 on MacOS 10.11.~~ <br>
* Quartz Composer 4.61 or 4.62 (Framework Version 5.1)
* Xcode 9.4.1 on MacOS 10.14.6

## Usage
Open .xcodeproj with Xcode. If you feel lucky, just "Build" and restart Quartz Composer.

"Image2PNG" patch will export "yyyyMMdd-HHmmss_xxxxx.png" on Desktop by default.

## Licence

This source code was developed while reffering to [Apple Developer Library](https://developer.apple.com/library/mac/samplecode/ImageExporter/Introduction/Intro.html#//apple_ref/doc/uid/DTS40009329-Intro-DontLinkElementID_2).

## Author

* [Shin'ichiro SUZUKI](shin@szk-engineering.com)
