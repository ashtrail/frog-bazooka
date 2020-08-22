extends Sprite

func init(pos, img, flip = false, z_offset = 0):
	add_to_group('corpses')
	position = pos
	texture = img
	z_index += z_offset
	if flip:
		flip_h = true
