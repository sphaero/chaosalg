#version 150

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 textureMatrix;
uniform mat4 modelViewProjectionMatrix;

in vec4 position;
in vec4 color;
in vec3 normal;
in vec2 texcoord;
// this is the end of the default functionality

out vec4 var_color;
out vec2 var_texcoord;
out vec3 var_position;
out vec3 var_normal;

uniform vec3 lightPos;

void main() {
    vec4 vert_pos = position;
    vec3 l_pos = normalize(vec3(-lightPos.xz, lightPos.y));
    gl_Position = modelViewProjectionMatrix * position;
    vec3 n_normal = normalize(normal);
    vec3 col = vec3(0.05,0.21,0.45);
    col -= -(1.0-pow(abs(normal.y),0.5))*0.9*vec3(0.8,0.8,0.9) + 0.075;
    float sun = clamp( dot(l_pos,normal), 0.0, 1.0 );
    col += 0.2*vec3(1.0,.8,0.5)*pow( sun, 8.0 );
    // sun glare
    col += 0.1*vec3(.9,0.4,0.2)*pow( sun, 3.0 );
    
    var_color = vec4(col,1);
    //var_color = vec4(abs(n_normal.y),0,0,1);
    var_position = position.xyz;
    var_normal = normal;
}
