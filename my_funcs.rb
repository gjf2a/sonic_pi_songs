define :basic_tri do |note, amp=1|
  synth :tri, note: note, amp: amp
end

define :cool_tri do |note, amp=1|
  synth :tri, note: note, amp: amp, attack: 0.2, attack_level: 1, decay: 0.2, sustain_level: 0.4, sustain: 0.4, release: 0.2
end

define :blade_swell do |note, amp=1|
  synth :blade, note: note, amp: amp, attack: 0.5, attack_level: 1, decay: 0.2, sustain_level: 0.4, sustain: 0.4, release: 0.4
end

# Based on Section A.18, Sonic Pi Tutorial
define :additive_1 do |note, amp=1|
  with_fx :flanger do
    synth :sine, note: note, amp: amp
    synth :square, note: note, amp: amp
    synth :tri, note: note + 12, amp: amp * 0.4
  end
end

define :play_melody do |note_times_list, note_maker|
  note_times_list.length().times do |index|
    method(note_maker).call note_times_list[index][0]
    sleep note_times_list[index][1]
  end
end


define :downshift do |notes, n, sc|
  down = []
  notes.length().times do |index|
    scale_index = sc.index(notes[index][0])
    scaled_note = [sc[scale_index - n], notes[index][1]]
    down.append(scaled_note)
  end
  
  return down
end

define :harmonize do |note, scale, interval|
  where = scale.index(note)
  if where != nil
    return scale[where + interval - 1]
  else
    return nil
  end
end

# Example: basic_midi_loop :cool_tri
define :basic_midi_loop do |note_maker|
  live_loop :midi_fun do
    use_real_time
    note, velocity = sync "/midi:*/note_on"
    method(note_maker).call(note, velocity / 127.0)
  end
end

# Example: midi_cutoff_loop :cool_tri
define :midi_cutoff_loop do |note_maker|
  sound = nil
  live_loop :midi_games do
    use_real_time
    value = sync "/midi:*/*"
    if value.length() == 2
      if not sound == nil
        control sound, note: 0
        control sound, amp: 0
      end
      sound = method(note_maker).call(value[0], value[1] / 127.0)
    end
  end
end

define :play_back do |recording, durations, note_maker|
  recording.length.times do |i|
    method(note_maker).call(recording[i][0], recording[i][1])
    sleep durations[i]
  end
end

# Example: midi_sampler :additive_1, :play_back, 1
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
