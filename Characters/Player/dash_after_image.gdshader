shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float gray = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
    vec3 final_rgb = mix(tex_color.rgb, vec3(gray), 0.6);
    
    COLOR = vec4(final_rgb, tex_color.a);
}