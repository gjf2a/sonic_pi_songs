# Welcome to Sonic Pi

define :cool_tri do |note|
  synth :tri, note: note, attack: 0.2, attack_level: 1, decay: 0.2, sustain_level: 0.4, sustain: 0.4, release: 0.2
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


part_1 = [[74, 0.5],   [73, 0.375], [71, 0.125], [69, 0.75],
          [67, 0.25],  [66, 0.5],   [64, 0.5],   [62, 0.75],
          [69, 0.25],  [71, 0.75],
          [71, 0.25],  [73, 0.75],
          [73, 0.25],  [74, 1]]
part_2 = [[74, 0.25],  [74, 0.25],  [73, 0.25],  [71, 0.25],  [69, 0.25],  [69, 0.375],
          [67, 0.125], [66, 0.25]]
brdg_0 = [[66, 0.25]]
part_3 = [[66, 0.25],  [66, 0.25],  [66, 0.25],  [66, 0.125], [67, 0.125], [69, 0.75]]
brdg_1 = [[67, 0.125], [66, 0.125]]
#part_4 = [[64, 0.25],  [64, 0.25],  [64, 0.25],  [64, 0.125], [66, 0.125], [67, 0.75]]
part_4 = downshift part_3, 1, scale(:d4, :major)
part_5 = [[66, 0.125], [64, 0.125], [62, 0.25],  [74, 0.5],
          [71, 0.25],  [69, 0.375], [67, 0.125], [66, 0.25],  [67, 0.25],
          [66, 0.5],   [64, 0.5],   [62, 1]]

notes = part_1 + part_2 + part_2 + brdg_0 + part_3 + brdg_1 + part_4 + part_5
play_melody notes, :cool_tri


