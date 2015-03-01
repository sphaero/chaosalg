#version 120
#extension GL_EXT_gpu_shader4 : enable

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
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    // scale y axis
    vert_pos.y *= 0.01;
    //vert_pos.y += 0.5;
    // just a small z addition to make sure we have a visible line
    vert_pos.z += vert_pos.y*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color;
}

void phase1() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    // scale y axis
    vert_pos.y *= 0.01;
    //vert_pos.y += 0.5;
    vert_pos.z = sin_n(vert_pos.x)*0.1;
    // just a small z addition to make sure we have a visible line
    vert_pos.z += vert_pos.y*0.2;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color;
}

void phase2() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    vert_pos.z = sin_n(vert_pos.x)*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color;
}

void phase3() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    vert_pos.z = sin_n(vert_pos.x)*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color * vec4(vec3(vert_pos.z*10),1);
}

void phase4() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    vert_pos.z = (sin_n(vert_pos.x) * sin_n(vert_pos.y))*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color * vec4(vec3(vert_pos.z*10),1);
}

void phase5() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    vert_pos.z = (sin_n(vert_pos.x) * cos_n(vert_pos.y))*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color * vec4(vec3(vert_pos.z*10),1);
}

void phase6() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    // scale y axis
    vert_pos.y *= 0.01;
    vert_pos.z = sin_n(vert_pos.x)*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color * vec4(vec3(vert_pos.z*10),1);
}

void phase7() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    // scale y axis
    vert_pos.y *= 0.0000001;
    vert_pos.z = rand(vert_pos.xy)*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color * vec4(vec3(vert_pos.z*10),1);
}

void phase8() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    vert_pos.z = rand(vert_pos.xy)*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color * vec4(vec3(vert_pos.z*10),1);
}

void phase9() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    vert_pos.z = ip_rand(vert_pos.xy, 16)*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color * vec4(vec3(vert_pos.z*10),1);
}

void phase10() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    vert_pos.z = lip_rand(vert_pos.xy, 16)*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color * vec4(vec3(vert_pos.z*10),1);
}

void phase11() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.1;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color * vec4(vec3(vert_pos.z*10),1);
}

void phase12() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    vert_pos.z = slip_rand(vert_pos.xy, 16)*0.1;
    vert_pos.z += rand(vert_pos.xy)*0.001;
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
    gl_FrontColor = gl_Color * vec4(vec3(vert_pos.z*10),1);
}


void phaseY() {
    gl_TexCoord[0] = gl_MultiTexCoord0;
    vec4 vert_pos = vec4(gl_Vertex);
    float prev = rand(floor(vert_pos.xy*10)/10)*0.1;
    float next = rand(ceil(vert_pos.xy*10)/10)*0.1;
    vec2 pos = (vert_pos.xy - floor(vert_pos.xy*10)/10) / (ceil(vert_pos.xy*10)/10 - floor(vert_pos.xy*10)/10);
    vert_pos.z = mix(prev, next, pos.x);
    gl_FrontColor = vec4(vec3(vert_pos.z*10), 1);
    gl_Position = gl_ModelViewProjectionMatrix * vert_pos;
}

void main()
{	
    switch (phase) {
        
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
    //vert_pos.y *= 0.01;
    //vert_pos.y += 0.5;

    //vert_pos.z = lcg_norm(lcg(int(vert_pos.x*512)));
    //vert_pos.z = cos(vert_pos.x*100)*0.1;
	//gl_Position = gl_Vertex;
	//gl_FrontColor = gl_Color;// + vec4 (cos(vert_pos.x*10)*sin(vert_pos.y*10));
}
