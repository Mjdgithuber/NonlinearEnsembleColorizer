class Palette {
	color red = #ff807f;

	color currentColor;
	int padX, padY;
	int x, y, width, height, boxSize, boxHor, boxVer;
	color[][] cArr;
	public Palette(int _x, int _y, int _width, int _height, int _box_size, int _box_hor, int _box_ver) {
		x = _x;
		y = _y;
		width = _width;
		height = _height;
		boxSize = _box_size;
		boxHor = _box_hor;
		boxVer = _box_ver;

		padX = (width - boxSize * boxHor) / (boxHor - 1);
		padY = (height - boxSize * boxVer) / (boxVer - 1);

		currentColor = red;
		cArr = new color[boxVer][boxHor];
		print(padX, padY, boxSize);
	}

	color getColor(int index) {
		int tmp = index/boxHor;
		return cArr[tmp][index - tmp*boxHor];
	}

	int getIndex(int _x, int _y) {
		int i_x = _x - x;
		int i_y = _y - y;
		for(int i = 0; i < boxVer; i++) {
			for(int j = 0; j < boxHor; j++) {
				if(i_x > (padX + boxSize)*j && i_x < (padX + boxSize)*(j+1)) {
					if(i_y > (padY + boxSize)*i && i_y < (padY + boxSize)*(i+1))
						return i*boxHor + j;
				}
			}
		} 
		return -1;
	}

	void display() {
		stroke(red);
		strokeWeight(5);
		noFill();

		float shade = .95;

		color temp = currentColor;
		for(int i = 0; i < boxVer; i++) {
			for(int j = 0; j < boxHor; j++) {
				fill(temp);
				cArr[i][j] = temp;
				rect(x + (padX + boxSize)*j, y + (padY + boxSize)*i, boxSize, boxSize);
				temp = color(red(temp) * shade, green(temp) * shade, blue(temp) * shade);
			}
		} 
	}

	void update(color c) {
		currentColor = c;
	}
}
