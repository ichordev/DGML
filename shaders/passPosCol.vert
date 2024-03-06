$input a_position, a_color0
$output v_colour0

#include "bgfx_shader.sc"

void main(){
	gl_Position = mul(u_modelViewProj, vec4(a_position.xyz, 1.0));
	
	v_colour0 = a_color0;
}
