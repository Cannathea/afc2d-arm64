Apple File Conduit "2" (iOS 11+, arm64)
=======================================

**Works on any arm64 device running iOS 11, 12, and 13.**

This is a modified version of saurik's original AFC2 code that downloads and installs an arm64 copy of afcd (required on iOS 11 and above) straight from Apple, and then automatically grants it the necessary `platform-application` entitlement required for functionality on KPPLess jailbreaks (like Electra and Meridian).

As a result, **this package does not illegally redistribute copyrighted Apple binaries.**

In compliance with saurik's original code being licensed under GPLv3, source code has been released above at the GitHub link.

## saurik's original explanation of what AFC2 is

AFC stands for "Apple File Conduit" (or at least so says [TheiPhoneWiki](https://www.theiphonewiki.com/wiki/AFC)), and is how computer applications such as iTunes and iPhoto can read and write files from your device over USB.

AFC is "jailed" and only allows access to "media" (such as photos, music, and data for apps from the App Store).

This package creates a new service, "AFC2", with full filesystem access.

If you use a USB device management tool, it might need AFC2 to fully work.

Historically, getting full (not "jailed") filesystem access was core to the idea "this is a jailbreak". However, due to security concerns, modern "jailbreaks" now avoid installing AFC2 by default.

**Please understand that AFC2 is considered by many to be a security hole: you might not want to provide full USB filesystem access.**

Some AFC2 setups, in particular many that were installed by default with older jailbreaks (such as evasi0n for iOS 6) set a flag that allows this access to not require a "trusted" USB connection :/.

Installing this package will correct that mistake, and is thereby more secure than the "stock" from-jailbreak AFC2 configuration you may be using now.

AFC2 is GPLv3-licensed. See `LICENSE` for more information.