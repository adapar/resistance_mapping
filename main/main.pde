boolean DO_DEBUG = false;

// State variables
float misfitPointThreshold = 0.5;
float misfitRegionSoftness = 0.0;

float bodyValue = 0.9; // 1 = perfectly typical, 0 = perfectly atypical
float environmentValue = 0.9; // 1 = perfectly supportive, 0 = perfectly unsupportive
float familiarityConstant = 0; // 0 = no familiarity, 1 = complete familiarity

float bodyRangeValue = 0.1;

boolean updateMap = true;
boolean updatePerson = true;
boolean renderBodyRange = false;
boolean isRendering = false;

int cellGranularity = 100;

// Settings

String outputPath = "/Users/adapar/Devel/resistance_mapper/output/";

boolean useFullScreen = false;

int canvasSize = 512;

color minResistance = color(255, 255, 255);
color maxResistance = color(128, 128, 128);

int personSize = 10;
color personColor = color(0, 0, 0);

PGraphics map;
PGraphics person;
PGraphics bodyRange;
PGraphics renderCanvas;

public void settings() {
  if (useFullScreen) {
    fullScreen(2);
  } else {
    size (canvasSize, canvasSize);
  }
}

void setup() {
  background(minResistance);
  map = createGraphics(width, height);
  person = createGraphics(width, height);
  bodyRange = createGraphics(width, height);
  renderCanvas = createGraphics(width, height);
}

void draw() {
  if (!isRendering) {
    drawMap();
    drawPerson();
    background(minResistance);
    image(map, 0, 0);
    if (renderBodyRange) {
      image(bodyRange, 0, 0);
    }
    image(person, 0, 0);
  }
}

void drawMap() {
  if (isRendering || updateMap) {
    float bodyComponent;
    float environmentComponent;
    float resistance;
    color resistanceColor;

    map.beginDraw();
    map.clear();
    
    map.scale(-1, 1);
    map.translate(-width, 0);
  
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        bodyComponent = getBodyComponentFor(x);
        environmentComponent = getEnvironmentComponentFor(y);
        resistance = getResistance(bodyComponent, environmentComponent);
        resistanceColor = getResistanceColor(resistance);
        if (resistanceColor != minResistance) {
          map.stroke(resistanceColor);
          map.point(x, y);
        }
      }
    }
    map.endDraw();
  }
  updateMap = false;
}

void drawPerson() {
  if (isRendering || updatePerson) {
    person.beginDraw();
    
    if (!isRendering) {
      person.clear();
    }
    
    person.scale(-1, 1);
    person.translate(-width, 0);

    person.noStroke();
    person.fill(personColor);
    person.circle(getPositionForBody(bodyValue), getPositionForEnvironment(environmentValue), personSize);
    person.endDraw();
    if (DO_DEBUG) {
      println("RESISTANCE AT THIS POINT IS: " + getResistance(bodyValue, environmentValue));
    }
    drawBodyRange();
  }  
  updatePerson = false;
}

void drawBodyRange() {
  bodyRange.beginDraw();
  bodyRange.clear();
  bodyRange.scale(-1, 1);
  bodyRange.translate(-width, 0);
  bodyRange.noStroke();
  bodyRange.fill(color(255, 0, 0, 64));
  bodyRange.rect(getPositionForBody(bodyValue - bodyRangeValue), 0, getPositionForBody(bodyRangeValue) * 2, height);
  bodyRange.endDraw();
}

float getBodyComponentFor(float value) {
  return value/width;
}

float getEnvironmentComponentFor(float value) {
  return value/height;
}

int getPositionForBody(float value) {
  return round(value * width);
}

int getPositionForEnvironment(float value) {
  return round(value * height);
}

float getResistance(float body, float environment) {
  return (1 - familiarityConstant) * (1 - (body * environment));
}

