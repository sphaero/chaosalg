#version 150
// these are for the programmable pipeline system and are passed in
// by default from OpenFrameworks
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 textureMatrix;
uniform mat4 modelViewProjectionMatrix;

// input
in vec4 var_color;
in vec2 var_texcoord;
in vec3 var_normal;
in vec3 var_position;

uniform vec3 lightPos;
//output
out vec4 outputColor;

void main() {
    //outputColor.a = 1.0;
    vec3 color = var_color.rgb;
    vec3 l_pos = normalize(vec3(-lightPos.xz, lightPos.y));
    float sun = clamp( dot(l_pos,normalize(var_normal)), 0.0, 1.0 );
    color += 0.75*vec3(1.0,.8,0.5)*pow( sun, 512.0 );
    outputColor = vec4(color,1);
}
