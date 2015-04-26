#version 150
//#extension GL_EXT_gpu_shader4 : enable

uniform int phase;
uniform int subdiv;
uniform float seed = 12.9898;
uniform float fog_depth = 10.0;

const int a = 1140671485;
const int c = 128201163;
const int m = 16777216;
const float PI = 3.14159265358979323846264;

// these are for the programmable pipeline system and are passed in
// by default from OpenFrameworks
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

// begin helper methods
float sin_n(float val) {
    return sin(val*62.8)*0.5+0.5;
} 

float cos_n(float val) {
    return cos(val*62.8)*0.5+0.5;
}

float lmix( const float a, const float b, const float t ) {
    return a * ( 1 - t ) + b * t;
}
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(seed,78.233))) * 43758.5453);
}

float ip_rand(vec2 co, float step) {
    vec2 c00 = floor(vec2(co*step))/step;
    vec2 c11 = c00 + vec2(1/step);//ceil(vec2(co*step))/step;
    vec2 c01 = vec2(c00.x, c11.y);
    vec2 c10 = vec2(c11.x, c00.y);
    return rand(c00);
}

float lip_rand(vec2 co, float step) {
    vec2 c00 = floor(vec2(co*step))/step;
    vec2 c11 = ceil(vec2(co*step))/step;
    vec2 c01 = vec2(c00.x, c11.y);
    vec2 c10 = vec2(c11.x, c00.y);
    // random values for the corners
    float rc00 = rand(c00);
    float rc11 = rand(c11);
    float rc01 = rand(c01);
    float rc10 = rand(c10);

    float tx = (co.x - c00.x)*step;
    float ty = (co.y - c00.y)*step;
    
    /// Linearly interpolate values along the x axis float 
    float nx0 = lmix( rc00, rc10, tx ); 
    float nx1 = lmix( rc01, rc11, tx ); 
    /// Linearly interpolate the nx0/nx1 along the y axis 
    float ny = mix( nx0, nx1, ty );
    return ny;
}

float slip_rand(vec2 co, float step) {
    vec2 c00 = floor(vec2(co*step))/step;
    vec2 c11 = ceil(vec2(co*step))/step;
    vec2 c01 = vec2(c00.x, c11.y);
    vec2 c10 = vec2(c11.x, c00.y);
    // random values for the corners
    float rc00 = rand(c00);
    float rc11 = rand(c11);
    float rc01 = rand(c01);
    float rc10 = rand(c10);

    float tx = (co.x - c00.x)*step;
    float txRemapCosine = ( 1 - cos( tx * PI ) ) * 0.5;
    float ty = (co.y - c00.y)*step;
    float tyRemapCosine = ( 1 - cos( ty * PI ) ) * 0.5;
    
    /// Linearly interpolate values along the x axis float 
    float nx0 = lmix( rc00, rc10, txRemapCosine ); 
    float nx1 = lmix( rc01, rc11, txRemapCosine ); 
    /// Linearly interpolate the nx0/nx1 along the y axis 
    float ny = mix( nx0, nx1, tyRemapCosine );
    return ny;
}

vec3 calc_normal(vec3 _ngb1, vec3 _ngb2, vec3 _ngb3) {
    vec3 tangent = _ngb1 - _ngb3;
    vec3 bitangent = _ngb2 - _ngb3;
    return normalize(cross(tangent, bitangent));
    
    //return normalize(cross(_ngb2 - _ngb1, _ngb3 - _ngb1));
}

vec3 calc_quad_normal(vec3 v1, vec3 v2, vec3 v3, vec3 v4)
{
    vec3 norm1 = normalize(cross((v2-v1), (v3-v1)));
    vec3 norm2 = normalize(cross((v3-v4), (v4-v1)));
    return normalize((norm1 + norm2) * 0.5f);
}

// the most simple random number generator
/*int lcg(int seed) {
    seed = (a*seed + c) % m;
    return seed;
}*/

// normalise the random numbers between 0-1.0
float lcg_norm(int val) {
    return sin(val) * 0.1;
}

vec4 normal_to_color(vec3 normal) {
    return vec4((normal + vec3(1))/2., 1.0);
}
// end helper methods

void simple_line() {
    // just a line
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    // scale y axis
    vert_pos.y *= 0.01;
    //vert_pos.y += 0.5;
    // just a small z addition to make sure we have a visible line
    vert_pos.z += vert_pos.y*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color;
    var_normal = normal;
}

void sinus_line() {
    // a sinus line
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    // scale y axis
    vert_pos.y *= 0.01;
    //vert_pos.y += 0.5;
    vert_pos.z = sin_n(vert_pos.x)*0.05;
    // just a small z addition to make sure we have a visible line
    vert_pos.z += vert_pos.y*0.2;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
    // normal from sinus
    var_normal = normalize(vec3(abs(cos(vert_pos.x*31))*0.5, normal.y, abs(sin(vert_pos.x*31))*0.5+0.5));
}

