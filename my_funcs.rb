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

