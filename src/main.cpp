#include "ofMain.h"
#include "ofApp.h"

//========================================================================
int main( ){
    ofGLWindowSettings settings;
    settings.width = 1920;
    settings.height = 1080;
    settings.setGLVersion(4, 4);
    ofCreateWindow(settings);

    ofRunApp( new ofApp());
}
