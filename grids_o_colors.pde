// MJD

GUIFrame frame;
// MovieFrame frame;
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
import http.requests.*;
import org.apache.commons.codec.binary.Base64;
import java.io.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.net.*;

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

String gui_type, server_gui_ip, mp4_loc, dump_loc;

PImage playButton;

	
void settings() {
	screenSizeX = (gGridOffsetX * 2) + ((gCellWidth + gCellOffsetX) * gGridWidth) - gCellOffsetX + gGridPadLeft + gGridPadRight;
	screenSizeY = (gGridOffsetY * 2) + ((gCellHeight + gCellOffsetY) * (gGridHeight + 1) ) - gCellOffsetY + gGridPadTop + gGridPadBottom;

	screenSizeX = 550;
	screenSizeY = 600;
	size( screenSizeX, screenSizeY);
}

void setup() {
	// read init preferences
	readPreferencesFile();


	if(gui_type.equals("server"))
		frame = new MovieFrame(this, mp4_loc, 0, 0, 477, 268, dump_loc);
	else
		frame = new ClientFrame(this, mp4_loc, 0, 0, 477, 268, server_gui_ip);

	palette = new Palette(0, 270, 477, 300, 65, 4, 3); 
	
	oscP5 = new OscP5(this, 12000);
	
	myBroadcastLocation = new NetAddress(server_ip, server_port); // server
	myLocalMachine = new NetAddress(local_client_ip, local_client_port);

	playButton = loadImage("play.png");

	// testHTTP();
}

void draw() {
	palette.update(frame.getAvgerageColor());
	background(currentColor);

	// frame.draw();
	frame.updateFrame();
	frame.display();
	palette.display();

	fill(frame.getAvgerageColor());
	rect(476, 1, 50, 267);

	if(gui_type.equals("server"))
		image(playButton, 0, 0, 50, 50);
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

	if(mouseX < 50 && mouseY < 50) {
		frame.toggleState();
		if(!frame.isPlaying() && gui_type.equals("server")) {
			frame.writeFrame();
			testHTTP();
		}
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
	gui_type = lines[4];
	server_gui_ip = lines[5];
	mp4_loc = lines[6];
	dump_loc = lines[7];
		
	print(client_id, client_name, server_ip, server_port);
}

void movieEvent(Movie m) {
	m.read();
}


String encodeToBase64(String fileLoc) throws IOException, FileNotFoundException, URISyntaxException {
	File originalFile = new File(fileLoc);
	// File originalFile = new File(Thread.currentThread().getContextClassLoader().getResource("data/" + fileLoc).toURI());
	String encodedBase64 = null;

	FileInputStream fileInputStreamReader = new FileInputStream(originalFile);
	byte[] bytes = new byte[(int)originalFile.length()];
	fileInputStreamReader.read(bytes);
	encodedBase64 = new String(Base64.encodeBase64(bytes));
	fileInputStreamReader.close();

	return encodedBase64;
}

PImage DecodePImageFromBase64(String b64Image) throws IOException {
	PImage result = null;
	byte[] decodedBytes = Base64.decodeBase64(b64Image);

	ByteArrayInputStream in = new ByteArrayInputStream(decodedBytes);
	BufferedImage bImageFromConvert = ImageIO.read(in);
	BufferedImage convertedImg = new BufferedImage(bImageFromConvert.getWidth(), bImageFromConvert.getHeight(), BufferedImage.TYPE_INT_ARGB);
	convertedImg.getGraphics().drawImage(bImageFromConvert, 0, 0, null);
	result = new PImage(convertedImg);

	return result;
}

void testHTTP() {
	print("TESTING...");
	try {
		// print(System.getProperty("user.dir"));

		// print(encodeToBase64("C:/Users/Matthew/Desktop/School Stuff/Spring 2021/Nonlinear Ens/final_project/src/oscGridClient/a/grids_o_colors/data/" + "inception.jpg"));
		// String pic = encodeToBase64("C:/Users/Matthew/Desktop/School Stuff/Spring 2021/Nonlinear Ens/final_project/src/oscGridClient/a/grids_o_colors/data/" + "inception.jpg");
		String pic = encodeToBase64(dump_loc + "frame.jpg");
		PostRequest post = new PostRequest("http://" + server_gui_ip + "/api_test_post.php");
		post.addData("name", pic);
		post.send();
		System.out.println("Reponse Content: " + post.getContent());
	} catch(Exception e) {
		e.printStackTrace();;
		print("Failed Emma");
	}

	// GetRequest get = new GetRequest("http://192.168.1.113/api_test.php");
	// get.send();
	// println("Reponse Content: " + get.getContent());
	// println("Reponse Content-Length Header: " + get.getHeader("Content-Length"));
}