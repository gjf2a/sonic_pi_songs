# Sonic Pi Songs

This is a code library I'm building to support my musical efforts with Sonic
Pi. These efforts are currently in the following categories:
* Use Sonic Pi as a synthesizer to control via my MIDI-equipped electric mandolin.
* Experiment with different sound synthesis techniques.
* Encode melodies as data structures and play them back with a variety of
  synthesized sounds.

## Sound Synthesis

I have written several simple sound synthesis functions which all have a
common API. The first parameter is the note to play. The second parameter
is the `amp` value, defaulting to `1`. These functions, in turn, are passed
as parameters to the other functions in this framework.

## MIDI

I'm using the [Sonuus i2M Musicport](https://www.sonuus.com/products_i2m_mp.html) to convert my mandolin playing into MIDI instructions. It issues three types of MIDI messages:
* `note_on` `note` `volume`
* `note_off` `note` `0`
* `pitch_bend` `amount`

So far, I've written two `live_loop` functions as MIDI event handlers:
* `basic_midi_loop`: Handles each `note_on` event by activating a sound
synthesis function.
* `midi_cutoff_loop`: Similar to `basic_midi_loop`, except that the previous
note is deactivated when a new `note_on` or `note_off` event arrives.

### MIDI example

```
run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

basic_midi_loop :blade_swell
```

This program loads in my library, then starts up a `basic_midi_loop` using
the `blade_swell` synthesizer sound.

## Melody Playback

Melodies can be encoded as lists, in which each element is a two-value list
containing a note and a duration. Given such a list, a call to `play_melody`
with the list and a synthesizer sound will perform the melody.
