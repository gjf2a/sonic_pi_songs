define :alter_note do |note, alteration|
  if note.class == Array
    return note.map { |n| n + alteration }
  else
    return note + alteration
  end
end

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
    synth :tri, note: alter_note(note, 12), amp: amp * 0.4
  end
end

define :play_melody do |note_times_list, note_maker|
  note_times_list.length().times do |index|
    n = note_times_list[index]
    amp = n.length == 3 ? n[2] : 1
    method(note_maker).call(n[0], amp)
    sleep n[1]
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

define :transpose do |note, scale, interval|
  where = scale.index(note)
  if where != nil
    if interval >= 1
      return scale[where + interval - 1]
    elsif interval <= -2
      return scale[where + interval + 1]
    else
      return nil
    end
  else
    return nil
  end
end

define :find_interval do |note1, note2, scale|
  return (-8..8).detect {|i| transpose(note1, scale, i) == note2}
end

define :intervals_in do |melody, scale|
  intervals = []
  (melody.length - 1).times do |i|
    intervals.append(find_interval(melody[i][0], melody[i+1][0], scale))
  end
  return intervals
end

# Example:
# t = transpose_melody(melody, scale(:D4, :major, num_octaves: 4), 3)
# play_melody(t, :additive_1)
define :transpose_melody do |melody, scale, interval|
  return melody.map {|note| [transpose(note[0], scale, interval)] + note[1, 2]}
end

# Example:
# hm = harmonize_melody(melody, scale(:D4, :major, num_octaves: 4), 3)
# play_melody(hm, :additive_1)
define :harmonize_melody do |melody, scale, interval|
  return melody.map {|note| [[note[0], transpose(note[0], scale, interval)]] + note[1, 2]}
end

define :func do |f|
  if f.class == Symbol
    return method(f)
  else
    return f
  end
end

define :midi_loop do |note_maker, before|
  live_loop :midi_fun do
    use_real_time
    note, velocity = sync "/midi:*/note_*"
    amp = velocity / 127.0
    func(before).call(note, amp)
    func(note_maker).call(note, amp)
  end
end

# Example: basic_midi_loop :cool_tri
define :basic_midi_loop do |note_maker|
  midi_loop note_maker, lambda {|n,a|}
end

# midi_drone_loop :cool_tri, :D3, :additive_1, 0.3
define :midi_drone_loop do |note_maker, drone_note, drone_maker, drone_amp_scaling|
  midi_loop note_maker, lambda { |note, amp|
    method(drone_maker).call(drone_note, amp * drone_amp_scaling)
  }
end

# Example: midi_harmonizer_loop :additive_1, scale(:g3, :major, num_octaves: 4), 3
# G Major scale matching the mandolin range, harmonizing in thirds
define :midi_harmonizer_loop do |note_maker, scale, interval|
  midi_loop note_maker, lambda {|note, amp|
    method(note_maker).call(transpose(note, scale, interval), amp)
  }
end

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
	print zipped
        print "Replay complete"
      end
      sleep 1
    end
  end
end

define :midi_live_recorder do |note_maker|
  midi_loop note_maker, lambda { |note, amp|
    current = vt
    duration = current - get[:last]
    append_time_state_array(:durations, duration)
    append_time_state_array(:notes, note)
    append_time_state_array(:amps, amp)
    set :last, current
    print "Recording", note, amp
  }
end

# MIDI Sampler with playback
#
# note_maker specifies synth sound to use.
#
# player specifies how the sample is to be played back
# when replay_delay time has passed
#
# Example usage: midi_sampler :additive_1, :play_melody, 1.5
# By using :play_melody, this example will repeat the sample 
# verbatim after 1.5 beats of silence.
define :midi_sampler do |note_maker, player, replay_delay|
  midi_sampler_reset
  set :last, vt
  print "Sampler started at", get[:last]
  midi_playback_thread note_maker, player, replay_delay
  midi_live_recorder note_maker
end

# Melody analysis functions
define :bump do |dict, key, amount|
  if dict[key] == nil
    dict[key] = 0
  end
  dict[key] += amount
end

define :melody_note_count do |melody|
  counts = {}
  melody.length.times do |i|
    bump counts, melody[i][0], melody[i][1]
  end
  return counts.sort_by {|c| -c[1]}
end

define :deepest_root do |root, lo|
  while root > lo do
    root -= 12
  end
  return root
end

define :num_octaves do |root, hi|
  return ((hi - root) / 12.0).ceil + 1
end

define :within do |item, collection|
  collection.length.times do |i|
    if collection[i] == item
      return true
    end
  end
  return false
end

define :num_missing_melody_notes do |melody, scale|
  missing = 0
  melody.length.times do |i|
    if not within(melody[i][0], scale)
      missing += 1
    end
  end
  return missing
end

define :candidate_scales_for do |melody|
  counts = melody_note_count(melody)
  lo, hi = counts.minmax.map {|m| m[0]}
  root = deepest_root(counts[0][0], lo)
  octaves = num_octaves(root, hi)
  return [:major, :minor, :dorian, :phrygian, :lydian, :mixolydian].map {|name| scale(root, name, num_octaves: octaves)}
  #return scale_names.map {|name| scale(root, name, num_octaves: octaves)}
end

define :best_scales_for do |melody|
  return candidate_scales_for(melody)
  .map {|s| [num_missing_melody_notes(melody, s), s]}
  .sort_by {|c| c[0]}
end

define :best_scale_for do |melody|
  return best_scales_for(melody)[0][1]
end

define :play_harmonized_melody do |note_times_list, note_maker|
  scale_used = best_scale_for note_times_list
  interval = 3
  hm = harmonize_melody(note_times_list, scale_used, interval)
  print "scale", scale_used
  play_melody hm, note_maker
  print "scale", scale_used
end
