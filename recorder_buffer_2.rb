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

define :midi_sampler do |note_maker, player|
  set :last, vt
  set :notes, []
  
  in_thread do
    loop do
      duration = vt - get[:last]
      print duration
      if duration > 5
        recorded = get[:notes]
        print recorded # Ultimately, play these notes
        method(player).call(recorded, note_maker)
        set :notes, []
      end
      sleep 0.1
    end
  end
  
  
  live_loop :midi_recording do
    use_real_time
    note, velocity = sync "/midi:*/note_on"
    amp = velocity / 127.0
    method(note_maker).call(note, amp)
    current = vt
    duration = current - get[:last]
    set :last, current
    played = get[:notes].dup
    played.append([note, amp, duration])
    set :notes, played
  end
end

midi_sampler :additive_1, :play_back