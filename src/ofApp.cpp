#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    ofSetLogLevel(OF_LOG_VERBOSE);
    ofDisableArbTex();
    //ofSetVerticalSync(true);
    ofEnableAlphaBlending();
    
	shader.load("shaders/vert.glsl", "shaders/frag.glsl"); 
    
    ofBackground(70);
    ofSetColor(255);

    oculusRift.baseCamera = &cam; //attach to your camera
    //oculusRift.setup();

    // needed for programmable renderer
    ofViewport(ofGetNativeViewport());
    
    // setup params & gui
    setupParams();
    int p=0;
    phaseChanged(p);
    _cam_pos = ofVec3f(0,-0.6, 0.1);
    _cam_ori = ofVec3f(75, 0, 0);

    cam.setPosition(0,-0.6, 0.1);
    cam.setOrientation(ofVec3f(75,0,0));
    cam.setNearClip(0.001);
    cam.setFarClip(10);
    
    //oculusRift.lockView = false;
    //oculusRift.setUsePredictedOrientation(true);

    // generate a plane
    int rows = 512, columns = 512;
    int width = 1, height = 1;
    ofVec3f vert;
    ofVec3f normal(0, 0, 1); // always facing forward //
    ofVec2f texcoord;
    for(int iy = 0; iy < rows; iy++) {
        for(int ix = 0; ix < columns; ix++) {
            // normalized tex coords //
            texcoord.x = ((float)ix/((float)columns-1.f));
            texcoord.y = ((float)iy/((float)rows-1.f));
            
            vert.x = texcoord.x * width;
            vert.y = texcoord.y * height;
            
            mesh.addVertex(vert);
            mesh.addTexCoord(texcoord);
            mesh.addNormal(normal);
            mesh.addColor(ofFloatColor(1.0));
        }
    }
    for(int y = 0; y < rows-1; y++) {
        for(int x = 0; x < columns-1; x++) {
            // first triangle //
            mesh.addIndex((y)*columns + x);
            mesh.addIndex((y)*columns + x+1);
            mesh.addIndex((y+1)*columns + x);

            // second triangle //
            mesh.addIndex((y)*columns + x+1);
            mesh.addIndex((y+1)*columns + x+1);
            mesh.addIndex((y+1)*columns + x);
        }
    }
}

//--------------------------------------------------------------
void ofApp::update(){
    updatePhase();
    updateCam();
}

void ofApp::draw() {
    if (oculusRift.isSetup()) {
        ofColor(255);
        glEnable(GL_DEPTH_TEST);

        oculusRift.beginLeftEye();
        draw_scene();
        oculusRift.endLeftEye();

        oculusRift.beginRightEye();
        draw_scene();
        oculusRift.endRightEye();

        oculusRift.draw();
        glDisable(GL_DEPTH_TEST);
    }
    else {
        ofEnableDepthTest();
        cam.begin();
        draw_scene();
        cam.end();
        ofDisableDepthTest();
    }
    // draw ui
    ofDisableDepthTest();
    gui.draw();
	ofDrawBitmapString("fps: " + ofToString((int)ofGetFrameRate()) + " ori: " + ofToString(cam.getOrientationEuler()), 20, 10);
}

//--------------------------------------------------------------
void ofApp::draw_scene(){
    ofPushStyle();
    if (debug.get()) {
        origin.drawAxes(0.1);
        ofTranslate(-0.5,-0.5);
        origin.drawAxes(0.1);
        ofTranslate(1,1);
        origin.drawAxes(0.1);
        ofTranslate(-0.5,-0.5);
    }
    
    shader.begin();
    ofTranslate(-0.5, -0.5, 0);
    ofColor(255);
    mesh.draw();
    // set phase in shader
    shader.setUniform1i("phase", phase.get());
    
    // make light direction slowly rotate
    shader.setUniform3f("lightDir", sin(ofGetElapsedTimef()/10), cos(ofGetElapsedTimef()/10), 0);

    shader.end();
	ofPopStyle();
}

