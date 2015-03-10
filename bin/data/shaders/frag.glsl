#version 150

// input
in vec4 var_color;
in vec2 var_texcoord;
in vec3 var_normal;

//output
out vec4 outputColor;

uniform int phase;
const int a = 1140671485;
const int c = 128201163;
const int m = 16777216;
const float PI = 3.14159265358979323846264;

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

vec4 normal_to_color(vec3 normal) {
    return vec4((var_normal + vec3(1))/2., 1.0);
}

void phase13() {
    outputColor = var_color * vec4(vec3(rand(var_texcoord)),1.0);
}

void phase14() {
    outputColor = var_color * vec4(vec3(ip_rand(var_texcoord, 2048)),1.0);
}

void phase15() {
    outputColor = var_color * vec4(vec3(lip_rand(var_texcoord, 2048)),1.0);
}

void phase16() {
    outputColor = var_color * vec4(vec3(slip_rand(var_texcoord, 2048)),1.0);
}

void phase17() {
    outputColor = normal_to_color(var_normal);
}

void phase18() {
    vec4 ncolor = normal_to_color(var_normal);
    outputColor = vec4(var_normal.z, 0,0,1);
}

void main (void)  
{  
   switch (phase) {
        
        case 18:
            phase18();
            break;
        case 17:
            phase17();
            break;
        case 16:
            phase16();
            break;
        case 15:
            phase15();
            break;
        case 14:
            phase14();
            break;
        case 13:
            phase13();
            break;
        default:
            outputColor = var_color;
            break;
    }
}
