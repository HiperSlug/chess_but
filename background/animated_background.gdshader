shader_type canvas_item;
// from: https://www.shadertoy.com/view/tdG3Rd
//uniform float iResolution = (1.0 / SCREEN_PIXEL_SIZE);

/* Effects for mat2 */
uniform float stretch : hint_range(0.0, 100.0, 0.1) = 0.8;
uniform float thing1 : hint_range(0.0, 100.0, 0.1) = 0.6;
uniform float thing2 : hint_range(0.0, 100.0, 0.1) = 0.6;
uniform float thing3 : hint_range(0.0, 100.0, 0.1) = 0.8;
/* Effects for scale and speed */
uniform float scale : hint_range(0.000, 100.0, 0.001) = 1.0;


vec4 colormap(float x) {
    vec3 color_start = vec3(24.0 / 255.0, 100.0 / 255.0, 132.0 / 255.0);
    vec3 color_end = vec3(1.0); // #ffffff
    vec3 color = mix(color_start, color_end, clamp(x, 0.0, 1.0));
    return vec4(color, 1.0);
}

// https://iquilezles.org/articles/warp
/*float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float a = textureLod(iChannel0,(p+vec2(0.5,0.5))/256.0,0.0).x;
	float b = textureLod(iChannel0,(p+vec2(1.5,0.5))/256.0,0.0).x;
	float c = textureLod(iChannel0,(p+vec2(0.5,1.5))/256.0,0.0).x;
	float d = textureLod(iChannel0,(p+vec2(1.5,1.5))/256.0,0.0).x;
    return mix(mix( a, b,f.x), mix( c, d,f.x),f.y);
}*/


float rand(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u*u*(3.0-2.0*u);

    float res = mix(
        mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
        mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
    return res*res;
}

// OG stuff here:
// const mat2 mtx = mat2( vec2(0.80,  0.60), vec2(-0.60,  0.80) );

float fbm( vec2 p )
{
    float f = 0.0;
    mat2 mtx = mat2( vec2(stretch,  thing1), vec2(-thing2,  thing3) );
    f += 0.500000*noise( p + TIME  ); p = mtx*p*2.02;
    f += 0.031250*noise( p ); p = mtx*p*2.01;
    f += 0.250000*noise( p ); p = mtx*p*2.03;
    f += 0.125000*noise( p ); p = mtx*p*2.01;
    f += 0.062500*noise( p ); p = mtx*p*2.04;
    f += 0.015625*noise( p + sin(TIME) );

    return f/0.96875;
}

float pattern( in vec2 p )
{
	return fbm( p + fbm( p + fbm( p ) ) );
}

void fragment()
{
    //vec2 uv = FRAGCOORD.xy / (0.01 / SCREEN_PIXEL_SIZE).x;
    vec2 uv = FRAGCOORD.xy / (scale / SCREEN_PIXEL_SIZE).y;
	float shade = pattern(uv);
    COLOR = vec4(colormap(shade).rgb, shade);
}

