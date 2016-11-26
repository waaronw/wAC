# wAC
Personal iOS project to control Particle Photon-connected air conditioner 

This project uses a Particle Photon driving an IR emitter to toggle the power of the air conditioner at my jewelry studio. The IR code was harvested from the remote using an Arduino and IR reciver/demodulator. See http://www.righto.com/2009/09/arduino-universal-remote-record-and.html

Because IR is not a dependable transmission medium, and because my AC only has "toggle" and not discrete "on" and "off" IR commands, I also need some sort of feedback device. For this, I use a solid state wind sensor from Modern Device. https://moderndevice.com/product/wind-sensor/
You could also use a photoresistor near the power LED, but modification of both the iOS code and firmware will be necessary to support this.

This is a personal, simple project and there are a couple of rough edges. The app may crash on first launch if you haven't defined the required settings in the iOS settings app. Occasionally the button may become unresponsive. Killing the app and restarting fixes this. However, the animation while waiting for confirmation that the power toggle worked is fun. In fact, imagining this simple one-button interface is most of why I made this project! (And so my studio is comfy when I arrive on hot days.)


DEPENDENCIES
This project uses the Spark SDK for iOS, AFNetworking, and a couple of tiny helper files.
These are baked into this project for convenience. This is not ideal. It is, however, what it is.
