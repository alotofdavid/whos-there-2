WhosThere
==========
![WhosThere Image](http://imgur.com/mwaIWyZ.jpg)
Knock, knock, I'm here. With WhosThere, you can send hassle free notifications to your friends with a rap of your knuckles. (You can even leave it in your pocket!) 

We leveraged the iPhone's accelerometer in tandem with the Parse/Facebook API to convert sequences of 'knock' impulses into live notifications sent to your Facebook friends. 

Features
-------
- Knock to send push notifications
- Vibration confirmation for sent Knocks
- Facebook integration
- Customize your Knock message

Use Cases
---------
WhosThere is still in its infancy. The proof of concept is there and the application potential is astounding. 

### Driver pickup
We used to let someone know we were there by knocking on their door. Now you can knock on your phone instead, eliminating the danger of texting while driving.

### Accessibility
The ability to send notifications without any thoughtful interaction with the phone could be useful for individuals with disabilities, signaling for assistance by simply knocking on the surface of their phone.  

### Anything else
What's limiting this app to sending notifications? The knock detection scheme could be used to trigger any events. Turning on/off light switches. 

How do you detect Knocks?
-------
![Graph](http://i.imgur.com/tCEsOrh.jpg)
We sampled the accelerometer data to determine what registered when knocking on the phone. We recorded a bunch of sample signals, some including knocks and some containing just noise. We used python to develop an algorithm based on a high pass filter that would reject low frequency noise. We ran very rudimentary machine learning routines to determine the optimal threshold values for our filter and then ported to Objective-C!


