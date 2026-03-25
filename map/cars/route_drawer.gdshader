shader_type canvas_item;

uniform sampler2D line_texture; // the texture to display
//uniform ivec2 line_texture_size; // how large the texture will appear on screen
uniform float scale = 10.0;
uniform float speed = 0.5;

void fragment() 
{
	/*ivec2 pixel_position = ivec2(SCREEN_UV / SCREEN_PIXEL_SIZE);
	vec2 local_pixel_position = vec2(float(pixel_position.x % line_texture_size.x), float(pixel_position.y % line_texture_size.y));
	vec2 texture_uv = local_pixel_position / vec2(line_texture_size);
	float uv_animated_x = texture_uv.x + speed*TIME;
	float uv_animated_y = texture_uv.y - sin(speed*TIME);
	texture_uv.x = uv_animated_x - floor(uv_animated_x);
	texture_uv.y = uv_animated_y - floor(uv_animated_y);*/
	
	float uv_x = (UV.x + speed*TIME) / scale;
	float uv_x_clamped = uv_x - floor(uv_x);
	vec2 uv = vec2(uv_x_clamped, UV.y);
	vec4 color_tex = texture(line_texture, uv);
	float center_dist = abs(UV.y - 0.5) * 2.0;
	vec4 color_base = COLOR; // from modulation and stuff
	color_base.a = round(mix(1.0, color_tex.r, center_dist));
	COLOR = color_base;
}