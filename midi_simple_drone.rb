# Welcome to Sonic Pi

# Based on Tutorial 11.1

live_loop :midi_fun do
  use_real_time
  note, velocity = sync "/midi:*/note_on"
  amp = velocity / 127.0
  synth :blade, note: note, amp: amp
  synth :blade, note: [:A3, :D4], amp: amp / 2
end