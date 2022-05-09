# Sonic Pi Songs

This is a code library I'm building to support my musical efforts with Sonic
Pi. These efforts are currently in the following categories:
* Use Sonic Pi as a synthesizer to control via my MIDI-equipped electric mandolin.
* Experiment with different sound synthesis techniques.
* Encode melodies as data structures and play them back with a variety of
  synthesized sounds.

## Importing the library

Of course, you'll need to adjust the path to where you installed it on your
machine, but this is the general idea.

```
run_file "~/Documents/sonic_pi_songs/my_funcs.rb"
```

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

Additional melody playback functions, using the same parameters:
* `play_harmonized_melody`: Auto-detects the scale used and plays back a melody harmonized in thirds with the detected scale.

## MIDI

I'm using the [Sonuus i2M Musicport](https://www.sonuus.com/products_i2m_mp.html) to convert my mandolin playing into MIDI instructions. It issues three types of MIDI messages:
* `note_on` `note` `volume`
* `note_off` `note` `0`
* `pitch_bend` `amount`

The basic `live_loop` MIDI function is `midi_loop`. It expects two parameters:
* A sound synthesis function.
* A function describing what to do before sounding the note.

So far, I've written the following `live_loop` functions as MIDI event handlers:
* `basic_midi_loop`: Handles each `note_on` event by activating a sound
synthesis function, specified by the `note_maker` parameter.
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
recording the melody, until the amount of time given by the 
`replay_delay` parameter has passed. At that point, it will play an
interpretation of the melody as specified by the `player` function.
  * Every `player` function has to have the same two parameters as `play_melody`
    * `note_times_list`
    * `note_maker`
  * Every function listed in the Melody Playback section can be used
    as a `player` function.


### MIDI examples

```
run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

basic_midi_loop :blade_swell
```

This program loads in my library, then starts up a `basic_midi_loop` using
the `blade_swell` synthesizer sound.

```
run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

midi_sampler :additive_1, :play_harmonized_melody, 1.5
```

This program loads in my library, then starts up a `midi_sampler` that 
will record a melody using the `additive_1` synthesizer sound until there is 
a rest of 1.5 beats. At that point, it will play the melody back using that
same sound, accompanied by a harmony melody a third higher.
