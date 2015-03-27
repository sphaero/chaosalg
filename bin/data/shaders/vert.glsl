#version 150
#extension GL_EXT_gpu_shader4 : enable

uniform int phase;
uniform int subdiv;

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

float sin_n(float val) {
    return sin(val*31)*0.5+0.5;
} 

float cos_n(float val) {
    return cos(val*31)*0.5+0.5;
}

float lmix( const float a, const float b, const float t ) {
    return a * ( 1 - t ) + b * t;
}
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
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
int lcg(int seed) {
    seed = (a*seed + c) % m;
    return seed;
}

// normalise the random numbers between 0-1.0
float lcg_norm(int val) {
    return sin(val) * 0.1;
}


void phase0() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    // scale y axis
    vert_pos.y *= 0.01;
    //vert_pos.y += 0.5;
    // just a small z addition to make sure we have a visible line
    vert_pos.z += vert_pos.y*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color;
}

void phase1() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    // scale y axis
    vert_pos.y *= 0.01;
    //vert_pos.y += 0.5;
    vert_pos.z = sin_n(vert_pos.x)*0.1;
    // just a small z addition to make sure we have a visible line
    vert_pos.z += vert_pos.y*0.2;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color;
}

void phase2() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = sin_n(vert_pos.x)*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color;
}

