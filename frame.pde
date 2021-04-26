import processing.video.*;

interface GUIFrame {
	public void leftPress(int mouseX, int mouseY);
	public void rightPress(int mouseX, int mouseY);
	public void releaseRightMouse();
	public void releaseLeftMouse();

	public void draw();

	public void updateFrame();

	public void toggleState();

	public boolean isPlaying();

	public void writeFrame();

	public color getAvgerageColor();

	public void update(int mouseX, int mouseY);
	
	public void display();
}

class ClientFrame implements GUIFrame {
	color red = #ff807f;
	int x, y, width, height;
	// PImage frame;

	int selX, selY, selW, selH;

	boolean leftSelected;
	int selOffX, selOffY;

	boolean rightSelected;
	int zone;
	int zoneStartX, zoneStartY;

	PImage frame;
	String current;
	PApplet parent;
	boolean updating;
	Thread t;
	String server_ip;

	public ClientFrame(PApplet _parent, String frame, int _x, int _y, int _width, int _height, String _server_ip) {
		parent = _parent;

		x = _x;
		y = _y;
		width = _width;
		height = _height;

		loadFrame();

		selX = 10;
		selY = 10;
		selW = 75;
		selH = 75;
		leftSelected = false;

		rightSelected = false;
		zone = 0;
		current = "";
		server_ip = _server_ip;
	}

	public String getServerIP() {
		return server_ip;
	}

	private class ImageUpdater implements Runnable {

		ClientFrame cf;

		public ImageUpdater(ClientFrame _cf) {
			cf = _cf;
		}

		public void run() {
			GetRequest get = new GetRequest("http://" + cf.getServerIP() + "/api_test_post.php");
			get.send();

			String b64Image = get.getContent();
			cf.installFrame(b64Image);
		}
	}

	public void installFrame(String b64) {
		if(!current.equals(b64)) {
			try {
				frame = DecodePImageFromBase64(b64);
				current = b64;
			} catch(Exception e) { e.printStackTrace(); }
		}
	}

	private PImage DecodePImageFromBase64(String b64Image) throws IOException {
		PImage result = null;
		byte[] decodedBytes = Base64.decodeBase64(b64Image);

		ByteArrayInputStream in = new ByteArrayInputStream(decodedBytes);
		BufferedImage bImageFromConvert = ImageIO.read(in);
		BufferedImage convertedImg = new BufferedImage(bImageFromConvert.getWidth(), bImageFromConvert.getHeight(), BufferedImage.TYPE_INT_ARGB);
		convertedImg.getGraphics().drawImage(bImageFromConvert, 0, 0, null);
		result = new PImage(convertedImg);

		return result;
	}

	private void loadFrame() {
		
		// GetRequest post = new GetRequest("http://192.168.1.113/api_test_post.php");
		// get.send();

		// String b64Image = get.getContent();

		// if(!current.equals(b64Image)) {
		// 	frame = parent.DecodePImageFromBase64(b64Image);
		// 	current = b64Image;
		// }

		Runnable r = new ImageUpdater(this);
		t = new Thread(r);
		t.start();

		// t = new Thread() {
		// 	public void run() {
		// 		try {
		// 			System.out.println("Does it work?");

		// 			Thread.sleep(1000);

		// 			System.out.println("Nope, it doesnt...again.");
		// 		} catch(InterruptedException v) {
		// 			System.out.println(v);
		// 		}
		// 	}  
		// };
	}

	private boolean overRect(int mouseX, int mouseY, int x, int y, int width, int height) {
		if (mouseX >= x && mouseX <= x+width && 
			mouseY >= y && mouseY <= y+height)
			return true;
		return false;
	}

	void leftPress(int mouseX, int mouseY) {
		if(overRect(mouseX, mouseY, selX, selY, selW, selH)) {
			leftSelected = true;
			selOffX = mouseX - selX;
			selOffY = mouseY - selY;
		}
	}

	void rightPress(int mouseX, int mouseY) {
		if(overRect(mouseX, mouseY, selX, selY, selW, selH)) {
			float xPer = (mouseX - selX) / ((float) selW);
			float yPer = (mouseY - selY) / ((float) selH);

			// Zone: 0 - top left, 1 - top right, 2 - bottom left, 3 - bottom right
			int zStart = (yPer <= .5f) ? 0 : 2;
			zone = ((xPer <= .5f) ? 0 : 1) + zStart;

			zoneStartX = mouseX;
			zoneStartY = mouseY;

			print("Zone", zone, "\n");

			rightSelected = true;
		}
	}

	void releaseRightMouse()  {
		rightSelected = false;
	}

	void releaseLeftMouse()  {
		leftSelected = false;
	}

	public void draw() {
		image(frame, 0, 0, width, height);
	}

	public void updateFrame() {
		if(t != null && !t.isAlive()) {
			loadFrame();
		}
	}

	public void toggleState() {}

	public boolean isPlaying() {
		return false;
	}

	public void writeFrame() {}

	public color getAvgerageColor() {
		float r = 0;
		float g = 0;
		float b = 0;

		int num = 0;
		for(int i = 0; i < selW; i++) {
			for(int j = 0; j < selH; j++) {
				color c = frame.get((selX + i) * (frame.width / width), (selY + j) * (frame.height / height));
				r += red(c);
				g += green(c);
				b += blue(c);
				num++;
			}
		}

		return color(r/num, g/num, b/num);
	}

