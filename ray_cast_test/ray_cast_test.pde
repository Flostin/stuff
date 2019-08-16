int[][] WORLD = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
};

PImage WALL_TEXTURE;
int[] TEXTURE_ARRAY;

int WORLD_WIDTH = WORLD[0].length;
int WORLD_HEIGHT = WORLD.length;

float PROJECTION_DIST;
float FIELD_OF_VIEW = PI / 2;

int UNIT_SIZE = 64;

float direction = TAU * 3/4;
float x = 187, y = 187;

boolean inBounds(int x, int y) {
    try {
        return WORLD[y][x] == 0;
    } catch (ArrayIndexOutOfBoundsException e) {
        return false;
    }
}

void drawWorld() {
    for (int y = 0; y < WORLD_WIDTH; y++) {
        for (int x = 0; x < WORLD_HEIGHT; x++) {
            fill(WORLD[y][x] == 1 ? 175 : 255);
            rect(x * UNIT_SIZE, y * UNIT_SIZE, UNIT_SIZE, UNIT_SIZE);
        }
    }
}

void updatePlayer() {
    if (keyPressed) {
        // rotates player
        if (keyCode == LEFT) {
            direction = ((direction - PI / 45) + TAU) % TAU;
        } else if (keyCode == RIGHT) {
            direction = (direction + PI / 45) % TAU;
        }
        
        // moves player
        if (key == 'a') {
            x += cos(direction - PI / 2) * 5;
            y += sin(direction - PI / 2) * 5;
        } else if (key == 'd') {
            x -= cos(direction - PI / 2) * 5;
            y -= sin(direction - PI / 2) * 5;
        }
        
        if (key == 'w') {
            x += cos(direction) * 5;
            y += sin(direction) * 5;
        } else if (key == 's') {
            x -= cos(direction) * 5;
            y -= sin(direction) * 5;
        }
    }
}

void drawSlice(int projectionHeight, float offset, int index) {
    for (int y = 0, i, textureSize = WALL_TEXTURE.width; y < height; y++) {
        i = index + y * width;
        
        if (y < (height - projectionHeight) / 2) {
            pixels[i] = color(100, 200, 225);
        } else if (y > (height + projectionHeight) / 2) {
            pixels[i] = color(0, 175, 0);
        } else {
            int u = (int)(map(y, (height - projectionHeight) / 2, (height + projectionHeight) / 2, 0, textureSize - 1));
            int v = (int)(map(offset, 0, UNIT_SIZE, 0, textureSize));
            
            try {
                pixels[i] = TEXTURE_ARRAY[v + u * textureSize];
            } catch(ArrayIndexOutOfBoundsException e) {
                pixels[i] = color(0);
                println(offset);
            }
        }
    }
}

void castRay(float theta, int index) {
    float xHorizontal, yHorizontal;
    float xVertical, yVertical;
    
    float xA, yA;
    float horizontalDist, verticalDist;
    
    // checks in which direction the ray is pointing
    if (theta >= PI && theta <= TAU) {
        yHorizontal = floor(y / UNIT_SIZE) * UNIT_SIZE - 1;
        yA = -UNIT_SIZE;
        xA = UNIT_SIZE / -tan(theta);
    } else {
        yHorizontal = floor(y / UNIT_SIZE) * UNIT_SIZE + UNIT_SIZE;
        yA = UNIT_SIZE;
        xA = UNIT_SIZE / tan(theta);
    }
    
    xHorizontal = x + (y - yHorizontal) / -tan(theta);
    
    while (inBounds(floor(xHorizontal / UNIT_SIZE), floor(yHorizontal / UNIT_SIZE))) {
        xHorizontal += xA;
        yHorizontal += yA;
    }
    
    horizontalDist = dist(x, y, xHorizontal, yHorizontal);
    
     // checks in which direction the ray is pointing
    if (theta >= PI / 2 && theta <= PI * 1.5) {
        xVertical = floor(x / UNIT_SIZE) * UNIT_SIZE - 1;
        xA = -UNIT_SIZE;
        yA = UNIT_SIZE * -tan(theta);
    } else {
        xVertical = floor(x / UNIT_SIZE) * UNIT_SIZE + UNIT_SIZE;
        xA = UNIT_SIZE;
        yA = UNIT_SIZE * tan(theta);
    }
    
    yVertical = y + (x - xVertical) * -tan(theta);
    
    while (inBounds(floor(xVertical / UNIT_SIZE), floor(yVertical / UNIT_SIZE))) {
        xVertical += xA;
        yVertical += yA;
    }
    
    verticalDist = dist(x, y, xVertical, yVertical);
    
    float distance = min(horizontalDist, verticalDist);
    float offset = ((horizontalDist < verticalDist) ? xHorizontal : yVertical) % UNIT_SIZE;
    float projectionHeight = UNIT_SIZE / (distance * cos(theta - direction)) * PROJECTION_DIST;
    
    drawSlice((int)(projectionHeight), offset, index);
    
    /*strokeWeight(1);
    stroke(distance, 0, 0);
    line(index, (height - projectionHeight) / 2, index, (height + projectionHeight) / 2);*/
}

void setup() {
    size(480, 300);
    strokeWeight(2);
    frameRate(1000);
    
    PROJECTION_DIST = (width / 2) / tan(FIELD_OF_VIEW / 2);
    WALL_TEXTURE = loadImage("tile03.jpg");
    
    WALL_TEXTURE.loadPixels();
        TEXTURE_ARRAY = WALL_TEXTURE.pixels;
    WALL_TEXTURE.updatePixels();
}

void draw() {
    updatePlayer();
    
    background(255);
    
    /*stroke(0);
    strokeWeight(2);
    drawWorld();*/
    
    /*noStroke();
    fill(255, 0, 0);
    ellipse(x, y, 5, 5);*/
    
    float start = ((direction - FIELD_OF_VIEW / 2) + TAU) % TAU;
    
    loadPixels();
        for (int i = 0; i < width; i++) {
            float theta = (i * (FIELD_OF_VIEW / width) + start) % TAU;
            castRay(theta, i);
        }
    updatePixels();
    
    println(frameRate);
}
