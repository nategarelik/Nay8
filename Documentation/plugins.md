# Plugins

Plugins allow you to add additional routing modules to Nay8 by using native Swift code.

If you would like to develop your own Nay8 plugins, you need to build a .bundle to be loaded by Nay8. You must include Nay8Framework.framework in your project and define a public subclass of RoutingModule. The bundle must set this class as the principle class in `Info.plist`. `Info.plist` must also contain a string for `Nay8FrameworkVersion`, the current version number is `3.0.0`.

To include Nay8Framework you have 3 options:
1. Manually include it in the project (Grab it from the [release](https://github.com/nategarelik/Nay8/releases/latest) page)
2. Use [Carthage](https://github.com/Carthage/Carthage)
3. Use [CocoaPods](https://cocoapods.org) (coming soon)

Take a look at the [Sample project](/Documentation/SampleModule) to see how the project should be configured. The README there contains instructions for how to build a plugin. Also look at the modules in contained in the main project for examples of more complicated routings. 