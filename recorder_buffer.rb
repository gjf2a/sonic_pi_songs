# Welcome to Sonic Pi

# References
#
# Using vt for time: https://in-thread.sonic-pi.net/t/checking-current-time/1551/2

run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

define :midi_sampler do |note_maker, player, completion_delay|
  notes = []
  amps = []
  durations = []
  last = vt
  live_loop :midi_recording do
    use_real_time
    note, velocity = sync "/midi:*/note_*"
    current = vt
    duration = current - last
    durations.append(duration)
    if duration > completion_delay and velocity == 0
      durations = durations[1, durations.length]
      zipped = notes.zip(durations, amps)
      print(zipped)
      method(player).call(zipped, note_maker)
      notes = []
      amps = []
      durations = []
      print "Replay complete"
      last = vt
    else
      amp = velocity / 127.0
      method(note_maker).call(note, amp)
      last = current
      notes.append(note)
      amps.append(amp)
    end
  end
end

midi_sampler :additive_1, :play_melody, 1
