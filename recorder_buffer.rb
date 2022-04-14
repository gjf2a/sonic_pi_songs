# Welcome to Sonic Pi

# References
#
# Stopping a loop: https://in-thread.sonic-pi.net/t/stopping-a-live-loop-or-a-thread-via-osc-command/672/2
# Using vt for time: https://in-thread.sonic-pi.net/t/checking-current-time/1551/2

run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

define :play_back do |recording, durations, note_maker|
  recording.length.times do |i|
    method(note_maker).call(recording[i][0], recording[i][1])
    sleep durations[i]
  end
end

define :midi_sampler do |note_maker, player, completion_delay|
  notes_played = []
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
      print notes_played
      print durations
      method(player).call(notes_played, durations, note_maker)
      notes_played = []
      durations = []
      print "Replay complete"
      last = vt
    else
      amp = velocity / 127.0
      method(note_maker).call(note, amp)
      last = current
      notes_played.append([note, amp])
    end
  end
end

#midi_sampler :cool_tri, :play_back, 1
midi_sampler :additive_1, :play_back, 1