void sinus_3d() {
    // a sinus in 3d 
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = sin_n(vert_pos.x)*0.05;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
    // normal from sinus
    var_normal = normalize(vec3(abs(cos(vert_pos.x*31))*0.5, normal.y, abs(sin(vert_pos.x*31))*0.5+0.5));
}

void sinus_x_y() {
    // sinus on x and y
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = (sin_n(vert_pos.x) * sin_n(vert_pos.y))*0.05;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
    //var_normal = vec3(1, cos(vert_pos.x*31)/sqrt(1+(pow(cos(vert_pos.x*31), 2))), 0);
    var_normal = normalize(vec3(abs(cos(vert_pos.x*31))*0.5, abs(-cos(vert_pos.x*31))*0.5, abs(sin(vert_pos.x*31))*0.5+0.5));
}

void phase4() {
    // back to a simple sinus line
    sinus_line();
}

void noise_line() {
    // introduce random generator (noise)
    vec4 vert_pos = position;
    // scale y axis
    vert_pos.y *= 0.0000001;
    vert_pos.z = rand(vert_pos.xy)*0.05;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
    var_normal = normal;
}

void noise_3d() {
    // random generator in 3d
    vec4 vert_pos = position;
    vert_pos.z = rand(vert_pos.xy)*0.05;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
    var_normal = normal;
}

void noise_3d_step() {
    // random generator stepping
    vec4 vert_pos = position;
    vert_pos.z = ip_rand(vert_pos.xy, 16)*0.05;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
    var_normal = normal;
}

void noise_3d_interpol() {
    // random generator stepping linear interpolation
    vec4 vert_pos = position;
    vert_pos.z = lip_rand(vert_pos.xy, 16)*0.05;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
    var_normal = normal;
}

void noise_3d_sin_interpol() {
    // random generator stepping sinus interpolation
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.05;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
    var_normal = normal;
}

void landscape_normal() {
    // random generator stepping sinus interpolation
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.05;
    
    // calculate correct normal
    vec3 ngb1 = vert_pos.xyz;
    ngb1.xy += vec2(1.0/subdiv, 0.0);
    vec3 ngb2 = vert_pos.xyz;
    ngb2.xy += vec2(0.0, 1.0/subdiv);
    vec3 ngb3 = vert_pos.xyz;
    ngb3.xy += vec2(-1.0/subdiv, 0);
    vec3 ngb4 = vert_pos.xyz;
    ngb4.xy += vec2(0, -1.0/subdiv);

    ngb1.z = slip_rand(ngb1.xy, 16)*0.05;
    ngb2.z = slip_rand(ngb2.xy, 16)*0.05;
    ngb3.z = slip_rand(ngb3.xy, 16)*0.05;
    ngb4.z = slip_rand(ngb4.xy, 16)*0.05;
    var_normal = calc_quad_normal(ngb1, ngb2, ngb3, ngb4);
    
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
}

void landscape_normal_detail() {
    // random generator stepping sinus interpolation + detail
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.05;
    vert_pos.z += slip_rand(vert_pos.xy, 64)*0.01;

    // calculate correct normal
    vec3 ngb1 = vert_pos.xyz;
    ngb1.xy += vec2(1.0/subdiv, 0.0);
    vec3 ngb2 = vert_pos.xyz;
    ngb2.xy += vec2(0.0, 1.0/subdiv);
    vec3 ngb3 = vert_pos.xyz;
    ngb3.xy += vec2(-1.0/subdiv, 0);
    vec3 ngb4 = vert_pos.xyz;
    ngb4.xy += vec2(0, -1.0/subdiv);

    ngb1.z = slip_rand(ngb1.xy, 16)*0.05;
    ngb1.z += slip_rand(ngb1.xy, 64)*0.01;
    ngb2.z = slip_rand(ngb2.xy, 16)*0.05;
    ngb2.z += slip_rand(ngb2.xy, 64)*0.01;
    ngb3.z = slip_rand(ngb3.xy, 16)*0.05;
    ngb3.z += slip_rand(ngb3.xy, 64)*0.01;
    ngb4.z = slip_rand(ngb4.xy, 16)*0.05;
    ngb4.z += slip_rand(ngb4.xy, 64)*0.01;
    var_normal = calc_quad_normal(ngb1, ngb2, ngb3, ngb4);

    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
}

