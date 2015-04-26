#pragma once

#include "ofMain.h"
#include "ofxGui.h"
#include "ofxOculusDK2.h"

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();
		void draw_scene();
		void draw_text();

		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);

        ofShader shader;
        ofVboMesh mesh;
        ofPlanePrimitive plane;
        ofShader sphereShader;
        ofSpherePrimitive sphere;
        int subdiv = 256;
        ofCamera cam;
        float rotPos;
		ofQuaternion curRot;
		ofVec2f lastMouse;
        of3dPrimitive origin;
        ofNode light;
        
        ofTrueTypeFont	verdana;
        ofFbo           texttex;
        
        void setupParams();
        ofxPanel            gui;
        bool                ui;
        ofParameterGroup    parameters;
        ofXml               settings;
        ofParameter<float> speed;
        ofParameter<float> rot_speed;
        ofParameter<int> phase;
        ofParameter<bool> debug;
        ofParameter<ofVec3f> lightPos;
        ofParameter<float> seed;
        ofParameter<float> fog_depth;
        
        void updateCam();
        void updatePhase();
        void phaseChanged(int& newPhase);
        void updateValue(float& source, float& dest); 
        void updateValue(ofVec3f& source, ofVec3f& dest); 
        void updateCamRotation(ofVec2f mouse);
        ofVec3f _cam_pos;
        ofVec3f _cam_ori;
        float _phase8time;

        //oculus
        ofxOculusDK2        oculusRift;
};
