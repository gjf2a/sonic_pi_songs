run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

define :midi_drone_loop do |note_maker, drone_note, drone_maker, drone_amp_scaling|
  live_loop :midi_fun do
    use_real_time
    note, velocity = sync "/midi:*/note_on"
    amp = velocity / 127.0
    method(note_maker).call(note, amp)
    method(drone_maker).call(drone_note, amp * drone_amp_scaling)
  end
end

midi_drone_loop :cool_tri, :D3, :additive_1, 0.3