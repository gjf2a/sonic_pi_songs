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

Some examples include:
* `blade_swell`
* `cool_tri`
* `additive_1`

## Melody Playback

The `play_melody` function takes two parameters:
* `note_times_list`: A list in which each element is a list containing a
  note, a duration, and (optionally) an amplitude. If no amplitudes are
  supplied, it will use an amplitude of 1.
* `note_maker`: A sound synthesis function.

It then plays the given melody with the given sound. The program
`joy_to_the_world.rb` is an example of its use.

## MIDI

I'm using the [Sonuus i2M Musicport](https://www.sonuus.com/products_i2m_mp.html) to convert my mandolin playing into MIDI instructions. It issues three types of MIDI messages:
* `note_on` `note` `volume`
* `note_off` `note` `0`
* `pitch_bend` `amount`

So far, I've written the following `live_loop` functions as MIDI event handlers:
* `basic_midi_loop`: Handles each `note_on` event by activating a sound
synthesis function, specified by the `note_maker` parameter.
* `midi_cutoff_loop`: Similar to `basic_midi_loop`, except that the previous
note is deactivated when a new `note_on` or `note_off` event arrives.
* `midi_drone_loop`: Similar to `basic_midi_loop`, but it accompanies each
melody note with a specified drone note. The drone note can have a separate
sound and has a scaling factor to control its volume. Useful for playing
many medieval melodies.
* `midi_harmonizer_loop`: Similar to `basic_midi_loop`, augmented with 
harmony notes, determined by the `scale` and `interval` parameters. The
interval is the position in an octave, so if `interval` is `3` it will
harmonize in thirds.
* `midi_sampler`: This function allows a user to play a MIDI instrument
(its sound specified by the `note_maker` parameter),
recording the melody, until a `note_off` message of a duration given by the
`completion_delay` parameter is received. At that point, it will play an
interpretation of the melody as specified by the `player` function.
  * Thus far, the only `player` function available is the `play_melody` 
    function described above. 
  * It is intended to add some more `player` functions that perform various
    transformations on the melody.
  * Every `player` function has the same two parameters as `play_melody`
    * `note_times_list`
    * `note_maker`

### MIDI example

```
run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

basic_midi_loop :blade_swell
```

This program loads in my library, then starts up a `basic_midi_loop` using
the `blade_swell` synthesizer sound.
