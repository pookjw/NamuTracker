# NamuTracker

Hearthstone deck tracker for jailbroken iOS devices.

![](images/0.png)

## Compatibility

- iOS 14.x with jailbroken devices (requires tweak injection, with support for libhooker).

Rootless is not supported yet. Not tested with iOS 15 or above.

## Build

1. Create required API keys. See [common/headers/NamuTracker/keys.h](https://github.com/pookjw/NamuTracker/blob/main/common/headers/NamuTracker/keys.h).

2. Setup [theos](https://github.com/theos/theos) with iOS 16.0+ SDK.

3. `make package`
