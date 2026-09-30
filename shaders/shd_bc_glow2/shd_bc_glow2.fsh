varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform float u_para;
void main() {
vec4 c = texture2D(gm_BaseTexture, v_vTexcoord);
c.a *= u_para * v_vColour.a;
c.rgb = (1.0 - c.a) + c.rgb * c.a;
gl_FragColor = c;
}