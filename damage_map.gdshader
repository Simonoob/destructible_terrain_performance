shader_type canvas_item;

uniform sampler2D destruction_mask : hint_default_white;

void fragment() {
	
	vec4 original_color = texture(TEXTURE, UV).rgba;
	vec4 destruction_map_color = texture(destruction_mask, UV).rgba;
	
	COLOR = destruction_map_color;
	
	COLOR = vec4(original_color.r, original_color.g, original_color.b, original_color.a - destruction_map_color.a);
	//COLOR = vec4(destruction_map_color.r, destruction_map_color.g, destruction_map_color.b, destruction_map_color.a);
	
}
