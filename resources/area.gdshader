shader_type canvas_item;

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

void fragment() 
{
	vec2 uv = (UV - vec2(0.5, 0.5)) * 2.0;
	float len = length(uv);
	float d = sdBox(uv, vec2(0.7));

	COLOR = vec4(0.8,0.7,0.9, d);
}
