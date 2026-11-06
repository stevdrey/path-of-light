shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform vec2 focus = vec2(0.5, 0.5);
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 aspect = vec2(SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0);
	vec2 delta = (SCREEN_UV - focus) * aspect;
	float radius = length(delta);
	float influence = 1.0 - smoothstep(0.03, 0.168, radius);
	float angle = 2.5 * intensity * influence;
	mat2 rotation = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	vec2 warped = focus + (rotation * delta) / aspect;
	vec3 scene = texture(screen_texture, clamp(warped, vec2(0.001), vec2(0.999))).rgb;
	float streak = pow(max(0.0, sin(atan(delta.y, delta.x) * 3.0 - radius * 28.0 + intensity * 5.0)), 8.0);
	scene += vec3(0.12, 0.36, 0.55) * streak * influence * intensity;
	COLOR = vec4(scene, intensity * influence);
}
