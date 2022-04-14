# Welcome to Sonic Pi

# References
#
# Stopping a loop: https://in-thread.sonic-pi.net/t/stopping-a-live-loop-or-a-thread-via-osc-command/672/2
# Using vt for time: https://in-thread.sonic-pi.net/t/checking-current-time/1551/2

run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

define :play_back do |recording, note_maker|
  recording.length.times do |i|
    method(note_maker).call(recording[i][0], recording[i][1])
    sleep recording[i][2]
  end
end

define :midi_sampler do |note_maker, player, sample_duration|
  played = []
  last = vt
  remaining = sample_duration
  
  live_loop :midi_recording do
    use_real_time
    note, velocity = sync "/midi:*/note_on"
    current = vt
    amp = velocity / 127.0
    method(note_maker).call(note, amp)
    duration = current - last
    last = current
    played.append([note, amp, duration])
    remaining = remaining - duration
    print "remaining:", remaining
    if remaining < 0
      sleep 1
      remaining = sample_duration
      print played
      method(player).call(played, note_maker)
      played = []
      print "Replay complete"
      last = vt
    end
  end
end

midi_sampler :cool_tri, :play_back, 10
#midi_sampler :additive_1, :play_back, 10
