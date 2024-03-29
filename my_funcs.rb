define :alter_note do |note, alteration|
  if note.class == Array
    return note.map { |n| n + alteration }
  else
    return note + alteration
  end
end

##
## Synthesizer Sound Functions
##

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

define :additive_2 do |note, amp=1|
  synth :blade, note: note, amp: amp
  synth :prophet, note: note, amp: amp
end

## 
## Melody playback
##

define :play_melody do |note_times_list, note_maker|
  note_times_list.length().times do |index|
    n = note_times_list[index]
    amp = n.length == 3 ? n[2] : 1
    method(note_maker).call(n[0], amp)
    sleep n[1]
  end
end

##
## Interval Manipulation
##

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

##
## MIDI
##

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
  set :last_recording, []
end

define :midi_playback_thread do |note_maker, player, replay_delay|
  in_thread do
    loop do
      wait_time = vt - get[:last]
      print "wait_time", wait_time
      if wait_time > replay_delay and get[:durations].length >= 2
        print "Replay begin"
        melody = retrieve_recording replay_delay
        method(player).call(melody, note_maker)
        set :last_recording, melody.map {|i| [i[0], i[1].round(2), i[2].round(2)]}
        print "Replay complete; melody in :last_recording"
      end
      sleep 1
    end
  end
end

define :retrieve_recording do |replay_delay|
  dur = get[:durations][1, get[:durations].length]
  dur.append(replay_delay)
  zipped = get[:notes].zip(dur, get[:amps])
  midi_sampler_reset
  return zipped
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
# Example usages: 
#
# midi_sampler :additive_1, :play_melody, 1.5
# By using :play_melody, this example will repeat the sample 
# verbatim after 1.5 beats of silence.
#
# midi_sampler :additive_1, :play_harmonized_melody, 1.5
# Similar to the previous example, except the sample when repeated
# will play both the sample and an automatically-detected harmony.
#
# midi_sampler :additive_1, :play_variation_3, 1.5
# Similar to the last two examples, except it sends the melody to a server 
# listening on "localhost:8888", which then replies with a variation.
#
define :midi_sampler do |note_maker, player, replay_delay|
  midi_sampler_reset
  set :last, vt
  print "Sampler started at", get[:last]
  midi_playback_thread note_maker, player, replay_delay
  midi_live_recorder note_maker
end

##
## Additional replay functions
##

define :play_harmonized_melody do |note_times_list, note_maker|
  scale_used = best_scale_for note_times_list
  interval = 3
  hm = harmonize_melody(note_times_list, scale_used, interval)
  print "scale", scale_used
  play_melody hm, note_maker
  print "scale", scale_used
end

define :play_random_note_melody do |note_times_list, note_maker|
  scale_used = best_scale_for note_times_list
  r = note_times_list.map {|note| [choose(scale_used)] + note[1, 2]}
  play_melody r, note_maker
end

define :play_weighted_random_melody do |note_times_list, note_maker|
  play_melody(make_weighted_random_melody(note_times_list), note_maker)
end

define :invert_note do |note, scale|
  return scale[0] + (scale[-1] - note)
end

define :invert_melody do |melody|
  scale_match = best_scale_for melody
  return melody.map {|n| [invert_note(n[0], scale_match), n[1], n[2]]}
end

require 'socket'

define :play_external_transform_melody do |note_times_list, note_maker, external_command|
  s = TCPSocket.open('localhost', 8888)
  s.puts(external_command)
  shipment = note_times_list.join(",")
  s.puts(shipment)
  reply = s.gets
  s.close

  reply = eval(reply)
  sleep(1)
  play_melody reply, note_maker
end

define :play_variation_3 do |note_times_list, note_maker| 
  play_external_transform_melody note_times_list, note_maker, "create_variation_3 0.75"
end


##
## Probabilistic Analysis
##

define :distribution_of do |note_times_list|
  note_counts = melody_note_count note_times_list
  notes, counts = note_counts.transpose
  total = counts.inject { |a, b| a + b }
  counts = counts.map {|c| c / total}
  return [notes, counts].transpose
