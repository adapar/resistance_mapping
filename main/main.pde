boolean DO_DEBUG = false;

//TODO: Decouple Person & Map from ResistanceMapper methods (that is, decouple rendering or create a mapper class?)

class Person {
  int size = 10;
  color shade = color(255, 0, 0);
  
  float bodyValue = 0.9; // 1 = perfectly typical, 0 = perfectly atypical
  float environmentValue = 0.9; // 1 = perfectly supportive, 0 = perfectly unsupportive

  float bodyRangeValue = 0.1;

  boolean update = false;

  PGraphics canvas;
  
  ResistanceMapper resistanceMapper;
  
  Person(int canvasWidth, int canvasHeight, ResistanceMapper rmapper) {
    canvas = createGraphics(canvasWidth, canvasHeight);
    resistanceMapper = rmapper;
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
      canvas.circle(resistanceMapper.getPositionForBody(bodyValue), resistanceMapper.getPositionForEnvironment(environmentValue), size);
      canvas.endDraw();
      //TODO: decide about this
      //drawBodyRange();
    }  
    update = false;
  }
  
  void increaseBodyConformance() {
    bodyValue += 0.1;
    if (bodyValue > 1.0) bodyValue = 1.0;        
    update = true;
  }
  
  void decreaseBodyConformance() {
    bodyValue -= 0.1;
    update = true;
    if (bodyValue < 0.0) bodyValue = 0.0;
  }
  
  void increaseEnvironmentalSupport() {
    environmentValue -= 0.1;
    if (environmentValue < 0.0) environmentValue = 0.0;
    update = true;
  }
  
  void decreaseEnvironmentalSupport() {
    environmentValue += 0.1;
    if (environmentValue > 1.0) environmentValue = 1.0;        
    update = true;
  }
}

class Map {
  float misfitPointThreshold = 0.5;
  float misfitRegionSoftness = 0.0;
  float familiarityConstant = 0; // 0 = no familiarity, 1 = complete familiarity

  boolean update = true;

  PGraphics canvas;

  ResistanceMapper resistanceMapper;
  
  Map(int canvasWidth, int canvasHeight, ResistanceMapper rmapper) {
    canvas = createGraphics(canvasWidth, canvasHeight);
    resistanceMapper = rmapper;
  }
  
  void draw() {
    if (isRendering || update) {
      float bodyComponent;
      float environmentComponent;
      float resistance;
      color resistanceColor;
  
      canvas.beginDraw();
      canvas.clear();
      
      canvas.background(resistanceMapper.minResistance);
      
      canvas.scale(-1, 1);
      canvas.translate(-canvasWidth, 0);
    
      for (int x = 0; x < canvasWidth; x++) {
        for (int y = 0; y < canvasHeight; y++) {
          bodyComponent = resistanceMapper.getBodyComponentFor(x);
          environmentComponent = resistanceMapper.getEnvironmentComponentFor(y);
          resistance = resistanceMapper.getResistance(bodyComponent, environmentComponent);
          resistanceColor = resistanceMapper.getResistanceColor(resistance);
          if (resistanceColor != resistanceMapper.minResistance) {
            canvas.stroke(resistanceColor);
            canvas.point(x, y);
          }
        }
      }
      canvas.endDraw();
    }
    update = false;
  }
  
  void increaseMisfitPointThreshold() {
    misfitPointThreshold += 0.1;
    if (misfitPointThreshold > 1.0) misfitPointThreshold = 1.0;
    update = true;
  }    
  
  void decreaseMisfitPointThreshold() {
    misfitPointThreshold -= 0.1;
    if (misfitPointThreshold < 0.0) misfitPointThreshold = 0.0;
    update = true;
  }    
  
  void increaseFamiliarityConstant() {
    familiarityConstant += 0.01;
    if (familiarityConstant > 1.0) familiarityConstant = 1.0;        
    update = true;
  }
  
  void decreaseFamiliarityConstant() {
    familiarityConstant -= 0.01;
    if (familiarityConstant < 0.0) familiarityConstant = 0.0;
    update = true;
  }
  
  void increaseMisfitRegionSoftness() {
    misfitRegionSoftness += 0.01;
    if (misfitRegionSoftness > 1.0) misfitRegionSoftness = 1.0;              
    update = true;
  }

  void decreaseMisfitRegionSoftness() {
    misfitRegionSoftness -= 0.01;
    if (misfitRegionSoftness < 0.0) misfitRegionSoftness = 0.0;
    update = true;
  }
}

class ResistanceMapper {
  int width;
  int height;

  boolean update = false;

  color minResistance = color(0, 0, 0);
  color maxResistance = color(255, 255, 255);

  PGraphics canvas;

  Map map;
  Person person;

