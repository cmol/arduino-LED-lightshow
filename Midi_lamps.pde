#include <Lamp.h>
#include <MIDI.h>

int timer = 60;           // The higher the number, the slower the timing.
int timer2 = 5;
int ledPins[] = { 
  3, 5, 6, 9, 10, 11 };       // an array of pin numbers to which LEDs are attached
int pinCount = 6;          // the number of pins (i.e. the length of the array)
int fade_speed = 1;
int midi_data;
unsigned long now;
int note = 0;
int velocity = 0;
int fade_offset = 0;
int fade_length = 0;

Lamp lampsDigital[] = {2,4,7,8,12,13};
Lamp lampsAnalog[] = {3,5,6,9,10,11};
Lamp lamps[] = {3,5,6,9,10,11,2,4,7,8,12,13};

void setup() {
  // use a for loop to initialize each pin as an output:
  for (int thisPin = 2; thisPin < 14; thisPin++)  {
    pinMode(thisPin, OUTPUT);
  }
  now = 0;
  
  // Sets all analog lamps to be analog
  for (int lamp = 0; lamp < 6; lamp++) {
    lampsAnalog[lamp].analog = true;
    lamps[lamp].analog = true;
  }
  
  // Initiate MIDI communications, listen to all channels
  MIDI.begin(15);   
  
  
  // Turn all the digital lamps off
  for (int lamp = 0; lamp < 6; lamp++) {
    //lampsDigital[lamp].blink(50,50);
    lampsDigital[lamp].off();
  }
  
  // Turn all the analog lamps off
  for (int lamp = 0; lamp < 6; lamp++) {
    lampsAnalog[lamp].off();
  }
 
}

// This will carry out the fades and so on. These must be run each loop! (!!!)
void work() {
  for (int lamp = 0; lamp < 6; lamp++) {
    lampsDigital[lamp].work();
  }
  
  for (int lamp = 0; lamp < 6; lamp++) {
    lampsAnalog[lamp].work();
  }
  
  for (int lamp = 0; lamp < 12; lamp++) {
    lamps[lamp].work();
  }
}

// Handle the note on calls
void noteOn(int note, int velocity) {
  
  // Clean velocity to light
  if (note < 12) {
    lamps[note].setLevel(velocity*2);
  }
  
  // Strobes for lamps
  else if (note > 11 && note < 24) {
    lamps[note-12].blink(velocity,velocity);
    //lamps[note-12].setLevel(velocity);
  }
  
  // FadeUps for lamps
  else if (note > 23 && note < 36) {
    if (lamps[note-24].analog) {
      fade_offset = 0;
      fade_length = velocity * 100;
      lamps[note-24].fade(fade_offset, fade_length, 1);
    }
  }
  
  // FadeDowns for lamps
  else if (note > 35 && note < 48) {
    if (lamps[note-36].analog) {
      fade_offset = 0;
      fade_length = velocity * 100;
      lamps[note-36].fade(fade_offset, fade_length, -1);
    }
  }
  
  // Flicker on
  else if (note > 47 && note < 60) {
    lamps[note-48].flicker(true, velocity);
  }
  
  // Special functions
  else if (note > 119) {
    switch(note) {		
      
      case 127:
        for (int lamp = 0; lamp < 12; lamp++) {
          lamps[lamp].fade(1000, 10000, 0);
          lamps[lamp].blink(0,0);
          lamps[lamp].flicker(false);
          lamps[lamp].off();
        }
        break;
        
      case 126:
        for (int lamp = 0; lamp < 12; lamp++) {
          lamps[lamp].fade(1000, 10000, 0);
          lamps[lamp].blink(0,0);
          lamps[lamp].flicker(false);
          lamps[lamp].on();
        }
        break;
      case 125:
        for (int lamp = 0; lamp < 12; lamp++) {
          lamps[lamp].fade(1000, 10000, 0);
          lamps[lamp].blink(0,0);
          lamps[lamp].flicker(false);
          lamps[lamp].on();
        }
        break;
      // See the online reference for other message types
      default:
        break;
      
    }
  }
}

// Handle the note on calls
void noteOff(int note, int velocity) {
  
  // Clean velocity to light, off state
  if (note < 12) {
    lamps[note].off();
  }
  
  // Strobes for lamps, off state
  else if (note > 11 && note < 24) {
    lamps[note-12].blink(0,0);
  }
  
  // Fades for lamps, off state
  else if (note > 23 && note < 36) {
    lamps[note-24].fade(1000, 10000, 0);
    lamps[note-24].off();
  }
  
  // Fades for lamps, off state
  else if (note > 35 && note < 48) {
    lamps[note-36].fade(1000, 10000, 0);
    lamps[note-36].off();
  }
  
  // Flicker on
  else if (note > 47 && note < 60) {
    lamps[note-48].flicker(false);
  }
  
  // Special functions
  else if (note > 119) {
    switch(note) {		
      
      case 125:
        for (int lamp = 0; lamp < 12; lamp++) {
          lamps[lamp].fade(1000, 10000, 0);
          lamps[lamp].blink(0,0);
          lamps[lamp].flicker(false);
          lamps[lamp].off();
        }
        break;
      // See the online reference for other message types
      default:
        break;
      
    }
  }
}

// This is our main loop
void loop() {
  
  if (MIDI.read()) {                    // Is there a MIDI message incoming ?
  switch(MIDI.getType()) {		// Get the type of the message we caught
    case NoteOn:
      noteOn(MIDI.getData1(), MIDI.getData2());
      break;
    
    case NoteOff:
      noteOff(MIDI.getData1(), MIDI.getData2());
      break;
    
    case ProgramChange:               // If it is a Program Change
      midi_data = int(MIDI.getData1());	         
					
      break;
      
    
    // See the online reference for other message types
    default:
      break;
    }
  }
  
  // This is where the fun begins
  work();
  
}