void phase3() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = sin_n(vert_pos.x)*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase4() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = (sin_n(vert_pos.x) * sin_n(vert_pos.y))*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase5() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = (sin_n(vert_pos.x) * cos_n(vert_pos.y))*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase6() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    // scale y axis
    vert_pos.y *= 0.01;
    vert_pos.z = sin_n(vert_pos.x)*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase7() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    // scale y axis
    vert_pos.y *= 0.0000001;
    vert_pos.z = rand(vert_pos.xy)*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase8() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = rand(vert_pos.xy)*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase9() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = ip_rand(vert_pos.xy, 16)*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase10() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = lip_rand(vert_pos.xy, 16)*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase11() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.1;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase12() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.1;
    vert_pos.z += rand(vert_pos.xy)*0.001;
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase17() {
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.1;
    vert_pos.z += slip_rand(vert_pos.xy, 64)*0.03; //deze levert ellende met licht vast door afwijking in normals
    
    vec3 ngb1 = vert_pos.xyz;
    ngb1.xy += vec2(1.0/subdiv, 0.0);
    vec3 ngb2 = vert_pos.xyz;
    ngb2.xy += vec2(0.0, 1.0/subdiv);
    vec3 ngb3 = vert_pos.xyz;
    ngb3.xy += vec2(-1.0/subdiv, 0);
    vec3 ngb4 = vert_pos.xyz;
    ngb4.xy += vec2(0, -1.0/subdiv);
    /*
    vec3 ngb1 = vec3(0);
    ngb1.xy = vert_pos.xy + vec2(1/1024.0, 0.00);
    vec3 ngb2 = vec3(0);
    ngb2.xy = vert_pos.xy + vec2(0.0, 1/1024.0);
    vec3 ngb3 = vec3(0);
    ngb3.xy = vert_pos.xy + vec2(-.707/1024.0, -.707/1024.0);
    */
    ngb1.z = slip_rand(ngb1.xy, 16)*0.1;
    ngb1.z += slip_rand(ngb1.xy, 64)*0.03;
    //ngb1.z += lip_rand(ngb1.xy, 32)*0.05;
    ngb2.z = slip_rand(ngb2.xy, 16)*0.1;
    ngb2.z += slip_rand(ngb2.xy, 64)*0.03;
    //ngb2.z += lip_rand(ngb2.xy, 32)*0.05;
    ngb3.z = slip_rand(ngb3.xy, 16)*0.1;
    ngb3.z += slip_rand(ngb3.xy, 64)*0.03;
    //ngb3.z += lip_rand(ngb3.xy, 32)*0.05;
    ngb4.z = slip_rand(ngb4.xy, 16)*0.1;
    ngb4.z += slip_rand(ngb4.xy, 64)*0.03;
    //var_normal = calc_normal(ngb1.xyz, ngb2.xyz, ngb3.xyz);
    var_normal = calc_quad_normal(ngb1, ngb2, ngb3, ngb4);
    
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase18() {
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.05;
    vert_pos.z += slip_rand(vert_pos.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) vert_pos.z += slip_rand(vert_pos.xy, 512)*0.001;
    
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
    if ( vert_pos.z > 0.03) ngb1.z += slip_rand(ngb1.xy, 512)*0.001;
    //ngb1.z += lip_rand(ngb1.xy, 32)*0.05;
    ngb2.z = slip_rand(ngb2.xy, 16)*0.05;
    ngb2.z += slip_rand(ngb2.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) ngb2.z += slip_rand(ngb2.xy, 512)*0.001;
    //ngb2.z += lip_rand(ngb2.xy, 32)*0.05;
    ngb3.z = slip_rand(ngb3.xy, 16)*0.05;
    ngb3.z += slip_rand(ngb3.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) ngb3.z += slip_rand(ngb3.xy, 512)*0.001;
    //ngb3.z += lip_rand(ngb3.xy, 32)*0.05;
    ngb4.z = slip_rand(ngb4.xy, 16)*0.05;
    ngb4.z += slip_rand(ngb4.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) ngb4.z += slip_rand(ngb4.xy, 512)*0.001;
    //var_normal = calc_normal(ngb1.xyz, ngb2.xyz, ngb3.xyz);
    var_normal = calc_quad_normal(ngb1, ngb2, ngb3, ngb4);
    
    gl_Position = modelViewProjectionMatrix * vert_pos;
    var_color = color * vec4(vec3(vert_pos.z*10),1);
}

void phase19() {
    //add fog
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.05;
    vert_pos.z += slip_rand(vert_pos.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) vert_pos.z += slip_rand(vert_pos.xy, 512)*0.001;
    
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
    if ( vert_pos.z > 0.03) ngb1.z += slip_rand(ngb1.xy, 512)*0.001;
    //ngb1.z += lip_rand(ngb1.xy, 32)*0.05;
    ngb2.z = slip_rand(ngb2.xy, 16)*0.05;
    ngb2.z += slip_rand(ngb2.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) ngb2.z += slip_rand(ngb2.xy, 512)*0.001;
    //ngb2.z += lip_rand(ngb2.xy, 32)*0.05;
    ngb3.z = slip_rand(ngb3.xy, 16)*0.05;
    ngb3.z += slip_rand(ngb3.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) ngb3.z += slip_rand(ngb3.xy, 512)*0.001;
    //ngb3.z += lip_rand(ngb3.xy, 32)*0.05;
    ngb4.z = slip_rand(ngb4.xy, 16)*0.05;
    ngb4.z += slip_rand(ngb4.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) ngb4.z += slip_rand(ngb4.xy, 512)*0.001;
    //var_normal = calc_normal(ngb1.xyz, ngb2.xyz, ngb3.xyz);
    var_normal = calc_quad_normal(ngb1, ngb2, ngb3, ngb4);
    
    gl_Position = modelViewProjectionMatrix * vert_pos;
    float fog_val = clamp(gl_Position.z, 0.0, 1.0);
    var_color = color * vec4(vert_pos.z*10, fog_val, 0, 1);
}

void phase20() {
    //add vertex id
    vec4 vert_pos = position;
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.05;
    vert_pos.z += slip_rand(vert_pos.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) vert_pos.z += slip_rand(vert_pos.xy, 512)*0.001;
    
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
    if ( vert_pos.z > 0.03) ngb1.z += slip_rand(ngb1.xy, 512)*0.001;
    //ngb1.z += lip_rand(ngb1.xy, 32)*0.05;
    ngb2.z = slip_rand(ngb2.xy, 16)*0.05;
    ngb2.z += slip_rand(ngb2.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) ngb2.z += slip_rand(ngb2.xy, 512)*0.001;
    //ngb2.z += lip_rand(ngb2.xy, 32)*0.05;
    ngb3.z = slip_rand(ngb3.xy, 16)*0.05;
    ngb3.z += slip_rand(ngb3.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) ngb3.z += slip_rand(ngb3.xy, 512)*0.001;
    //ngb3.z += lip_rand(ngb3.xy, 32)*0.05;
    ngb4.z = slip_rand(ngb4.xy, 16)*0.05;
    ngb4.z += slip_rand(ngb4.xy, 64)*0.01;
    if ( vert_pos.z > 0.03) ngb4.z += slip_rand(ngb4.xy, 512)*0.001;
    //var_normal = calc_normal(ngb1.xyz, ngb2.xyz, ngb3.xyz);
    var_normal = calc_quad_normal(ngb1, ngb2, ngb3, ngb4);
    
    gl_Position = modelViewProjectionMatrix * vert_pos;
    float fog_val = clamp(gl_Position.z, 0.0, 1.0);
    var_color = color * vec4(vert_pos.z*10, fog_val, 0, 1);
    var_position = vert_pos.xyz;    //get the position of the vertex after translation, rotation, scaling
}

void phase22(){
    gl_Position = modelViewProjectionMatrix * position;
    var_normal = normal;
    var_color = color * vec4(position.z*10, 0, 0, 1);
}

void phaseY() {
    //gl_TexCoord[0] = texcoord;
    vec4 vert_pos = position;
    float prev = rand(floor(vert_pos.xy*10)/10)*0.1;
    float next = rand(ceil(vert_pos.xy*10)/10)*0.1;
    vec2 pos = (vert_pos.xy - floor(vert_pos.xy*10)/10) / (ceil(vert_pos.xy*10)/10 - floor(vert_pos.xy*10)/10);
    vert_pos.z = mix(prev, next, pos.x);
    var_color = vec4(vec3(vert_pos.z*10), 1);
    gl_Position = modelViewProjectionMatrix * vert_pos;
}

void main()
{	
    switch (phase) {
        
        case 22:
            phase22();
            break;
        case 21:
        case 20:
            phase20();
            break;
        case 19:
            phase19();
            break;
        case 18:
            phase18();
            break;
        case 17:
            phase17();
            break;
        case 16:
        case 15:
        case 14:
        case 13:
        case 12:
            phase12();
            break;
        case 11:
            phase11();
            break;
        case 10:
            phase10();
            break;
        case 9:
            phase9();
            break;
        case 8:
            phase8();
            break;
        case 7:
            phase7();
            break;
        case 6:
            phase6();
            break;
        case 5:
            phase5();
            break;
        case 4:
            phase4();
            break;
        case 3:
            phase3();
            break;
        case 2:
            phase2();
            break;
        case 1:
            phase1();
            break;
        default:
            phase0();
            break;
    }
    var_texcoord = texcoord;
}
