# Welcome to Sonic Pi
live_loop :midi_piano do
  use_real_time
  note, velocity = sync "/midi:i2m_musicport:1/note_on"
  synth :piano, note: note, amp: velocity / 127.0
end