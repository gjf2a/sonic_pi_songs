run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

#midi_sampler :additive_1, :play_melody, 1

define :append_time_state_array do |state_key, appendee|
  array = get[state_key] + [appendee]
  set state_key, array
end

define :midi_sampler_reset do
  set :notes, []
  set :amps, []
  set :durations, []
end

define :midi_playback_thread do |note_maker, player, replay_delay|
  in_thread do
    loop do
      wait_time = vt - get[:last]
      print "wait_time", wait_time
      if wait_time > replay_delay and get[:durations].length >= 2
        print "Replay begin"
        dur = get[:durations][1, get[:durations].length]
        dur.append(replay_delay)
        zipped = get[:notes].zip(dur, get[:amps])
        midi_sampler_reset
        method(player).call(zipped, note_maker)
        print "Replay complete"
      end
      sleep 1
    end
  end
end

define :midi_live_recorder do |note_maker|
  midi_loop note_maker, lambda {|note, amp|
    set :current, vt
    duration = get[:current] - get[:last]
    append_time_state_array(:durations, duration)
    append_time_state_array(:notes, note)
    append_time_state_array(:amps, amp)
  }, lambda {|note, amp| set :last, get[:current]}
end

define :midi_sampler_2 do |note_maker, player, replay_delay|
  midi_sampler_reset
  set :last, vt
  print "Sampler started at", get[:last]
  midi_playback_thread note_maker, player, replay_delay
  midi_live_recorder note_maker
end

midi_sampler_2 :additive_1, :play_melody, 2