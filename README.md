# AWSPlacePicker
This is IOS Swift Universal Static Library for Place picking from Map.



## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like `YSimpleImagePicker` in your projects. 

First, add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
pod 'AWSPlacePicker'
```

Second, install `AWSPlacePicker` into your project:

```ruby
pod install
```

## Usage

Import Library into View Controller

```ruby
import AWSPlacePicker
```

Then set api google key
```ruby
AWSPlacePicker.shared.API_KEY = "AIzaSyDgOeL1TnDOy7ePEdvdcNs9sE2EDypRJ2Y";
```
Then After simply get location by using shared instance of AWSPlacePicker

```ruby
AWSPlacePicker.shared.pickLocationFrom(from: self, onLocationSelection: { (loc) in
  print(loc)
}, onCancellation: nil)
```
AWSLocation is having following information of picked location.
```ruby
public struct AWSLocation {
    public var id : String?
    public var postcode : String?
    public var city : String?
    public var country : String?
    public var country_short : String?
    public var latitude : Double?
    public var longitude : Double?
    public var address : String?
}
```

## License

`AWSPlacePicker` is distributed under the terms and conditions of the [MIT license]
