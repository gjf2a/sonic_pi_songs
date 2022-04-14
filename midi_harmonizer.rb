run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

define :midi_harmonizer_loop do |note_maker, scale, interval|
  live_loop :midi_fun do
    use_real_time
    note, velocity = sync "/midi:*/note_on"
    amp = velocity / 127.0
    method(note_maker).call(note, amp)
    method(note_maker).call(harmonize(note, scale, interval), amp)
  end
end

midi_harmonizer_loop :additive_1, scale(:g3, :major, num_octaves: 4), 3