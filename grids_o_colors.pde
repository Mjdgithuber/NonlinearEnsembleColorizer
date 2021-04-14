// MJD

MovieFrame frame;
Palette palette;

String client_name;
int client_id = -1; // starting value for 
String server_ip;
int server_port;
String local_client_ip; 
int local_client_port;

String preferences_file = "prefs.txt";

import oscP5.*;
import netP5.*;
import processing.video.*;

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
	frame = new MovieFrame(this, "mkl.mp4", 0, 0, 477, 268);
	palette = new Palette(0, 270, 477, 300, 65, 5, 3); 

	// read init preferences
	readPreferencesFile();
	
	oscP5 = new OscP5(this, 12000); 
	
	myBroadcastLocation = new NetAddress(server_ip, server_port); // server
	myLocalMachine = new NetAddress(local_client_ip, local_client_port);
}

void draw() {
	palette.update(frame.getAvgerageColor());
	background(currentColor);

	// frame.draw();
	// frame.updateFrame();
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
 
	print("hellooooo");
 
 int index = palette.getIndex(mouseX, mouseY);
 
 if(index != -1) {
	 
	 float currentRed = red(palette.getColor(index));
	 float currentGreen = green(palette.getColor(index));
	 float currentBlue = blue(palette.getColor(index));
	 
	 sendOscNote(index, currentRed, currentGreen, currentBlue);
	 print(red(palette.getColor(index)) + "\n");  
 }
 
 
 
 print(index);
 
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

// _id is the cell clicked that triggered the send;
void sendOscNote(int index, float _red, float _green, float _blue){
		
		// /grid/client/<user_id> <user_name> <clicked_cell_id> <active_sound> <cell1 color> <cell2 color> ...
		OscMessage myOscMessage = new OscMessage("/gridocolor");
		
		myOscMessage.add(client_id);
		myOscMessage.add(client_name);
		myOscMessage.add(index);
		myOscMessage.add(_red);
		myOscMessage.add(_green);
		myOscMessage.add(_blue);
		print(_red, _green, _blue);
		
		oscP5.send(myOscMessage, myBroadcastLocation);    
	}

void readPreferencesFile() {  

	String[] lines = loadStrings(preferences_file);  
		 
	server_ip = lines[0]; 
	server_port = int(lines[1]);
	client_name = lines[2];
	client_id = int(lines[3]);       
		
	print(client_id, client_name, server_ip, server_port);
}

void movieEvent(Movie m) {
	m.read();
}