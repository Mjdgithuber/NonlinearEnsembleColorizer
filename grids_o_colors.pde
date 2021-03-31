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

Cell[] cells;
SoundCell[] soundcells;
int currentEditor = -1;

boolean[] overCells;      // array of which cell if any mouse is over
boolean[] overSoundcells;

int currentSoundCellOver = -1;
int currentCellOver = -1;

int currentSelectedSoundCell = -1;

class SoundCell {
	int id, x, y, cellWidth, cellHeight, cellOffsetX, cellOffsetY;
	color currentcolor;
	boolean highlight;
	boolean selected;
	
	SoundCell(int _id) {
		id = _id;
		cellWidth = gCellWidth;
		cellHeight = gCellHeight;
		cellOffsetX = gCellOffsetX;
		cellOffsetY = gCellOffsetY;   
		selected = false;
		
		// first part of x just pushes whole row over one...
		x = gGridOffsetX + ( id % gGridWidth * (cellOffsetX + cellWidth));
		y = gGridPadTop + gSoundCellPadTop + gGridOffsetY + ( ( floor(gCellCount / gGridWidth) * (cellOffsetY + cellHeight) ));// + cellHeight + cellOffsetY);      
	}
	
	void update() {    
	
	}  
	
	void display() {
		
		fill(gSoundColors[id]);         
		stroke(strokeDefault);
		
		if(selected) {
			strokeWeight(strokeWeightSelected);
		} else {
			if(highlight) 
				strokeWeight(strokeWeightHighlight);
			else 
				strokeWeight(strokeWeightDefault);
		}
		
		//strokeWeight(strokeWeightDefault);
		rect(x, y, cellWidth, cellHeight);
		 
	}
	
	void select() {
		selected = !selected;
	}
	
	boolean isOver() {
		 if (mouseX >= x && mouseX <= x+cellWidth && mouseY >= y && mouseY <= y+cellHeight) {
			 highlight = true;
			 return true;      
		 } else {
			 highlight = false;
			 return false;
		 }
	 }    

	// plays selected bottom cell sound on local client for auditioning
	void sendOscSelection(int cell, int _id){    
		// OscMessage myOscMessage = new OscMessage("/grid/selection");        
		// myOscMessage.add(cell);    
		// myOscMessage.add(_id);    
		// oscP5.send(myOscMessage, myLocalMachine);    
	}
	
	 
	void press() {
			
		select();                  
				
		// if its  not pressing the button again...
		if( currentSelectedSoundCell != id) { 
		
			// ignore resetting last value if its the first click...
			if( currentSelectedSoundCell != -1)
				soundcells[currentSelectedSoundCell].select();
			
			// set current cell to selected 
			currentSelectedSoundCell = id; 
			
			sendOscSelection(currentSelectedSoundCell, client_id); // send call to local client audio server; do after resetting id to currently clicked cell
			
			// if its a repeat click of the last one, set to black (last one)
		} else if(currentSelectedSoundCell == id) {
			
			sendOscSelection(currentSelectedSoundCell, client_id);//client_id); // send call to local client audio server; do before resetting id to use last click (for doubles)
			
			currentSelectedSoundCell = soundcells.length-1;
			soundcells[currentSelectedSoundCell].select();             
		}        
		
		gActiveSound = currentSelectedSoundCell;
	}
}

class FineEditor {
	int x, y, cellWidth, cellHeight, cellOffsetX, cellOffsetY;

	color[] c_arr;
	Cell parent;
	boolean visible;

	FineEditor(Cell p, int cy) {
		parent = p;
		int h_off = 10;
		int w_off = 30;

		x = 5;
		y = cy - h_off/2;
		cellWidth = (gGridOffsetX * 2) + ((gCellWidth + gCellOffsetX) * gGridWidth) - gCellOffsetX - 10;
		cellHeight = gCellHeight + h_off;
		visible = false;

	}

	void update() {}

	void display() {
		if(!visible) return;

		fill(black);
		
		stroke(red);
		strokeWeight(strokeWeightHighlight);

		rect(x, y, cellWidth, cellHeight);

		parent.display(false);
	}

	void setVisible(boolean v) {
		visible = v;
	}

	boolean isVisible() {
		return visible;
	}

}

class Cell {

	int id, x, y, cellWidth, cellHeight, cellOffsetX, cellOffsetY;
	boolean highlight;
	int currentNote = -1;  
	color currentColor;

	FineEditor fe;
	
	// Constructor
	Cell(int _id) {
		print(_id);
		id = _id;
		cellWidth = gCellWidth;
		cellHeight = gCellHeight; 
		cellOffsetX = gCellOffsetX;
		cellOffsetY = gCellOffsetY;

		x = gGridOffsetX + ( id % gGridWidth * (cellOffsetX + cellWidth));
		y = gGridPadTop + gGridOffsetY + ( ( floor(id / gGridWidth) * (cellOffsetY + cellHeight) ) );
		
		currentColor = defaultColor;
		fe = new FineEditor(this, y);
	}

