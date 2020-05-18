boolean DO_DEBUG = false;

//TODO: Decouple Person & Map from ResistanceMapper methods (that is, decouple rendering or create a mapper class?)

class Person {
  int size = 10;
  color shade = color(255, 0, 0);
  
  float bodyValue = 0.1; // 0 = perfectly typical, 1 = perfectly atypical
  float environmentValue = 0.1; // 0 = perfectly supportive, 1 = perfectly unsupportive

  float bodyRangeValue = 0.1;

  boolean update = true;
  boolean cleanHistory = true;

  PGraphics canvas;
  
  ResistanceMapper resistanceMapper;
  
  Person(int canvasWidth, int canvasHeight, ResistanceMapper rmapper) {
    canvas = createGraphics(canvasWidth, canvasHeight);
    resistanceMapper = rmapper;
  }
  
  void draw() {
    if (update) {
      canvas.beginDraw();
      
      if (cleanHistory) {
        canvas.clear();
        cleanHistory = false;
      }
        
      canvas.noStroke();
      canvas.fill(shade);
      canvas.circle(resistanceMapper.getPositionForBody(bodyValue), resistanceMapper.getPositionForEnvironment(environmentValue), size);
      canvas.endDraw();
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
    if (update) {
      float bodyComponent;
      float environmentComponent;
      float resistance;
      color resistanceColor;
  
      canvas.beginDraw();
      canvas.clear();
      
      canvas.background(resistanceMapper.minResistance);
          
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
  
  float bodyComponentWeight = 1;
  float environmentComponentWeight = 1;

  boolean isGeneratingSequence = false;
  boolean isSaving = false;

  color minResistance = color(0, 0, 0);
  color maxResistance = color(255, 255, 255);

  PGraphics canvas;

  Map map;
  Person person;

  // Sequencer state
  int minBodyPosition; 
  int maxBodyPosition;
    
  int famW = round(canvasWidth / cellGranularity);
  int famH = round(canvasHeight / cellGranularity);
      
  float[][] familiarities;
  
  int sequenceIndex;
  int totalFrames = 100;
  
  String sequencePrefix;
  //
  
  ResistanceMapper(int canvasWidth, int canvasHeight) {
    width = canvasWidth;
    height = canvasHeight;
  
    familiarities = new float[famW][famH];
    
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
    canvas.image(person.canvas, 0, 0);
    canvas.endDraw();
  }
    
  float getResistance(float body, float environment) {    
    float weightedBodyComponent = body * bodyComponentWeight;
    float weightedEnvironmentComponent = environment * environmentComponentWeight;
    return (1 - map.familiarityConstant) * ( (weightedBodyComponent + weightedEnvironmentComponent) / (1 + (weightedBodyComponent * weightedEnvironmentComponent)) );
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
  
  void increaseBodyComponentWeight() {
    bodyComponentWeight += 0.1;
    map.update = true;
  }    
  
  void decreaseBodyComponentWeight() {
    bodyComponentWeight -= 0.1;
    if (bodyComponentWeight < 0.0) bodyComponentWeight = 0.0;
    map.update = true;
  }    

  void increaseEnvironmentComponentWeight() {
    environmentComponentWeight += 0.1;
    map.update = true;
  }    
  
  void decreaseEnvironmentComponentWeight() {
    environmentComponentWeight -= 0.1;
    if (environmentComponentWeight < 0.0) environmentComponentWeight = 0.0;
    map.update = true;
  }    

  void mouseClicked(int mouseX, int mouseY) {
    person.bodyValue = getBodyComponentFor(mouseX - getCanvasLeft());
    person.environmentValue = 1 - getEnvironmentComponentFor(mouseY - getCenterY());
    person.update = true;
    println("RESISTANCE here is " + getResistance(person.bodyValue, person.environmentValue));
  }

  void startSaveMode(String prefix) {
    isSaving = true;
    sequencePrefix = prefix;
  }

  void stopSaveMode() {
    isSaving = false;
  }
  
  void sequenceStart() {
    isGeneratingSequence = true;
    
    minBodyPosition = getPositionForBody(person.bodyValue - person.bodyRangeValue); 
    maxBodyPosition = getPositionForBody(person.bodyValue + person.bodyRangeValue);
            
    for (int i = 0; i < famW; i++) {
      for (int j = 0; j < famH; j++) {
        familiarities[i][j] = -0.01;
      }
    }
    
    sequenceIndex = 0;
  }
  
  void sequenceNext() {
    int x;
    int y;
    int famX;
    int famY;
  
    x = round(random(minBodyPosition, maxBodyPosition + 1));
    y = round(random(0, canvasHeight + 1));
    
    famX = round(x / cellGranularity);
    famY = round(y / cellGranularity);
    if (famX >= famW) famX = famW - 1;
    if (famY >= famH) famY = famH - 1;

    person.bodyValue = getBodyComponentFor(x);
    person.environmentValue = getEnvironmentComponentFor(y);
    familiarities[famX][famY] += 0.01;
    if (familiarities[famX][famY] > 1.0) familiarities[famX][famY] = 1.0;
    map.familiarityConstant = familiarities[famX][famY];
    
    map.update = true;
    person.update = true;

    draw();

    if (isSaving) {
      println("Saving frame: " + sequenceIndex);
      canvas.save(outputPath + sequencePrefix + nf(sequenceIndex + 1, 4) + ".jpg"); 
    }

    sequenceIndex++;
    
    if (sequenceIndex >= totalFrames) sequenceStop();
  }
  
  void sequenceStop() {
    stopSaveMode();
    isGeneratingSequence = false;
  }
  
  void clean() {
    sequenceStop();
    person.update = true;
    person.cleanHistory = true;
  }
}

// State variables
int cellGranularity = 100;

// Settings

String outputPath = "/Users/adapar/Devel/resistance_mapper/output/";

boolean useFullScreen = false;

int canvasWidth = 512;
int canvasHeight = 512;

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
  frameRate(24);
}

void draw() {
  if (resistanceMapper.isGeneratingSequence) {
    resistanceMapper.sequenceNext();
  }
  resistanceMapper.draw();    

  scale(1, -1);
  translate(0, -canvasHeight);
  
  image(resistanceMapper.canvas, getCanvasLeft(), getCenterY());
}

int getCanvasLeft() {
  return round((width - canvasWidth) / 2);
}

int getCenterY() {
  return round((height - canvasHeight) / 2);
}

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
    resistanceMapper.person.decreaseBodyConformance();
  } else if (key == 'd' || key == 'D') {
    resistanceMapper.person.increaseBodyConformance();
  } else if (key == 'w' || key == 'W') {
    resistanceMapper.person.decreaseEnvironmentalSupport();
  } else if (key == 's' || key == 'S') {
    resistanceMapper.person.increaseEnvironmentalSupport();
  } else if (key == 'l' || key == 'L') {
    resistanceMapper.increaseBodyComponentWeight();
  } else if (key == 'j' || key == 'J') {
    resistanceMapper.decreaseBodyComponentWeight();
  } else if (key == 'i' || key == 'I') {
    resistanceMapper.increaseEnvironmentComponentWeight();
  } else if (key == 'k' || key == 'K') {
    resistanceMapper.decreaseEnvironmentComponentWeight();
  } else if (key == 'r' || key == 'R') {
    saveImage("frame");
  } else if (key == 'g' || key == 'G') {
    resistanceMapper.startSaveMode("pic");
    resistanceMapper.sequenceStart();
  } else if (key == 'p' || key == 'P') {
    resistanceMapper.stopSaveMode();
    resistanceMapper.sequenceStart();
  } else if (key == 'x' || key == 'X') {
    resistanceMapper.stopSaveMode();
    resistanceMapper.sequenceStop();
  } else if (key == 'c' || key == 'C') {
    resistanceMapper.clean();
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
