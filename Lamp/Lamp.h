#ifndef Lamp_h
#define Lamp_h

#include "Arduino.h"

class Lamp
{
  public:
    Lamp(int pin);
    void fade(int fade_offset, int fade_length, int direction);
    void fade();
    void blink(int off, int on);
    void blink();
    void flicker(bool flicker, int velocity);
    void flicker();
    void on();
    void off();
    void work();
    void setLevel(int level);
    bool analog;
  private:
    int _pin;
    int _current_light;
    unsigned long _fade_start;
    float _fade_end;
    int _fade_direction;
    float _fade_length;
    int level;
    int _blink_off;
    int _blink_on;
    unsigned long _blink_timer;
    bool _blink_lamp_on;
    bool _flicker;
    int _flicker_random;
    unsigned long _flicker_last;
    int _flicker_velocity;
};

#endif