	boolean editorOpen() {
		return fe.isVisible();
	}

	void toggleEditor() {
		// close current editor
		if(gEditorOpen) {
			cells[currentEditor].fe.setVisible(false);
			gEditorOpen = false;
			return;
		}

		fe.setVisible(true);
		gEditorOpen = true;
		currentEditor = id;
		// fe.setVisible(!gEditorOpen && open);
		// gEditorOpen = fe.isVisible() ? true : gEditorOpen;
	}

	void update() {    
		
		if (gLastSelectedCell == id)      
			highlight = true;
		else
			highlight = false;   
		
		// clear cell or set color    
		if(gActiveSound == -1)
			currentColor = defaultColor;
	}

	void display() {
		this.display(true);
	}

	void display(boolean fill) {
		
		if(fill) fill(currentColor);
		
		if (highlight) {
			//fill(rectHighlight);
			stroke(strokeHighlight);
			strokeWeight(strokeWeightHighlight * (!fill ? 2 : 1));
		} else {
			//
			stroke(strokeDefault); 
			strokeWeight(strokeWeightDefault * (!fill ? 4 : 1));
		}
		
		rect(x, y, cellWidth, cellHeight);
		
	}

	void displayEditor() {
		if(fe != null) fe.display();
	}
	
	// _id is the cell clicked that triggered the send;
	void sendOscNote(int _id){
		
		// // /grid/client/<user_id> <user_name> <clicked_cell_id> <active_sound> <cell1 color> <cell2 color> ...
		// OscMessage myOscMessage = new OscMessage("/grid/client/" + client_id);
		
		// myOscMessage.add(client_name);
		// myOscMessage.add(_id);
		// myOscMessage.add(gActiveSound);
		
		// for (Cell currentCell : cells)        
		// 		myOscMessage.add(currentCell.currentNote);            

		// oscP5.send(myOscMessage, myBroadcastLocation);    
	}
	
	void setCellColorValue(color value) {
		fill(rectHighlight);
	}
	
	boolean isOver() {
		if (mouseX >= x && mouseX <= x+cellWidth && 
			mouseY >= y && mouseY <= y+cellHeight) {      
			return true;      
		} else {      
			return false;
	 }
	}    
	
	void press() {
		
		gLastSelectedCell = id;
		
		// set color of cell to gActiveSound and send that OSC value 
		if(gActiveSound > -1) {
			currentColor = gSoundColors[gActiveSound];
			currentNote = gActiveSound;
		
			sendOscNote(id);
		}
	}
	
}

/*
void sendOscSelection(int _id){
		
	// /grid/client/<user_id> <user_name> <clicked_cell_id> <active_sound> <cell1 color> <cell2 color> ...
	OscMessage myOscMessage = new OscMessage("/grid/selection");        
	myOscMessage.add(gActiveSound);    
	myOscMessage.add(_id);    
	oscP5.send(myOscMessage, myLocalMachine);    
}
*/
	
void settings() {
	screenSizeX = (gGridOffsetX * 2) + ((gCellWidth + gCellOffsetX) * gGridWidth) - gCellOffsetX + gGridPadLeft + gGridPadRight;
	screenSizeY = (gGridOffsetY * 2) + ((gCellHeight + gCellOffsetY) * (gGridHeight + 1) ) - gCellOffsetY + gGridPadTop + gGridPadBottom;
	size( screenSizeX, screenSizeY);
}

void setup() {
	frame = new MovieFrame("inception.jpg", 0, 0, 477, 268);
	palette = new Palette(0, 270, 477, 300, 35, 4, 3);

	//rectHighlight = color(51);
	rectHighlight = color(liteGreen);
	
	circleColor = color(255);
	circleHighlight = color(204);
	
	
	currentColor = baseColor;
	circleX = width/2+circleSize/2+10;
	circleY = height/2;
	rectX = width/2-rectSize-10;
	rectY = height/2-rectSize/2;
	ellipseMode(CENTER);

	// Grid init
	cells = new Cell[gCellCount];
	
	for ( int i=0; i<gCellCount; i++ ) {
		cells[i] = new Cell(i);
	}
	
	// Sound Cell Row init
	soundcells = new SoundCell[gSoundCellCount];
	
	for ( int i=0; i<gSoundCellCount; i++ ) {
		soundcells[i] = new SoundCell(i);
	}
 
}

