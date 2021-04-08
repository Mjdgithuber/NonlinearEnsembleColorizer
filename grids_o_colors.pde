// Your name here x
//String client_name = "Rob";
//int client_id = 9;
 




// MJD




MovieFrame frame;
Palette palette;







String client_name;
int client_id = -1; // starting value for 
String server_ip;
int server_port;
String local_client_ip; 
int local_client_port;

String preferences_file = "gridClient_preferences.txt";

import oscP5.*;
import netP5.*;

OscP5 oscP5;
/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation;
NetAddress myLocalMachine;

int rectX, rectY;      // Position of square button
int circleX, circleY;  // Position of circle button
int rectSize = 90;     // Diameter of rect
int circleSize = 93;   // Diameter of circle

int screenSizeX, screenSizeY;

color circleColor;
color baseColor = color(0);
color rectHighlight, circleHighlight;
color currentColor;
boolean rectOver = false;
boolean circleOver = false;

color defaultColor = #808080;
color black = 0;
color red = #ff807f;
color blue = #7fcaff;
color liteGreen = #7aff7a;
color yellow = #feff79;
color orange = #ffa845;
color purple = #695dff;
color liteBlue = #7cffff;
color pink = #ff7bff;
color green = #62AA5E;
color grey = #808080;


color[] gSoundColors = { red, liteGreen, purple, yellow, orange, pink, blue, liteBlue, grey };    // Array to hold the colors for our sound palatte
int gSoundCellCount = gSoundColors.length;

color strokeHighlight = 255;//liteGreen;
color strokeDefault = 255;

int strokeWeightHighlight = 4;
int strokeWeightDefault = 1;
int strokeWeightSelected = 6;

int gActiveSound = -1;

int gGridWidth = 9;
int gGridHeight = 4;
int gCellCount = gGridWidth * gGridHeight;
int gGridOffsetX = 10;
int gGridOffsetY = 10;
int gCellOffsetX = 10;
int gCellOffsetY = 10;
int gCellWidth = 100;
int gCellHeight = 100;
int gGridPadLeft = 0;
int gGridPadRight = 0;
int gGridPadTop = 0;
int gGridPadBottom = 100;
int gSoundCellPadTop = 20;

int gLastSelectedCell = -2;

int gOscCurrentCount = 0;
int gLastNoteSent = -1;

boolean gEditorOpen = false;



int currentSoundCellOver = -1;
int currentCellOver = -1;

int currentSelectedSoundCell = -1;

	
void settings() {
	screenSizeX = (gGridOffsetX * 2) + ((gCellWidth + gCellOffsetX) * gGridWidth) - gCellOffsetX + gGridPadLeft + gGridPadRight;
	screenSizeY = (gGridOffsetY * 2) + ((gCellHeight + gCellOffsetY) * (gGridHeight + 1) ) - gCellOffsetY + gGridPadTop + gGridPadBottom;

	screenSizeX = 550;
	screenSizeY = 600;
	size( screenSizeX, screenSizeY);
}

void setup() {
	frame = new MovieFrame("inception.jpg", 0, 0, 477, 268);
	palette = new Palette(0, 270, 477, 300, 65, 3, 3); 
}

void draw() {
	palette.update(frame.getAvgerageColor());
	background(currentColor);

	frame.display();
	palette.display();

	fill(frame.getAvgerageColor());
	rect(476, 1, 50, 267);
}

void keyPressed() {	
}

void setActiveSound(int sound)
{
}

void mousePressed() {

	/*
	if (circleOver) {
		currentColor = circleColor;
	}
	if (rectOver) {
		currentColor = defaultColor;    
	}
*/
	int index = palette.getIndex(mouseX, mouseY);
	if(index != -1)
		print(palette.getColor(index) + "\n");

	if(mouseButton == LEFT) {
		frame.leftPress(mouseX, mouseY);
	} else if(mouseButton == RIGHT) {
		frame.rightPress(mouseX, mouseY);
	}
			
}

void mouseReleased() {
	if(mouseButton == LEFT) {
		frame.releaseLeftMouse();
	} else if(mouseButton == RIGHT) {
		frame.releaseRightMouse();
	}
}

void mouseDragged() 
{
	frame.update(mouseX, mouseY);
}

/*
boolean overRect(int x, int y, int width, int height) {
	if (mouseX >= x && mouseX <= x+width && 
		mouseY >= y && mouseY <= y+height) {
		return true;
	} else {
		return false;
	}
}

boolean overCircle(int x, int y, int diameter) {
	float disX = x - mouseX;
	float disY = y - mouseY;
	if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
		return true;
	} else {
		return false;
	}
}
*/
