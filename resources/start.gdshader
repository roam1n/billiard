shader_type canvas_item;

float udHorizontalSegment( in vec2 p, in float xa, in float xb, in float y )
{
    vec2 pa = p - vec2(xa,y);
    float ba = xb - xa;
    pa.x -= ba*clamp( pa.x/ba, 0.0, 1.0 );
    return length( pa );
}

void fragment() {
	float f = abs(abs(UV.x)-1.02);
    f = min( f, udHorizontalSegment(UV,-1.0,1.0,1.0) );
	f *= 2.0;
	//float a = 0.8 + 0.2*sin(2.6*TIME) + 0.1*sin(4.0*TIME);
	vec3 col = 0.5*vec3(0.6,0.30,0.1)*exp(-30.0*f*f);
	//col += a*0.5*vec3(0.6,0.30,0.1)*exp(-30.0*f*f);
    //col = 0.6*vec3(0.4,0.6,0.7)*(1.0-0.4*length( UV ));
    //col *= 1.0 - 0.1*smoothstep( 0.0,1.0,sin(UV.x*80.0)*sin(UV.y*80.0))*(1.0 - smoothstep( 1.0, 1.01, abs(UV.x) ) );
	//COLOR = vec4(col, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
