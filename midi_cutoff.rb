# Welcome to Sonic Pi

sound = nil
live_loop :midi_games do
  use_real_time
  value = sync "/midi:*/*"
  if value.length() == 2
    if not sound == nil
      control sound, note: 0
      control sound, amp: 0
    end
    sound = synth :tri, note: value[0], amp: value[1] / 127.0
  end
end