	void update(int mouseX, int mouseY) {
		if(leftSelected) {
			selX = mouseX - selOffX;
			selY = mouseY - selOffY;
		}

		if(rightSelected) {
			int dX = mouseX - zoneStartX;
			int dY = mouseY - zoneStartY;
			if(zone == 3) {
				selW += dX;
				selH += dY;
			} else if(zone == 0) {
				selX += dX;
				selY += dY;

				selW -= dX;
				selH -= dY;

			} else if(zone == 1) {
				selW += dX;

				selY += dY;
				selH -= dY;
			} else if(zone == 2) {
				selH += dY;

				selX += dX;
				selW -= dX;
			}
			zoneStartX = mouseX;
			zoneStartY = mouseY;
		}
	}
	
	void display() {
		image(frame, x, y, width, height);

		stroke(red);
		strokeWeight(5);
		noFill();
		rect(selX, selY, selW, selH);		 
	}
}























































class MovieFrame implements GUIFrame {
	color red = #ff807f;
	int x, y, width, height;
	// PImage frame;

	int selX, selY, selW, selH;

	boolean leftSelected;
	int selOffX, selOffY;

	boolean rightSelected;
	int zone;
	int zoneStartX, zoneStartY;

	Movie frame;
	PApplet parent;

	boolean playing;
	String dump_loc;

	public MovieFrame(PApplet _parent, String frame, int _x, int _y, int _width, int _height, String _dump_loc) {
		parent = _parent;

		x = _x;
		y = _y;
		width = _width;
		height = _height;

		changeFrame(frame);

		selX = 10;
		selY = 10;
		selW = 75;
		selH = 75;
		leftSelected = false;

		rightSelected = false;
		zone = 0;
		playing = true;
		dump_loc = _dump_loc;
	}

	private boolean overRect(int mouseX, int mouseY, int x, int y, int width, int height) {
		if (mouseX >= x && mouseX <= x+width && 
			mouseY >= y && mouseY <= y+height)
			return true;
		return false;
	}

	void leftPress(int mouseX, int mouseY) {
		if(overRect(mouseX, mouseY, selX, selY, selW, selH)) {
			leftSelected = true;
			selOffX = mouseX - selX;
			selOffY = mouseY - selY;
		}
	}

	void rightPress(int mouseX, int mouseY) {
		if(overRect(mouseX, mouseY, selX, selY, selW, selH)) {
			float xPer = (mouseX - selX) / ((float) selW);
			float yPer = (mouseY - selY) / ((float) selH);

			// Zone: 0 - top left, 1 - top right, 2 - bottom left, 3 - bottom right
			int zStart = (yPer <= .5f) ? 0 : 2;
			zone = ((xPer <= .5f) ? 0 : 1) + zStart;

			zoneStartX = mouseX;
			zoneStartY = mouseY;

			print("Zone", zone, "\n");

			rightSelected = true;
		}
	}

	void releaseRightMouse()  {
		rightSelected = false;
	}

	void releaseLeftMouse()  {
		leftSelected = false;
	}

	void changeFrame(String newFrame) {
		frame = new Movie(parent, newFrame);
		frame.loop();
		frame.volume(0);
		// frame = loadImage(newFrame);
	}

	public void draw() {
		image(frame, 0, 0, width, height);
	}

	public void updateFrame() {
		// frame.read();
	}

	public void toggleState() {
		if(playing)
			frame.pause();
		else
			frame.play();
		playing = !playing;
	}

	public boolean isPlaying() {
		return playing;
	}

	public void writeFrame() {
		PImage newImage = createImage(477, 268, RGB);
		newImage = frame.get();
		newImage.resize(477, 268);
		newImage.save(dump_loc + "frame.jpg");
	}

	public color getAvgerageColor() {
		float r = 0;
		float g = 0;
		float b = 0;

		int num = 0;
		for(int i = 0; i < selW; i++) {
			for(int j = 0; j < selH; j++) {
				color c = frame.get((selX + i) * (frame.width / width), (selY + j) * (frame.height / height));
				r += red(c);
				g += green(c);
				b += blue(c);
				num++;
			}
		}

		return color(r/num, g/num, b/num);
	}

	void update(int mouseX, int mouseY) {
		if(leftSelected) {
			selX = mouseX - selOffX;
			selY = mouseY - selOffY;
		}

		if(rightSelected) {
			int dX = mouseX - zoneStartX;
			int dY = mouseY - zoneStartY;
			if(zone == 3) {
				selW += dX;
				selH += dY;
			} else if(zone == 0) {
				selX += dX;
				selY += dY;

				selW -= dX;
				selH -= dY;

			} else if(zone == 1) {
				selW += dX;

				selY += dY;
				selH -= dY;
			} else if(zone == 2) {
				selH += dY;

				selX += dX;
				selW -= dX;
			}
			zoneStartX = mouseX;
			zoneStartY = mouseY;
		}
	}
	
	void display() {
		image(frame, x, y, width, height);

		stroke(red);
		strokeWeight(5);
		noFill();
		rect(selX, selY, selW, selH);		 
	}
}
