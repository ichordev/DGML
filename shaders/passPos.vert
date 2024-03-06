$input a_position

#include "bgfx_shader.sc"

void main(){
	gl_Position = mul(u_modelViewProj, vec4(a_position.xyz, 1.0));
}
