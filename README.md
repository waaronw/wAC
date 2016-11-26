# wAC
Personal iOS project to control Particle Photon-connected air conditioner 

This project uses the Particle Photon driving an IR emitter to toggle the power of the air conditioner at my jewelry studio.
Because IR is not a dependable transmission medium, and because my AC only has "toggle" and not discrete "on" and "off" IR commands, I also need some sort of feedback device. For this, I use a solid state wind sensor from Modern Device. (You could also use a photoresistor near the power LED.)

This is a personal, simple project and there are a couple of rough edges. The app may crash on first launch if you haven't defined the required settings in the iOS settings app. Occasionally the button may become unresponsive. Killing the app and restarting fixes this.