void ofApp::updateValue(float& source, float& dest) {
    ofLerp(source, dest, speed.get());
}

void ofApp::updateValue(ofVec3f& source, ofVec3f& dest) {
    ofLerp(source.x, dest.x, speed.get());
    ofLerp(source.y, dest.y, speed.get());
    ofLerp(source.z, dest.z, speed.get());
}

void ofApp::updateCam() {
    ofVec3f source = cam.getPosition();
    source.x = ofLerp(source.x, _cam_pos.x, pow(2,-speed.get()));
    source.y = ofLerp(source.y, _cam_pos.y, pow(2,-speed.get()));
    source.z = ofLerp(source.z, _cam_pos.z, pow(2,-speed.get()));
    cam.setPosition(source);
    
    /*source = cam.getOrientationEuler();
    source.x = ofLerp(source.x, _cam_ori.x, pow(2,-speed.get()));
    source.y = ofLerp(source.y, _cam_ori.y, pow(2,-speed.get()));
    source.z = ofLerp(source.z, _cam_ori.z, pow(2,-speed.get()));
    cam.setOrientation(source);
    */
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){

    if (key == 'w') {
        _cam_pos += ofVec3f(0,.01,0);
    }
    else if (key == 's') {
        _cam_pos += ofVec3f(0,-.01,0);
    }
    else if (key == 'a') {
        _cam_pos += ofVec3f(-.01,0,0);
    }
    else if (key == 'd') {
        _cam_pos += ofVec3f(.01,0,0);
    }
    else if (key == 'e') {
        _cam_pos += ofVec3f(0,0,-.01);
    }
    else if (key == 'q') {
        _cam_pos += ofVec3f(0,0,.01);
    }
    else if (key == OF_KEY_LEFT) {
        phase.set(phase.get()-1);
    }
    else if (key == OF_KEY_RIGHT) {
        phase.set(phase.get()+1);
    }
    else if(key == 'l'){
        oculusRift.lockView = !oculusRift.lockView;
    }
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){
    if (oculusRift.isSetup()) oculusRift.dismissSafetyWarning();
    if (key == ' ') {
        shader.load("shaders/vert.glsl", "shaders/frag.glsl");
    }
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
    updateCamRotation(ofVec2f(x,y));
    lastMouse = ofVec2f(x,y);
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
    lastMouse = ofVec2f(x,y);
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}

void ofApp::setupParams() {

    parameters.setName("settings");
    parameters.add(speed.set("lerpspeed", 9, 1, 15));
    parameters.add(phase.set("phase", 0, 0, 20));
    parameters.add(debug.set("debug", true));
    //settings.load("settings.xml");
    //settings.deserialize(parameters);
    gui.setup(parameters);
    //font.load( OF_TTF_SANS,9,true,true);
    
    phase.addListener(this, &ofApp::phaseChanged);
}

void ofApp::phaseChanged(int &newPhase) {
    ofLogVerbose() << "phase change to: " << newPhase; 
    switch (newPhase) {
        case 0:
        case 1:
        case 6:
        case 7:
            _cam_pos = ofVec3f(0,-1.1, 0);
            _cam_ori = ofVec3f(90,0,0);
            break;
        case 8:
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:
        case 18:
        case 19:
            _cam_pos = ofVec3f(0,0.0, 0.1);
            _cam_ori = ofVec3f(0,0,0);
            speed.set(10);
            break;

        default:
            _cam_pos = ofVec3f(0,-0.6, 0.1);
            _cam_ori = ofVec3f(75, 0, 0);
            break;
    }
}

void ofApp::updatePhase() {
    
    
}

void ofApp::updateCamRotation(ofVec2f mouse) {\
    //float xdiff = ofGetWidth()/2.0 - mouse.x;
    //float ydiff = ofGetHeight()/2.0 - mouse.y;
    float xdiff = lastMouse.x - mouse.x;
    float ydiff = lastMouse.y - mouse.y;
    cam.rotate(xdiff*0.1, ofVec3f(0, 0, 1));
    cam.rotate(ydiff*0.1, cam.getSideDir());
}