color getResistanceColor(float resistance) {
  color output;
  float delta = resistance - misfitPointThreshold;
  if (abs(delta) <= misfitRegionSoftness) {
    float interpolationRange = 2 * misfitRegionSoftness;
    float interpolationRangeStart = misfitPointThreshold - misfitRegionSoftness;    
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
        misfitPointThreshold += 0.1;
        if (misfitPointThreshold > 1.0) misfitPointThreshold = 1.0;
        updateMap = true;
    } else if (keyCode == DOWN) {
        misfitPointThreshold -= 0.1;
        if (misfitPointThreshold < 0.0) misfitPointThreshold = 0.0;
        updateMap = true;
    } else if (keyCode == RIGHT) {
        familiarityConstant += 0.01;
        if (familiarityConstant > 1.0) familiarityConstant = 1.0;        
        updateMap = true;
    } else if (keyCode == LEFT) {
        familiarityConstant -= 0.01;
        if (familiarityConstant < 0.0) familiarityConstant = 0.0;
        updateMap = true;
    }
  } else if (key == '+') {
    misfitRegionSoftness += 0.01;
    if (misfitRegionSoftness > 1.0) misfitRegionSoftness = 1.0;              
    updateMap = true;
  } else if (key == '-') {
    misfitRegionSoftness -= 0.01;
    if (misfitRegionSoftness < 0.0) misfitRegionSoftness = 0.0;
    updateMap = true;
  } else if (key == 'a' || key == 'A') {
    bodyValue += 0.1;
    if (bodyValue > 1.0) bodyValue = 1.0;        
    updatePerson = true;
  } else if (key == 'd' || key == 'D') {
    bodyValue -= 0.1;
    updatePerson = true;
    if (bodyValue < 0.0) bodyValue = 0.0;
  } else if (key == 'w' || key == 'W') {
    environmentValue -= 0.1;
    if (environmentValue < 0.0) environmentValue = 0.0;
    updatePerson = true;
  } else if (key == 's' || key == 'S') {
    environmentValue += 0.1;
    if (environmentValue > 1.0) environmentValue = 1.0;        
    updatePerson = true;
  } else if (key == 'r' || key == 'R') {
    saveImage("frame");
  } else if (key == 'g' || key == 'G') {
    generateSequence("pic");
  } else if (key == 'q' || key == 'Q') {
    exit();
  }

  if (DO_DEBUG) {
    println("misfitPointThreshold: " + misfitPointThreshold);
    println("misfitRegionSoftness: " + misfitRegionSoftness);
    println("familiarityConstant: " + familiarityConstant);
    println("bodyValue: " + bodyValue);
    println("environmentValue: " + environmentValue);
  }
}

void mouseClicked() {
  bodyValue = getBodyComponentFor(width - mouseX);
  environmentValue = getEnvironmentComponentFor(mouseY);
  updatePerson = true;
}

void renderCurrentCanvas() {
  renderCanvas.beginDraw();
  renderCanvas.clear();
  renderCanvas.background(minResistance);
  renderCanvas.image(map, 0, 0);
  renderCanvas.image(person, 0, 0);
  renderCanvas.endDraw();
}
  
void saveImage(String fn) {
  renderCurrentCanvas();
  renderCanvas.save(outputPath + fn + "-" + nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".jpg"); 
}

void generateSequence(String prefix) {
  isRendering = true;
  
  int minBodyPosition = getPositionForBody(bodyValue - bodyRangeValue); 
  int maxBodyPosition = getPositionForBody(bodyValue + bodyRangeValue);
  
  float savedFamiliarity = familiarityConstant;
  float savedBodyValue = bodyValue;
  float saveEnvironmentValue = environmentValue;
  
  int famW = round(width / cellGranularity);
  int famH = round(height / cellGranularity);
  
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
    y = round(random(0, height + 1));
    famX = round(x / cellGranularity);
    famY = round(y / cellGranularity);
    if (famX >= famW) famX = famW - 1;
    if (famY >= famH) famY = famH - 1;
    if (DO_DEBUG) {
      println("famX: " + famX);
      println("famY: " + famY);
    }
    bodyValue = getBodyComponentFor(x);
    environmentValue = getEnvironmentComponentFor(y);
    familiarities[famX][famY] += 0.01;
    if (familiarities[famX][famY] > 1.0) familiarities[famX][famY] = 1.0;
    familiarityConstant = familiarities[famX][famY];
    
    drawMap();
    drawPerson();
    
    renderCanvas.beginDraw();
    renderCanvas.clear();
    renderCanvas.background(minResistance);
    renderCanvas.image(map, 0, 0);
    renderCanvas.image(person, 0, 0);
    renderCanvas.endDraw();
    renderCanvas.save(outputPath + prefix + nf(sequence + 1, 4) + ".jpg"); 
  }

  familiarityConstant = savedFamiliarity;
  environmentValue = saveEnvironmentValue;
  bodyValue = savedBodyValue;
  
  isRendering = false;
  
  updateMap = true;
  updatePerson = true;
}
