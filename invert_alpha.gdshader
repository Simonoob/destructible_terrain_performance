shader_type canvas_item;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV).rgba;
	
	COLOR = vec4(original_color.r, original_color.g, original_color.b, 1.0 - original_color.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
