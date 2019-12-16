boolean DO_DEBUG = false;

class Person {
  int size = 10;
  color shade = color(255, 0, 0);
  
  float bodyValue = 0.9; // 1 = perfectly typical, 0 = perfectly atypical
  float environmentValue = 0.9; // 1 = perfectly supportive, 0 = perfectly unsupportive

  float bodyRangeValue = 0.1;

  boolean update = false;

  PGraphics canvas;
  
  Person(int canvasWidth, int canvasHeight) {
    canvas = createGraphics(canvasWidth, canvasHeight);
  }
  
  void draw() {
    if (isRendering || update) {
      canvas.beginDraw();
      
      if (!isRendering) {
        canvas.clear();
      }
      
      canvas.scale(-1, 1);
      canvas.translate(-canvasWidth, 0);
  
      canvas.noStroke();
      canvas.fill(shade);
      canvas.circle(getPositionForBody(bodyValue), getPositionForEnvironment(environmentValue), size);
      canvas.endDraw();
      //TODO: decice about this
      //drawBodyRange();
    }  
    update = false;
  }
}

class Map {
  float misfitPointThreshold = 0.5;
  float misfitRegionSoftness = 0.0;
  float familiarityConstant = 0; // 0 = no familiarity, 1 = complete familiarity

  boolean update = true;

  PGraphics canvas;

  Map(int canvasWidth, int canvasHeight) {
    canvas = createGraphics(canvasWidth, canvasHeight);
  }
  
  void draw() {
    if (isRendering || update) {
      float bodyComponent;
      float environmentComponent;
      float resistance;
      color resistanceColor;
  
      canvas.beginDraw();
      canvas.clear();
      
      canvas.background(minResistance);
      
      canvas.scale(-1, 1);
      canvas.translate(-canvasWidth, 0);
    
      for (int x = 0; x < canvasWidth; x++) {
        for (int y = 0; y < canvasHeight; y++) {
          bodyComponent = getBodyComponentFor(x);
          environmentComponent = getEnvironmentComponentFor(y);
          resistance = getResistance(bodyComponent, environmentComponent);
          resistanceColor = getResistanceColor(resistance);
          if (resistanceColor != minResistance) {
            canvas.stroke(resistanceColor);
            canvas.point(x, y);
          }
        }
      }
      canvas.endDraw();
    }
    update = false;
  }
}

// State variables
boolean renderBodyRange = false;
boolean isRendering = false;

int cellGranularity = 100;

// Settings

String outputPath = "/Users/adapar/Devel/resistance_mapper/output/";

boolean useFullScreen = false;

int canvasWidth = 512;
int canvasHeight = 512;

color minResistance = color(0, 0, 0);
color maxResistance = color(255, 255, 255);

PGraphics bodyRange;
PGraphics renderCanvas;

Map map;
Person person;

public void settings() {
  if (useFullScreen) {
    fullScreen(2);
  } else {
    size (canvasWidth, canvasHeight);
  }
}

void setup() {
  background(minResistance);
  
  map = new Map(canvasWidth, canvasHeight);
  person = new Person(canvasWidth, canvasHeight);
  
  bodyRange = createGraphics(canvasWidth, canvasHeight);
  renderCanvas = createGraphics(canvasWidth, canvasHeight);
}

void draw() {
  print("isRendering = " + isRendering + ", ");
  if (!isRendering) {
    println("drawing...");
    background(128);
    map.draw();
    person.draw();
    image(map.canvas, getCanvasLeft(), getCenterY());
    if (renderBodyRange) {
      image(bodyRange, getCanvasLeft(), getCenterY());
    }
    image(person.canvas, getCanvasLeft(), getCenterY());
  }
}

int getCanvasLeft() {
  return round((width - canvasWidth) / 2);
}

int getCenterY() {
  return round((height - canvasHeight) / 2);
}

/*
void drawBodyRange() {
  bodyRange.beginDraw();
  bodyRange.clear();
  bodyRange.scale(-1, 1);
  bodyRange.translate(-canvasWidth, 0);
  bodyRange.noStroke();
  bodyRange.fill(color(255, 0, 0, 64));
  bodyRange.rect(getPositionForBody(bodyValue - bodyRangeValue), 0, getPositionForBody(bodyRangeValue) * 2, canvasHeight);
  bodyRange.endDraw();
}
*/

float getBodyComponentFor(float value) {
  return value/canvasWidth;
}

float getEnvironmentComponentFor(float value) {
  return value/canvasHeight;
}

int getPositionForBody(float value) {
  return round(value * canvasWidth);
}

int getPositionForEnvironment(float value) {
  return round(value * canvasHeight);
}

float getResistance(float body, float environment) {
  return (1 - map.familiarityConstant) * (1 - (body * environment));
}

