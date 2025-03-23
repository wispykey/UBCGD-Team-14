shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Red color
uniform float border_width : hint_range(0.0, 10.0) = 0.5; // Border width in pixels

void fragment() {
         // Calculate the pixel size based on the texture dimensions
    vec2 texture_size = vec2(textureSize(TEXTURE, 0));
    vec2 pixel_size = vec2(1.0) / texture_size;

    // Calculate the border area in UV space
    float border_left = step(border_width * pixel_size.x, UV.x); // Left edge
    float border_right = step(border_width * pixel_size.x, 1.0 - UV.x); // Right edge
    float border_top = step(border_width * pixel_size.y, UV.y); // Top edge
    float border_bottom = step(border_width * pixel_size.y, 1.0 - UV.y); // Bottom edge

    // Combine the edges to create a hollow border
    float is_border = 1.0 - (border_left * border_right * border_top * border_bottom);

    // Apply the border color only to the border area
    COLOR = mix(texture(TEXTURE, UV), border_color, is_border);
}