void draw() {
	update(mouseX, mouseY);
	palette.update(frame.getAvgerageColor());
	background(currentColor);


	// Instantiate grid
	for (Cell currentCell : cells) {
		currentCell.update();
		currentCell.display();
	}

	for (Cell currentCell : cells) {
		currentCell.displayEditor();
	}
	
	
	// Instantiate sound cell row
	for (SoundCell currentSoundCell : soundcells) {
		currentSoundCell.update();
		currentSoundCell.display();
	}
	
	strokeWeight(2);
	int lineY = soundcells[0].y + soundcells[0].cellHeight + soundcells[0].cellOffsetY + 2;
	int lineWidth = gCellWidth*2 + gCellOffsetX;
	int line1X1 = gGridOffsetX;
	int line1X2 = gGridOffsetX + lineWidth;
	int line2X1 = line1X2 + gCellOffsetX;
	int line2X2 = line2X1 + lineWidth;
	int line3X1 = line2X2 + gCellOffsetX;
	int line3X2 = line3X1 + lineWidth;
	int line4X1 = line3X2 + gCellOffsetX;
	int line4X2 = line4X1 + lineWidth;
	
	fill(255);
	// line 1
	line(line1X1, lineY, line1X2, lineY);
	line(line2X1, lineY, line2X2, lineY);
	line(line3X1, lineY, line3X2, lineY);
	line(line4X1, lineY, line4X2, lineY);
	
	text("1", line1X2 - lineWidth/2.0, lineY + 18);
	text("2", line2X2 - lineWidth/2.0, lineY + 18);
	text("3", line3X2 - lineWidth/2.0, lineY + 18);
	text("4", line4X2 - lineWidth/2.0, lineY + 18);
	
	textAlign(LEFT);
	int textY = soundcells[0].y + soundcells[0].cellHeight + soundcells[0].cellOffsetY + 70;
	String userPrefsText = client_name + ": (" + client_id + ")   Server: " + server_ip + ":" + server_port;  
	textSize(14);
	text(userPrefsText, 10, textY);  
	
	textAlign(RIGHT);  
	String aboutText = "Non-specific Gamelan Taiko Fusion (2005) \n by Perry R. Cook & Ge Wang \n GridClient v1.1 by Rob Hamilton (2021)";
	textSize(12);
	textLeading(14);
	text(aboutText, screenSizeX - 10, screenSizeY - 40);

	frame.display();
	palette.display();

	fill(frame.getAvgerageColor());
	rect(476, 1, 50, 267);
}

void keyPressed() {
	int keyIndex = -1;  
	
	switch(key) {
		case '0':
			keyIndex = 8;
			break;
		case '1':
			keyIndex = 0;
			break;
		case '2':
			keyIndex = 1;
			break;
		case '3':
			keyIndex = 2;
			break;
		case '4':
			keyIndex = 3;
			break;
		case '5':
			keyIndex = 4;
			break;      
		case '6':
			keyIndex = 5;
			break;      
		case '7':
			keyIndex = 6;
			break;      
		case '8':
			keyIndex = 7;
			break;
		case '9':
			keyIndex = 8;
			break;      
		case ' ':
			//println("Spacebar"); 
			clearAllCells();
			break;        
		/*      
		default:
			keyIndex = -1;
			break;
		*/
	}
	
	
	
	if(keyIndex > -1 && keyIndex < soundcells.length)
		setActiveSound(keyIndex);
	
}

void setActiveSound(int sound)
{
	//println(sound);  
	gActiveSound = sound;
	soundcells[sound].press();
	
}

void update(int x, int y) {

	/*
	if ( overCircle(circleX, circleY, circleSize) ) {
		circleOver = true;
		rectOver = false;
	} else if ( overRect(rectX, rectY, rectSize, rectSize) ) {
		rectOver = true;
		circleOver = false;
	} else {
		circleOver = rectOver = false;
	}
	*/
	
	currentSoundCellOver = -1;
	
	for (SoundCell currentSoundCell : soundcells) {    
		if(currentSoundCell.isOver()) 
			 currentSoundCellOver = currentSoundCell.id;         
	}
	
	currentCellOver = -1;
	
	for (Cell currentCell : cells) {
		if(currentCell.isOver()) 
			 currentCellOver = currentCell.id;     
	}



	
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

	if(mouseButton == LEFT) {
		frame.leftPress(mouseX, mouseY);

		if(currentSoundCellOver > -1){
			soundcells[currentSoundCellOver].press();        
			
		} else if(currentCellOver > -1) {
			cells[currentCellOver].press();
		}
	} else if(mouseButton == RIGHT) {
		frame.rightPress(mouseX, mouseY);

		if(currentCellOver > -1)
			cells[currentCellOver].toggleEditor();
		else if(currentEditor > -1)
			cells[currentEditor].toggleEditor();

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
void clearAllCells()
{
	gActiveSound = -1;
	
	for (Cell currentCell : cells)        
		currentCell.currentNote = -1;
		
	//cells[0].sendOscNote(gLastSelectedCell); // call send from any cell
	/*
	// set black as highlighted/selected cell
	soundcells[currentSelectedSoundCell].select();
	
	// set empty cell to be currently selected
	currentSelectedSoundCell = soundcells.length-1;
 
	gActiveSound = soundcells.length-1;
	//gLastSelectedCell = -1;
	
	for (Cell currentCell : cells) {    
		currentCell.press();   
		currentCell.highlight = false;
	}
	*/
}