gmusicapi-objc
==============

Objective-C/iOS port of the Unofficial Google Music API

Currently very, very basic, only supports getting all songs and retrieving stream urls.

Update (March 2014): May now be broken, due to changes in Google's Webclient interface, untested.


Usage
==============

To use the API in your project, simply drop in the .h and .m files into your project and include them as you would any other
class.

Currently, all requests are synchronous, but given the general use-case for this sort of API, I think this makes the most ssense. 
