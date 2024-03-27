shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D Normal_map : hint_normal, filter_nearest, repeat_disable;



void fragment() {
	vec4 n_out4p0;
// Texture2D:4
	n_out4p0 = texture(Normal_map, UV);


// Output:0
	NORMAL_MAP = vec3(n_out4p0.xyz);
	NORMAL_MAP_DEPTH = n_out4p0.x;


}