  ResistanceMapper(int canvasWidth, int canvasHeight) {
    width = canvasWidth;
    height = canvasHeight;
  
    canvas = createGraphics(canvasWidth, canvasHeight);

    map = new Map(canvasWidth, canvasHeight, this);
    person = new Person(canvasWidth, canvasHeight, this);
  }

  void draw() {
    map.draw();
    person.draw();
   
    canvas.beginDraw();
    canvas.clear();
    canvas.background(minResistance);
    canvas.image(map.canvas, 0, 0);
    /*
    if (renderBodyRange) {
      image(bodyRange, getCanvasLeft(), getCenterY());
    }
    */
    canvas.image(person.canvas, 0, 0);
    canvas.endDraw();
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
  
  void mouseClicked(int mouseX, int mouseY) {
    person.bodyValue = 1 - getBodyComponentFor(mouseX - getCanvasLeft());
    person.environmentValue = getEnvironmentComponentFor(mouseY - getCenterY());
    person.update = true;
  }
  
  void updatePersonByCoordinates(int x, int y) {
    person.bodyValue = getBodyComponentFor(x);
    person.environmentValue = getEnvironmentComponentFor(y);
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


PGraphics bodyRange;

ResistanceMapper resistanceMapper;

public void settings() {
  if (useFullScreen) {
    fullScreen(2);
  } else {
    size (canvasWidth, canvasHeight);
  }
}

void setup() {  
  resistanceMapper = new ResistanceMapper(canvasWidth, canvasHeight);
  
  background(128);
  
  bodyRange = createGraphics(canvasWidth, canvasHeight);
}

void draw() {
  //print("isRendering = " + isRendering + ", ");
  if (!isRendering) {
    //println("drawing...");
    resistanceMapper.draw();
    image(resistanceMapper.canvas, getCanvasLeft(), getCenterY());
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


void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
        resistanceMapper.map.increaseMisfitPointThreshold();
    } else if (keyCode == DOWN) {
        resistanceMapper.map.decreaseMisfitPointThreshold();
    } else if (keyCode == RIGHT) {
        resistanceMapper.map.increaseFamiliarityConstant();
    } else if (keyCode == LEFT) {
        resistanceMapper.map.decreaseFamiliarityConstant();
    }
  } else if (key == '+') {
    resistanceMapper.map.increaseMisfitRegionSoftness();
  } else if (key == '-') {
    resistanceMapper.map.decreaseMisfitRegionSoftness();
  } else if (key == 'a' || key == 'A') {
    resistanceMapper.person.increaseBodyConformance();
  } else if (key == 'd' || key == 'D') {
    resistanceMapper.person.decreaseBodyConformance();
  } else if (key == 'w' || key == 'W') {
    resistanceMapper.person.increaseEnvironmentalSupport();
  } else if (key == 's' || key == 'S') {
    resistanceMapper.person.decreaseEnvironmentalSupport();
  } else if (key == 'r' || key == 'R') {
    saveImage("frame");
  } else if (key == 'g' || key == 'G') {
    generateSequence("pic");
  } else if (key == 'p' || key == 'P') {
    generateSequence(null);
  } else if (key == 'q' || key == 'Q') {
    exit();
  }
}

void mouseClicked() {
  resistanceMapper.mouseClicked(mouseX, mouseY);
}
  
void saveImage(String fn) {
  resistanceMapper.draw();
  resistanceMapper.canvas.save(outputPath + fn + "-" + nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".jpg"); 
}

void generateSequence(String prefix) {
  isRendering = (prefix == null);
  
  int minBodyPosition = resistanceMapper.getPositionForBody(resistanceMapper.person.bodyValue - resistanceMapper.person.bodyRangeValue); 
  int maxBodyPosition = resistanceMapper.getPositionForBody(resistanceMapper.person.bodyValue + resistanceMapper.person.bodyRangeValue);
  
  float savedFamiliarity = resistanceMapper.map.familiarityConstant;
  float savedBodyValue = resistanceMapper.person.bodyValue;
  float saveEnvironmentValue = resistanceMapper.person.environmentValue;
  
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
    resistanceMapper.updatePersonByCoordinates(x, y);
    familiarities[famX][famY] += 0.01;
    if (familiarities[famX][famY] > 1.0) familiarities[famX][famY] = 1.0;
    resistanceMapper.map.familiarityConstant = familiarities[famX][famY];
    
    resistanceMapper.map.update = !isRendering;
    resistanceMapper.person.update = !isRendering;

    resistanceMapper.draw();

    if (isRendering) {
      resistanceMapper.canvas.save(outputPath + prefix + nf(sequence + 1, 4) + ".jpg"); 
    }
  }

  resistanceMapper.map.familiarityConstant = savedFamiliarity;
  resistanceMapper.person.environmentValue = saveEnvironmentValue;
  resistanceMapper.person.bodyValue = savedBodyValue;
  
  isRendering = false;

  resistanceMapper.map.update = true;
  resistanceMapper.person.update = true;
}
