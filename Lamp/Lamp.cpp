#include "Arduino.h"
#include "Lamp.h"

// Constructor - Will just set the pin for the lamp
Lamp::Lamp(int pin) {
	_pin = pin;
	_current_light = 0;
	_fade_start = 0;
	_fade_end = 0;
	_fade_direction = 0;
	_fade_length = 0;
	_blink_on = 0;
	_blink_off = 0;
	_blink_lamp_on = false;
	_blink_timer = 0;
	analog = false;
	_flicker = false;
	_flicker_random = 0;
	_flicker_last = 0;
	_flicker_velocity = 0;
}

// -------- FADES START --------

// Takes fade length in millis, and direction 1 for up and -1 for down
void Lamp::fade(int start_offset, int fade_length, int direction) {
	_fade_start			= millis() + start_offset;
	_fade_end				= millis() + start_offset + fade_length;
	_fade_length		= fade_length;
	_fade_direction = direction;
	if (direction != 0)
	{
		analogWrite(_pin, (direction == 1 ? 1 : 255));
	}
}

// Does the actual fading
void Lamp::fade() {
	if(millis() > _fade_start && millis() < _fade_end && _fade_direction != 0) {
		// Do the fade
		float light_val = ((millis() - _fade_end) * (255 / _fade_length));

		// Takes the raw float and abs it for fade
		int light = (_fade_direction  == 1 ? 255 - abs(light_val) : abs(light_val));
		
		// Sets the light level
		analogWrite(_pin, light);
		_current_light = light;
	}
	
	if (_fade_direction != 0 && millis() > _fade_end)	{
		int l = (_fade_direction == 1 ? 255 : 0);
		analogWrite(_pin, l);
		_current_light = l;
		_fade_direction = 0;
	}
}

// -------- FADES END ----------

// -------- BLINKS START -------

// Sets blinking, off for time off, and on for time on. Set both to 0 to stop the blinking.
void Lamp::blink(int off_t, int on_t) {
	_blink_off		= off_t;
	_blink_on 		= on_t;
	_blink_timer	= millis();
	off();
	blink();
}

void Lamp::blink() {
	if (_blink_off != 0) {
		// Runs when the lamp is on, to shut it off
		if (_blink_lamp_on && (_blink_timer + _blink_on) < millis()) {
			off();
			_current_light = 0;
			_blink_lamp_on = false;
			_blink_timer = millis();
		}
		// Runs when the lamp is off, to turn it on
		else if (!_blink_lamp_on && (_blink_timer + _blink_off) < millis()){
			on();
			_current_light = 255;
			_blink_lamp_on = true;
			_blink_timer = millis();
		}
	}
}

// -------- BLINKS END ---------

// -------- FLICKER START ---------

void Lamp::flicker(bool flicker, int velocity) {
	_flicker = flicker;
	_flicker_velocity = velocity;
}

void Lamp::flicker() {
	if (analog && _flicker && millis() > _flicker_last + _flicker_velocity)
	{
		//_flicker_random = (random(1) == 1 ? random(60) : random(60)*-1);
		//_flicker_random = (_flicker_random < 1 ? 1 : _flicker_random);
		//_flicker_random = (_flicker_random > 255 ? 255 : _flicker_random);
		analogWrite(_pin, random(0,255));
		_flicker_last = millis();
	}
}

// -------- FLICKER END ---------

void Lamp::off() {
	digitalWrite(_pin, LOW);
}

void Lamp::on() {
	digitalWrite(_pin, HIGH);
}

void Lamp::setLevel(int level) {
	analog ? analogWrite(_pin, level) : (level > 1 ? digitalWrite(_pin, HIGH) : digitalWrite(_pin, LOW));
}

// Place things here that needs to be done with all the lamps all the time
void Lamp::work() {
	// Analog lamps
	if (analog) {
		fade();
		flicker();
	}
	// Digital lamps
	//else {
	//	
	//}
	
	// All lamps outside the if-else statement
	blink();
}

