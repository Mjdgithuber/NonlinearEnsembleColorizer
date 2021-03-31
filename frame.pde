class MovieFrame {
	color red = #ff807f;
	int x, y, width, height;
	PImage frame;

	int selX, selY, selW, selH;

	boolean leftSelected;
	int selOffX, selOffY;

	boolean rightSelected;
	int zone;
	int zoneStartX, zoneStartY;

	public MovieFrame(String frame, int _x, int _y, int _width, int _height) {
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
		frame = loadImage(newFrame);
	}

	public color getAvgerageColor() {
		float r = 0;
		float g = 0;
		float b = 0;

		int num = 0;
		for(int i = 0; i < selW; i++) {
			for(int j = 0; j < selH; j++) {
				color c = frame.get(selX + i, selY + j);
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