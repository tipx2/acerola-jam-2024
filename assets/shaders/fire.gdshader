shader_type canvas_item;

uniform sampler2D textureNoise: repeat_enable;
uniform float radius: hint_range(0.0, 1.0) = 0.459;
uniform float effectControl: hint_range(0.0, 1.0) = 0.309;
uniform float burnSpeed: hint_range(0.0, 1.0) = 0.076;
uniform float shape: hint_range(0.0, 1.0) = 1.0;

uniform float brightness : hint_range(-1, 1) = 0;
uniform float contrast : hint_range(0, 3) = 1.0;
uniform float saturation : hint_range(0, 3) = 1.0;

uniform float redVal : hint_range(0, 1) = 1.0;
uniform float greenVal : hint_range(0, 1) = 1.0;
uniform float blueVal : hint_range(0, 1) = 1.0;

uniform vec4 tint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_effect_factor : hint_range(0, 1) = 0.0;
//---------------------------------------------
//CONTRAST
//---------------------------------------------
mat4 contrastMatrix( float _contrast ){
	float t = ( 1.0 - _contrast ) / 2.0;
    return mat4( 
		vec4(_contrast, 0, 0, 0),
		vec4(0, _contrast, 0, 0),
		vec4(0, 0, _contrast, 0),
		vec4(t, t, t, 1));
}
//---------------------------------------------
//BRIGHTNESS
//---------------------------------------------
mat4 brightnessMatrix( float _brightness ){
    return mat4( vec4(1, 0, 0, 0),
                 vec4(0, 1, 0, 0),
                 vec4(0, 0, 1, 0),
                 vec4(_brightness, _brightness, _brightness, 1));
}
//---------------------------------------------
//SATURATION
//---------------------------------------------
mat4 saturationMatrix( float _saturation ){
    vec3 luminance = vec3( 0.3086, 0.6094, 0.0820 );
    float oneMinusSat = 1.0 - _saturation;
	
    vec3 red = vec3( luminance.x * oneMinusSat );
    red+= vec3(_saturation, 0, 0)*redVal;
    vec3 green = vec3( luminance.y * oneMinusSat );
    green += vec3( 0,_saturation, 0 )*greenVal;
    vec3 blue = vec3( luminance.z * oneMinusSat );
    blue += vec3( 0, 0,_saturation )*blueVal;
	
    return mat4(vec4(red, 0),vec4(green,0),vec4(blue,0),vec4(0, 0, 0, 1));
}


void fragment() {
    vec2 centerDistVec = vec2(0.5) - UV;
    
	float distToCircleEdge = length(centerDistVec) * radius;
	float distToSquareEdge = 0.5*(0.5 - min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
	float distToEdge = mix(distToCircleEdge,distToSquareEdge,shape);

    float gradient = smoothstep(0.5, 0.5 - radius, distToEdge);

    vec2 direction = vec2(0, 1) * burnSpeed;
    float noiseValue = texture(textureNoise, UV + direction * TIME).r;

    float opacity = step(radius, mix(gradient, noiseValue, effectControl) - distToEdge);
	
	vec4 c = texture(TEXTURE, UV);
	vec4 c2 = c * tint_color;
	COLOR = brightnessMatrix( brightness ) * contrastMatrix( contrast ) *saturationMatrix( saturation ) * mix(c, c2, tint_effect_factor) * vec4(1.0, 1.0, 1.0, opacity);

}
