shader_type canvas_item;


uniform vec3 custom_color = vec3(1.0, 1.0, 1.0);
//vec3 palette( in float t)
//{
	//vec3 a = vec3(-0.012, 0.148, 0.758);
	//vec3 b = vec3(0.158, 0.128, -0.062);
	//vec3 c = vec3(1.00, 1.00, 1.00);
	//vec3 d = vec3(0.000, 0.333, 0.667);
    //return a + b*cos( 6.28318*(c*t+d) );
//}

float sdCircle(vec2 p, float r)
{
	return (r/2. - abs(length(p) - r/2.))*2.;
}

void fragment()
{
	vec2 uv = (UV - vec2(0.5, 0.5)) * 2.0;
	float len = length(uv);
	float d = sdCircle(uv, 1.);
	d = smoothstep(0.7, 0.99 , d);
	//if (len < 0.36) {
		//d = log(16.0*(0.3-len)+1.)/4.0;
	//} else if (len > 0.58 && len < 1.0) {
		//d = (exp(0.9 - len)*0.5 - 0.);
	//}
 
	COLOR = vec4(custom_color, d);
}
