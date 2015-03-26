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

//output
out vec4 outputColor;

uniform int phase;
uniform vec3 lightPos;
uniform sampler2D tex0;

const int a = 1140671485;
const int c = 128201163;
const int m = 16777216;
const float PI = 3.14159265358979323846264;
//material constants
const vec3 m_ambient = vec3(0.28, 0.3, 0.33);
const vec3 m_diffuse = vec3(0.8, 0.7, 0.6);
const vec3 m_specular = vec3(0.2, 0.2, 0.8);
const float shininess = 64.0;
//light constants
const vec3 l_ambient = vec3(0.5, 0.5, 0.6);
const vec3 l_diffuse = vec3(1, 1, 1);
const vec3 l_specular = vec3(0.5, 0.8, 0.8);

float sin_n(float val) {
    return sin(val*31.4)*0.5+0.5;
} 

vec2 sin_n(vec2 val) {
    return sin(val*31.4)*0.5+0.5;
} 

vec3 sin_n(vec3 val) {
    return sin(val*31.4)*0.5+0.5;
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

vec3 basic_phong(vec3 normal, vec3 light_dir, vec3 view_dir, vec3 diffuseColor, vec3 specularColor) 
{
    vec3 reflect_dir = reflect(light_dir, normal);
    vec3 ambient     = diffuseColor * l_ambient * m_ambient;
    vec3 diffuse     = l_diffuse * diffuseColor * max(dot(-light_dir, normal), 0.0);
    vec3 specular    = l_specular * specularColor * pow(max(dot(reflect_dir, view_dir), 0.0f), shininess);
    return ambient + diffuse + specular;
}

vec4 normal_to_color(vec3 normal) {
    return vec4((normal + vec3(1))/2., 1.0);
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
    //if (var_normal.z > 0.9) {
    //    outputColor = vec4(var_normal,1);
    //}
    //else {
        outputColor = normal_to_color(var_normal);
    //}
}

void phase18() {
    vec3 surf2view=normalize(-var_position);
    vec3 specColor = m_specular;
    vec3 diffColor = vec3(1.0 - slip_rand(var_texcoord, 2048)*0.05); //white snow
    float horizon_length = length(var_normal.xy);
    if (horizon_length > 0.7) 
    {
        float alpha = smoothstep(0.7, 0.75, horizon_length);
        specColor = vec3(0);
        vec3 rockDiffuse = vec3(0.077,0.029, 0.002) + vec3(slip_rand(var_texcoord, 2048)*0.05);
        diffColor = mix(diffColor, rockDiffuse, alpha);// - vec4(vec3(slip_rand(var_texcoord, 2048))*0.1,1.0);
    }
    outputColor.a = 1.0;
    outputColor.rgb = basic_phong(var_normal, normalize(-lightPos), surf2view, diffColor, specColor);
}

void phase19() {
    vec3 surf2view=normalize(-var_position);
    vec3 specColor = m_specular;
    vec3 diffColor = vec3(1.0 - slip_rand(var_texcoord, 2048)*0.05); //white snow
    float horizon_length = length(var_normal.xy);
    if (horizon_length > 0.7) 
    {
        float alpha = smoothstep(0.7, 0.75, horizon_length);
        specColor = vec3(0);
        vec3 rockDiffuse = vec3(0.077,0.029, 0.002) + vec3(slip_rand(var_texcoord, 2048)*0.05);
        diffColor = mix(diffColor, rockDiffuse, alpha);// - vec4(vec3(slip_rand(var_texcoord, 2048))*0.1,1.0);
    }
    vec3 fog = vec3(0.7, 0.8, 1.0);
    outputColor.a = 1.0;
    outputColor.rgb = mix(basic_phong(var_normal, normalize(-lightPos), surf2view, diffColor, specColor), fog, var_color.g);
}

void phase20() {
    
    vec3 surf2view=normalize(-var_position);
    outputColor.a = 1.0;
    outputColor.rgb = basic_phong(normalize(var_normal), normalize(-lightPos), surf2view, m_diffuse, m_specular);
}

void phase21() {
    
    vec3 surf2view=normalize(-var_position);
    //vec3 extranormal = normalize(var_normal + vec3(cos(var_texcoord.x*314), sin(var_texcoord.y*314), 1));
    vec3 extranormal = normalize(var_normal + noise3(var_texcoord));
    outputColor.a = 1.0;
    outputColor.rgb = basic_phong(extranormal, normalize(-lightPos), surf2view, m_diffuse, m_specular);
}

void phase22() {
    //vec3 rnd_normal = normalize(var_normal + vec3(cos(var_texcoord.x*314), sin(var_texcoord.y*314), 1));
    vec3 rnd_normal = normalize(var_normal + noise3(var_texcoord));
    //vec3 rnd_normal = normalize(vec3(pow(sin_n(var_texcoord*10),vec2(10)),0) + var_normal);
    //vec3 rnd_normal = normalize(texture(tex0, var_texcoord).xyz*2.0 - 1.0);
    vec3 surf2view=normalize(-var_position);
    outputColor.a = 1.0;
    outputColor.rgb = basic_phong(rnd_normal, normalize(-lightPos), surf2view, m_diffuse, m_specular);
}

void main (void)  
{  
   switch (phase) {
        
        case 22:
            phase22();
            break;
        case 21:
            phase21();
            break;
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
