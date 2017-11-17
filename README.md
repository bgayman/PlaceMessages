# PlaceMessages

iOS app that allows you to share Google Place locations with your contacts through a deep link and a universal link.

![Screenshot](https://raw.githubusercontent.com/bgayman/PlaceMessages/master/Screenshot.png)

## Installation

1. Clone this repository `git clone https://github.com/bgayman/PlaceMessages.git`
2. Add Google Place and Google Maps API Key to to the top of `AppDelegate.swift` (If you don't have a google api key you can get one [here](https://developers.google.com/maps/documentation/ios-sdk/))
3. Open PlaceMessages.xcworkspace.
4. To build to device update developer team and bundle identifier as needed.
5. You may want to turn off Associated Domains capabilities if you're not planning on using universal links.
6. Build and run.

## Univeral Link

Because apple-app-site-association file require an app id prefix it's not really possible to test this functionality without setting up your own server.

## Credits

_Place Messages_ uses artwork by Filippo Gianessi, Lesha Petrick, Noah, Alfa Design, Landan Lloyd, Ramesha, Vladimir Belochkin and UNiCORN all of which can be found on [The Noun Project](https://thenounproject.com).
