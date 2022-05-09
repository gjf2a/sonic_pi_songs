# Welcome to Sonic Pi
run_file "~/Documents/sonic_pi_songs/my_funcs.rb"

# An example sample from the electric mandolin
melody = [[62, 0.3480220000000145, 1.0], [64, 0.40819799999999873, 1.0],
          [66, 0.6728009999999927, 0.7716535433070866],
          [62, 0.09306399999999826, 0.05511811023622047],
          [62, 0.3781940000000077, 0.8661417322834646],
          [64, 0.0594300000000203, 0.16535433070866143],
          [64, 0.34025199999999245, 1.0], [66, 0.034609999999986485, 0.2204724409448819],
          [66, 0.624875000000003, 0.8661417322834646], [62, 0.05510300000000257, 0.05511811023622047],
          [62, 0.3685430000000167, 1.0], [64, 0.020217000000002372, 0.7559055118110236],
          [76, 0.012788000000000466, 0.7716535433070866], [64, 0.3065780000000018, 0.7480314960629921],
          [65, 0.05111600000000749, 0.5039370078740157], [66, 0.28751700000000824, 0.9763779527559056],
          [64, 0.020072999999996455, 0.6377952755905512], [76, 0.012823000000025786, 0.6456692913385826], [76, 0.00020499999999401552, 0.0],
          [64, 0.3384279999999933, 0.6141732283464567], [62, 0.42017900000001873, 0.8110236220472441],
          [64, 0.3244940000000156, 0.7795275590551181], [62, 0.3526819999999873, 1.0],
          [60, 0.37663499999999317, 0.6377952755905512], [62, 1.5233110000000067, 0.7559055118110236]]

melody_scale = scale(50, :mixolydian, num_octaves: 4)

puts scale_names
puts melody_scale

define :bump do |dict, key, amount|
  if dict[key] == nil
    dict[key] = 0
  end
  dict[key] += amount
end

define :count do |dict, key|
  if dict[key] == nil
    return 0
  else
    return dict[key]
  end
end

define :melody_note_count do |melody|
  counts = {}
  melody.length.times do |i|
    bump counts, melody[i][0], melody[i][1]
  end
  return counts.sort_by {|c| -c[1]}
end

count_demo = melody_note_count(melody)
print count_demo
lo, hi = count_demo.minmax.map {|m| m[0]}
print lo, hi

define :deepest_root do |root, lo|
  while root > lo do
    root -= 12
  end
  return root
end

define :num_octaves do |root, hi|
  return ((hi - root) / 12.0).ceil + 1
end

root = deepest_root(count_demo[0][0], lo)
print num_octaves(root, hi)

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

print "mixo", num_missing_melody_notes(melody, melody_scale)
print "major", num_missing_melody_notes(melody, scale(50, :major, num_octaves: 4))


# Not quite. I still need to sort them based on similarity to the
# melody notes, then return the best one.
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

print candidate_scales_for(melody).length
print best_scales_for(melody)