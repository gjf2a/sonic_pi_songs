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

## Melody Playback

Melodies can be encoded as lists, in which each element is a two-value list
containing a note and a duration. Given such a list, a call to `play_melody`
with the list and a synthesizer sound will perform the melody.

## MIDI

I'm using the [Sonuus i2M Musicport](https://www.sonuus.com/products_i2m_mp.html) to convert my mandolin playing into MIDI instructions. It issues three types of MIDI messages:
* `note_on` `note` `volume`
* `note_off` `note` `0`
* `pitch_bend` `amount`

So far, I've written three `live_loop` functions as MIDI event handlers:
* `basic_midi_loop`: Handles each `note_on` event by activating a sound
synthesis function, specified by the `note_maker` parameter.
* `midi_cutoff_loop`: Similar to `basic_midi_loop`, except that the previous
note is deactivated when a new `note_on` or `note_off` event arrives.
* `midi_sampler`: This function allows a user to play a MIDI instrument
(its sound specified by the `note_maker` parameter),
recording the melody, until a `note_off` message of a duration given by the
`completion_delay` parameter is received. At that point, it will play an
interpretation of the melody as specified by the `player` function.
  * Thus far, the only `player` function available is `play_back`, which
    repeats the stored melody.
  * It is intended to add some more `player` functions that perform various
    transformations on the melody.
  * Every `player` function has three parameters:
    * `recording`: A list of pairs of numbers: a note and its amplitude.
    * `durations`: A list of note durations.
    * `note_maker`: A sound synthesis function.

### MIDI example

```
run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

basic_midi_loop :blade_swell
```

This program loads in my library, then starts up a `basic_midi_loop` using
the `blade_swell` synthesizer sound.