void landscape_normal_detail_height() {
    // random generator stepping sinus interpolation + detail
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.05;
    vert_pos.z += slip_rand(vert_pos.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) vert_pos.z += slip_rand(vert_pos.xy, 512)*0.001;

    // calculate correct normal
    vec3 ngb1 = vert_pos.xyz;
    ngb1.xy += vec2(1.0/subdiv, 0.0);
    vec3 ngb2 = vert_pos.xyz;
    ngb2.xy += vec2(0.0, 1.0/subdiv);
    vec3 ngb3 = vert_pos.xyz;
    ngb3.xy += vec2(-1.0/subdiv, 0);
    vec3 ngb4 = vert_pos.xyz;
    ngb4.xy += vec2(0, -1.0/subdiv);

    ngb1.z = slip_rand(ngb1.xy, 16)*0.05;
    ngb1.z += slip_rand(ngb1.xy, 64)*0.01;
    if ( ngb1.z > 0.03) ngb1.z += slip_rand(ngb1.xy, 512)*0.001;
    //ngb1.z += lip_rand(ngb1.xy, 32)*0.05;
    ngb2.z = slip_rand(ngb2.xy, 16)*0.05;
    ngb2.z += slip_rand(ngb2.xy, 64)*0.01;
    if ( ngb2.z > 0.03) ngb2.z += slip_rand(ngb2.xy, 512)*0.001;
    //ngb2.z += lip_rand(ngb2.xy, 32)*0.05;
    ngb3.z = slip_rand(ngb3.xy, 16)*0.05;
    ngb3.z += slip_rand(ngb3.xy, 64)*0.01;
    if ( ngb3.z > 0.03) ngb3.z += slip_rand(ngb3.xy, 512)*0.001;
    //ngb3.z += lip_rand(ngb3.xy, 32)*0.05;
    ngb4.z = slip_rand(ngb4.xy, 16)*0.05;
    ngb4.z += slip_rand(ngb4.xy, 64)*0.01;
    if ( ngb4.z > 0.03) ngb4.z += slip_rand(ngb4.xy, 512)*0.001;
    //var_normal = calc_normal(ngb1.xyz, ngb2.xyz, ngb3.xyz);
    var_normal = calc_quad_normal(ngb1, ngb2, ngb3, ngb4);

    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*20),1);
    var_position = vert_pos.xyz;
}

void landscape_fog() {
    // random generator stepping sinus interpolation + detail
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.05;
    vert_pos.z += slip_rand(vert_pos.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) vert_pos.z += slip_rand(vert_pos.xy, 512)*0.001;

    // calculate correct normal
    vec3 ngb1 = vert_pos.xyz;
    ngb1.xy += vec2(1.0/subdiv, 0.0);
    vec3 ngb2 = vert_pos.xyz;
    ngb2.xy += vec2(0.0, 1.0/subdiv);
    vec3 ngb3 = vert_pos.xyz;
    ngb3.xy += vec2(-1.0/subdiv, 0);
    vec3 ngb4 = vert_pos.xyz;
    ngb4.xy += vec2(0, -1.0/subdiv);

    ngb1.z = slip_rand(ngb1.xy, 16)*0.05;
    ngb1.z += slip_rand(ngb1.xy, 64)*0.01;
    if ( ngb1.z > 0.03) ngb1.z += slip_rand(ngb1.xy, 512)*0.001;
    //ngb1.z += lip_rand(ngb1.xy, 32)*0.05;
    ngb2.z = slip_rand(ngb2.xy, 16)*0.05;
    ngb2.z += slip_rand(ngb2.xy, 64)*0.01;
    if ( ngb2.z > 0.03) ngb2.z += slip_rand(ngb2.xy, 512)*0.001;
    //ngb2.z += lip_rand(ngb2.xy, 32)*0.05;
    ngb3.z = slip_rand(ngb3.xy, 16)*0.05;
    ngb3.z += slip_rand(ngb3.xy, 64)*0.01;
    if ( ngb3.z > 0.03) ngb3.z += slip_rand(ngb3.xy, 512)*0.001;
    //ngb3.z += lip_rand(ngb3.xy, 32)*0.05;
    ngb4.z = slip_rand(ngb4.xy, 16)*0.05;
    ngb4.z += slip_rand(ngb4.xy, 64)*0.01;
    if ( ngb4.z > 0.03) ngb4.z += slip_rand(ngb4.xy, 512)*0.001;
    //var_normal = calc_normal(ngb1.xyz, ngb2.xyz, ngb3.xyz);
    var_normal = calc_quad_normal(ngb1, ngb2, ngb3, ngb4);

    gl_Position = modelViewProjectionMatrix * vert_pos;
    float fog_val = clamp(gl_Position.z/10, 0.0, 1.0);
    var_color = color * vec4(vert_pos.z*20, fog_val, 0, 1);
    var_position = vert_pos.xyz;
}

void main()
{	
    switch (phase) {
        
        case 21:
            landscape_fog();
            break;
        case 20:
        case 19:
        case 18:
        case 17:
        case 16:
        case 15:
        case 14: // add noise texture sinus interpolation
        case 13: // add noise texture linear interpolation// add noise texture stepping
                 // add noise texture
        case 12: 
            landscape_normal_detail_height();
            break;
        case 11: 
            landscape_normal_detail();
            break;
        case 10:
            landscape_normal();
            break;
        case 9:
            noise_3d_sin_interpol();
            break;
        case 8:
            noise_3d_interpol();
            break;
        case 7:
            noise_3d_step();
            break;
        case 6:
            noise_3d();
            break;
        case 5:
            noise_line();
            break;
        case 4:
            simple_line();
            break;
        case 3:
            sinus_x_y();
            break;
        case 2:
            sinus_3d();
            break;
        case 1:
            sinus_line();
            break;
        default:
            simple_line();
            break;
    }
    var_texcoord = texcoord;
}
