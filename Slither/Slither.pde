/*
 * TODO:
 * Add play button or menu
 */

int GRID_SIZE = 20;
int CELL_SIZE;
int TICK_RATE = 10;
boolean gameRunning = false;

Snake snake;
Apple apple;

void initGame() {
    snake = new Snake();
    apple = new Apple();
}

void drawGrid() {
    stroke(75);
    for (int i = 1; i < GRID_SIZE; i++) {
        /* Draws the vertical lines */
        line(i * CELL_SIZE, 0, i * CELL_SIZE, height);
        
        /* Draws the horizontal lines */
        line(0, i * CELL_SIZE, width, i * CELL_SIZE);
    }
    
    noStroke();
}

void playButton() {
    fill(200, 100);
    ellipse(width / 2, height / 2, width / 2, height / 2);
    
    float theta = 0;
    fill(0, 150);
    triangle(
        cos(theta) * 100 + width / 2, sin(theta) * 100 + height / 2,
        cos(theta + TAU / 3) * 100 + width / 2, sin(theta + TAU / 3) * 100 + height / 2,
        cos(theta + 2 * TAU / 3) * 100 + width / 2, sin(theta + 2 * TAU / 3) * 100 + height / 2);
}

void setup() {
    size(600, 600);
    frameRate(10);
    
    CELL_SIZE = width / GRID_SIZE;
    initGame();
}

void draw() {
    background(0);
    
    apple.draw();
    snake.run();
    
    drawGrid();
    println(keyCode);
    
    if (!gameRunning) {
        playButton();
        noLoop();
    }
}

void keyPressed() {
    snake.getInput();
}

void mouseClicked() {
    if (!gameRunning) {
        gameRunning = true;
        initGame();
        
        loop();
    }
}

public class Snake {
    /* Holds the position for the snake's head */
    private PVector head;
    
    /* Holds the positions for each segment of the snake */
    private ArrayList<PVector> segments;
    
    /* Holds the direction the snake is moving */
    private PVector direction;
    
    /* Holds how many segments the snake has */
    private int length;
    
    /* Holds how many apples the snake has eaten */
    private int apples;
    
    public Snake() {
        head = new PVector(width / 2, height / 2);
        direction = new PVector(CELL_SIZE, 0);
        length = 3;
        apples = 0;
        
        segments = new ArrayList<PVector>();
        segments.add(head.copy());
    }
    
    private void draw() {
        PVector segment;
        for (int i = 0; i < segments.size(); i++) {
            segment = segments.get(i);
            
            fill(0, map(i, 0, segments.size(), 100, 255), 0);
            rect(segment.x, segment.y, CELL_SIZE, CELL_SIZE);
        }
    }
    
    private void update() {
        head.add(direction);
        
        checkSegments();
        checkWalls();
        
        segments.add(head.copy());
        
        /* Removes a segment from the snake to maintain its length */
        int segmentCount = segments.size();
        if (segmentCount > length) {
            segments.remove(0);
        }
        
        eatApple();
    }
    
    public void run() {
        update();
        draw();
    }
    
    public void getInput() {
        /* Sets the dirtection of the snake to the arrow key pressed */
        switch (keyCode) {
            case LEFT:
            case 65:
                direction.set(-CELL_SIZE, 0);
                break;
            case RIGHT:
            case 68:
                direction.set(CELL_SIZE, 0);
                break;
            case UP:
            case 87:
                direction.set(0, -CELL_SIZE);
                break;
            case DOWN:
            case 83:
                direction.set(0, CELL_SIZE);
                break;
        }
    }
    
    /* Checks if the snake is touching the apple */
    private void eatApple() {
        if (head.equals(apple.getPosition())) {
            apples++;
            length += 2;
            
            apple = new Apple();
        }
    }
    
    /* Checks if the snake is out of bounds */
    private void checkWalls() {
        if (head.x < 0 || head.x >= width || head.y < 0 || head.y >= height) {
            gameRunning = false;
        }
    }
    
    /* Checks if the head is inside the body of the snake */
    private void checkSegments() {
        int lastIndex = max(segments.size() - 1, 1);
        if (segments.subList(0, lastIndex).contains(head)) {
            gameRunning = false;
        }
    }
    
    public void setDirection(int x, int y) {
        direction.set(x, y);
    }
    
    public PVector getDirection() {
        return direction;
    }
    
    public PVector getHead() {
        return head;
    }
    
    public ArrayList<PVector> getSegments() {
        return segments;
    }
}

public class Apple {
    /* Holds the position of the apple */
    private PVector position;
    
    public Apple() {
        ArrayList<PVector> segments = snake.getSegments();
        PVector pos;
        
        /* Generates a random position on the grid until the apple is not inside the snake */
        do {
            pos = new PVector(floor(random(GRID_SIZE)) * CELL_SIZE, floor(random(GRID_SIZE)) * CELL_SIZE);
        } while (segments.contains(pos));
        
        position = pos;
    }
    
    public void draw() {
        fill(175, 0, 0);
        rect(position.x, position.y, CELL_SIZE, CELL_SIZE);
    }
    
    public PVector getPosition() {
        return position;
    }
}