color getResistanceColor(float resistance) {
  color output;
  float delta = resistance - map.misfitPointThreshold;
  if (abs(delta) <= map.misfitRegionSoftness) {
    float interpolationRange = 2 * map.misfitRegionSoftness;
    float interpolationRangeStart = map.misfitPointThreshold - map.misfitRegionSoftness;    
    float interpolationAmount = (resistance - interpolationRangeStart) / interpolationRange;
    output = lerpColor(minResistance, maxResistance, interpolationAmount);
  } else if (delta < 0) {
    output = minResistance;
  } else {
    output = maxResistance;
  }
  return output;
}
  
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
        map.misfitPointThreshold += 0.1;
        if (map.misfitPointThreshold > 1.0) map.misfitPointThreshold = 1.0;
        map.update = true;
    } else if (keyCode == DOWN) {
        map.misfitPointThreshold -= 0.1;
        if (map.misfitPointThreshold < 0.0) map.misfitPointThreshold = 0.0;
        map.update = true;
    } else if (keyCode == RIGHT) {
        map.familiarityConstant += 0.01;
        if (map.familiarityConstant > 1.0) map.familiarityConstant = 1.0;        
        map.update = true;
    } else if (keyCode == LEFT) {
        map.familiarityConstant -= 0.01;
        if (map.familiarityConstant < 0.0) map.familiarityConstant = 0.0;
        map.update = true;
    }
  } else if (key == '+') {
    map.misfitRegionSoftness += 0.01;
    if (map.misfitRegionSoftness > 1.0) map.misfitRegionSoftness = 1.0;              
    map.update = true;
  } else if (key == '-') {
    map.misfitRegionSoftness -= 0.01;
    if (map.misfitRegionSoftness < 0.0) map.misfitRegionSoftness = 0.0;
    map.update = true;
  } else if (key == 'a' || key == 'A') {
    person.bodyValue += 0.1;
    if (person.bodyValue > 1.0) person.bodyValue = 1.0;        
    person.update = true;
  } else if (key == 'd' || key == 'D') {
    person.bodyValue -= 0.1;
    person.update = true;
    if (person.bodyValue < 0.0) person.bodyValue = 0.0;
  } else if (key == 'w' || key == 'W') {
    person.environmentValue -= 0.1;
    if (person.environmentValue < 0.0) person.environmentValue = 0.0;
    person.update = true;
  } else if (key == 's' || key == 'S') {
    person.environmentValue += 0.1;
    if (person.environmentValue > 1.0) person.environmentValue = 1.0;        
    person.update = true;
  } else if (key == 'r' || key == 'R') {
    saveImage("frame");
  } else if (key == 'g' || key == 'G') {
    generateSequence("pic");
  } else if (key == 'p' || key == 'P') {
    generateSequence(null);
  } else if (key == 'q' || key == 'Q') {
    exit();
  }

  if (DO_DEBUG) {
    println("misfitPointThreshold: " + map.misfitPointThreshold);
    println("misfitRegionSoftness: " + map.misfitRegionSoftness);
    println("familiarityConstant: " + map.familiarityConstant);
    println("bodyValue: " + person.bodyValue);
    println("environmentValue: " + person.environmentValue);
  }
}

void mouseClicked() {
  person.bodyValue = 1- getBodyComponentFor(mouseX - getCanvasLeft());
  person.environmentValue = getEnvironmentComponentFor(mouseY - getCenterY());
  person.update = true;
}

void renderCurrentCanvas() {
  renderCanvas.beginDraw();
  renderCanvas.clear();
  renderCanvas.background(minResistance);
  renderCanvas.image(map.canvas, 0, 0);
  renderCanvas.image(person.canvas, 0, 0);
  renderCanvas.endDraw();
}
  
void saveImage(String fn) {
  renderCurrentCanvas();
  renderCanvas.save(outputPath + fn + "-" + nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".jpg"); 
}

void generateSequence(String prefix) {
  isRendering = (prefix == null);
  
  int minBodyPosition = getPositionForBody(person.bodyValue - person.bodyRangeValue); 
  int maxBodyPosition = getPositionForBody(person.bodyValue + person.bodyRangeValue);
  
  float savedFamiliarity = map.familiarityConstant;
  float savedBodyValue = person.bodyValue;
  float saveEnvironmentValue = person.environmentValue;
  
  int famW = round(canvasWidth / cellGranularity);
  int famH = round(canvasHeight / cellGranularity);
  
  if (DO_DEBUG) {
    println("famW: " + famW);
    println("famH: " + famH);
  }
  
  float[][] familiarities;
  
  familiarities = new float[famW][famH];
  
  for (int i = 0; i < famW; i++) {
    for (int j = 0; j < famH; j++) {
      familiarities[i][j] = -0.01;
    }
  }
  
  int x;
  int y;
  int famX;
  int famY;

  int totalFrames = 100;
  
  for (int sequence = 0; sequence < totalFrames; sequence++) {
    println("Rendering frame: " + sequence);
    x = round(random(minBodyPosition, maxBodyPosition + 1));
    y = round(random(0, canvasHeight + 1));
    famX = round(x / cellGranularity);
    famY = round(y / cellGranularity);
    if (famX >= famW) famX = famW - 1;
    if (famY >= famH) famY = famH - 1;
    if (DO_DEBUG) {
      println("famX: " + famX);
      println("famY: " + famY);
    }
    person.bodyValue = getBodyComponentFor(x);
    person.environmentValue = getEnvironmentComponentFor(y);
    familiarities[famX][famY] += 0.01;
    if (familiarities[famX][famY] > 1.0) familiarities[famX][famY] = 1.0;
    map.familiarityConstant = familiarities[famX][famY];
    
    map.update = !isRendering;
    person.update = !isRendering;

    map.draw();
    person.draw();

    if (isRendering) {
      renderCurrentCanvas();
      renderCanvas.save(outputPath + prefix + nf(sequence + 1, 4) + ".jpg"); 
    }
  }

  map.familiarityConstant = savedFamiliarity;
  person.environmentValue = saveEnvironmentValue;
  person.bodyValue = savedBodyValue;
  
  isRendering = false;
  /*
  updateMap = true;
  updatePerson = true;
  */
}
