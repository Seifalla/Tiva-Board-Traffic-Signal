# Tiva-Board-Traffic-Signal
This embedded program controls the traffic lights on a pedestrian crosswalk. 
This traffic light system consists of 3 LEDs, 1 tri-state LED, and the Tiva Board microcontroller.  
The light is normally Green for cars as long as no pedestrians signal wanting to cross the street. In this state, the light for pedestrians is Red.
When a pedestrian pushes the button to cross, the Car Traffic Signal begins to transition to Yellow, then Red. After that, the Pedestrian Walk Signal turns Green for 10 seconds.
When the 10 seconds expire, that green Pedestrian Walk Signal begins to flash to warn the walkers that the time is about expire. The light should flash at a reasonable/noticeable rate for 5 seconds.
After those 5 seconds, the Pedestrian Walk Signal turns Red, and the Car Traffic Signal turns Green. After this, at least 15 seconds must elapse before pedestrians are allowed to cross again.

To achieve the desired time delays, I configured the SysTick timer subsystem so that the bus clock works at the frequency 80MHz.
