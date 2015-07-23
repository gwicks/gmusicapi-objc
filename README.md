gmusicapi-objc
==============

Objective-C/iOS port of the Unofficial Google Music API

Currently very, very basic, only supports getting all songs and retrieving stream urls.

Update (March 2014): Currently partially broken, due to changes in the Google Webclient interface. Metadata is probably inconsistent.

Update (July 2015): Reworked from the ground up due to changes in the login system, now requires that you subclass it as a view to use it. See the example code for reference.

Usage
==============

To use the API in your project, simply drop in the .h and .m files into your project and include them as you would any other
class. Then, in the view you want to use it in, make that view a subclass of GoogleMusicViewController, and implement the methods as shown in the example.

Currently, all requests are synchronous, but given the general use-case for this sort of API, I think this makes the most ssense. 
