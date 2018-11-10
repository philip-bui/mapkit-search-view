<p align="center">
<a href="https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit.png"><img src="https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit.png" title="MapKit" height="356" width="200"></a>
<a href="https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit_Completions.png"><img src="https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit_Completions.png" title="Completions" height="356" width="200"></a>
<a href="https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit_MapItems.png"><img src="https://github.com/philip-bui/mapkit-search-view/raw/master/Images/MapKit_MapItems.png" title="MapItems" height="356" width="200"></a>
</p>

# MapKit Search View
[![CI Status](http://img.shields.io/travis/philip-bui/mapkit-search-view.svg?style=flat)](https://travis-ci.org/philip-bui/mapkit-search-view)
[![CodeCov](https://codecov.io/gh/philip-bui/mapkit-search-view/branch/master/graph/badge.svg)](https://codecov.io/gh/philip-bui/mapkit-search-view)
[![Version](https://img.shields.io/cocoapods/v/MapKitSearchView.svg?style=flat)](http://cocoapods.org/pods/MapKitSearchView)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/MapKitSearchView.svg?style=flat)](http://cocoapods.org/pods/MapKitSearchView)
[![License](https://img.shields.io/cocoapods/l/MapKitSearchView.svg?style=flat)](https://github.com/philip-bui/mapkit-search-view/blob/master/LICENSE)

An implementation of Apple's Map search view. 

- Animation between states and keyboard events.
- Single gesture to scroll table view or drag down sheet.
- Map user tracking (Follow, Follow with Heading).
- Compass on non-north headings.
- Customizable colors, search options.

## Requirements

- iOS 11.0+
- Xcode 10.3+
- Swift 4.2+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate MapKit Search View into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'MapKitSearchView'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate MapKit Search View into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "philip-bui/mapkit-search-view"
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but MapKit Search View does support its use on supported platforms.

Once you have your Swift package set up, adding MapKit Search View as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/philip-bui/mapkit-search-view.git", from: "1.0.0"))
]
```

## Usage

```swift
import MapKitSearchView

let mapKitSearch = MapKitSearchViewController(delegate: self)
mapKitSearch.tintColor = nil // Tints the close, userTracking and searchBar cursor colors.
mapKitSearch.markerTintColor = nil // Tints map annotations and mapItem results.
mapKitSearch.completionEnabled = true // Enables search completions as you type.
mapKitSearch.geocodeEnabled = true // Enables geocoding when tapping on a map at street levels.
mapKitSearch.userLocationRequest = .authorizedAlways // Requests location permission on view load.
```

## Improvements

- Tablet / Landscape UI.
- Additional information on duplicate place names.
- Strings Localization.
- Optional delegate methods to customize UI views (Search Bar, Table View rows).
- Add Bottom Sheet states (collapsed, peek, expanded) for users to choose.

## License

MapKit Search View is available under the MIT license. [See LICENSE](https://github.com/philip-bui/mapkit-search-view/blob/master/LICENSE) for details.