end

define :random_weighted_note do |distribution|
  n = rand
  i = -1
  while i < distribution.length - 1 and n > 0 do
    i += 1
    n -= distribution[i][1]
  end
  return distribution[i][0]
end

define :make_weighted_random_melody do |note_times_list|
  distribution = distribution_of note_times_list
  return note_times_list.map {|note| [random_weighted_note(distribution)] + note[1, 2]}
end



##
## Melody analysis functions
##

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

define :candidates_for do |melody, candidate_list, candidate_func|
  counts = melody_note_count(melody)
  lo, hi = counts.minmax.map {|m| m[0]}
  root = deepest_root(counts[0][0], lo)
  octaves = num_octaves(root, hi)
  return candidate_list.map {|name| func(candidate_func).call(root, name, num_octaves: octaves)}
end

define :best_matches_for do |melody, candidate_list, candidate_func|
  return candidates_for(melody, candidate_list, candidate_func)
  .map {|s| [num_missing_melody_notes(melody, s), s]}
  .sort_by {|c| c[0]}
end

define :best_scale_for do |melody|
  return best_matches_for(melody, [:major, :minor, :dorian, :phrygian, :lydian, :mixolydian], :scale)[0][1]
end

define :best_chord_for do |melody|
  return best_matches_for(melody, [:major, :minor, :m7, :dim7, :dom7, :sus2, :sus4], :chord)[0][1]
end

##
## Subdividing melodies into parts based on pauses
##

define :find_pauses do |notes|
  result = []
  notes.length().times do |i|
    before = i - 1
    after = i + 1
    if before >= 0 and after < notes.length() and notes[i][1] > notes[before][1] and notes[i][1] > notes[after][1]
      result.append(i)
    end
  end
  return result
end

define :remove_zero_amp do |notes|
  return notes.select {|n| n.length() < 3 or n[2] > 0.0}
end

define :double_all do |nums|
  return nums.map {|n| n * 2}
end

define :subdivide_using do |notes, division_indices|
  result = []
  current_sub = []
  current_i = 0
  notes.length().times do |i|
    current_sub.append(notes[i])
    if i == division_indices[current_i]
      result.append(current_sub)
      current_sub = []
      current_i += 1
    end
  end
  result.append(current_sub)
  return result
end

define :get_subdivisions do |notes|
  no_zeros = remove_zero_amp(notes)
  pauses = find_pauses(no_zeros)
  if no_zeros.length() < notes.length()
    pauses = double_all(pauses)
  end
  return subdivide_using(notes, pauses)
end

##
## Melody remixers
##

# Concept:
#
# Write a function that takes a melody and a list of transformer functions.
# - First, it finds the best matching scale for the melody.
# - It uses get_subdivisions() to subdivide the melody.
# - For each subdivision, it calls a transformer function to create a variation.
# - All the variations get concatenated together into a new melody.
#
# Ideas for transformer functions:
# - transpose it
# - invert it
# - duplicate it
#   - maybe transform the duplicate with another function
# - change the durations of its notes
# - bridge its opening and closing notes with an alternative musical figure
# - Replace a note with a musical figure
# - Replace a musical figure with a note
# - Substitute consistent appearances of a specific musical figure with an alternative

# Alternative Concept:
#
# - Write an expander for each melodic figure.
#   - The expander will look for either:
#     - A single note if it starts and ends on the same note
#     - A pair of notes if it starts and ends with different notes
#   - It will then splice itself into the melody.
# - Write a collapser for each melodic figure.
#   - The collapser will look for the figure.
#   - It will then collapse it into either a single note or pair of notes.
# - Write a replacer for each melodic figure.
#   - It will look for compatible figures, i.e., same first/last note
#   - It will replace the compatible figure.
# - All of these will need to know the melody's scale first, of course.
# - I imagine using the expanders more than the collapsers.
#   - Maybe do two expansions for each collapse.
#   - The collapsers are there to add some unpredictability.

# Related alternative:
# - Find the long-duration notes ("peaks")
# - Select melodic figures to connect them, possibly with intervening points.
