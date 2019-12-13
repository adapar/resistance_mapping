// State variables
float misfitPointThreshold = 0.5;
float misfitRegionSoftness = 0.03;

float bodyValue = 0.1;
float environmentalValue = 0.1;
float familiarityConstant = 0;

boolean updateMap = true;
boolean updatePerson = true;

// Settings

boolean useFullScreen = false;
boolean shiftModifier = false;
boolean controlModifier = false;

int canvasSize = 512;

color minResistance = color(255, 255, 255);
color maxResistance = color(24, 128, 56);

int personSize = 10;
color personColor = color(0, 0, 0);

PGraphics map;
PGraphics person;

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
}

void draw() {
  drawMap();
  drawPerson();
  background(minResistance);
  image(map, 0, 0);
  image(person, 0, 0);
}

void drawMap() {
  if (updateMap) {
    float bodyComponent;
    float environmentComponent;
    float resistance;
    color resistanceColor;

    map.beginDraw();
    map.clear();
    
    map.scale(1, -1);
    map.translate(0, -height);
  
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
  if (updatePerson) {
    person.beginDraw();
    person.clear();
    
    person.scale(1, -1);
    person.translate(0, -height);

    person.noStroke();
    person.fill(personColor);
    person.circle(getPositionForBody(bodyValue), getPositionForEnvironment(environmentalValue), personSize);
    person.endDraw();
  }  
  updatePerson = false;
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
  return (1 - familiarityConstant) - ((1 - body) * (1 - environment));
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
    bodyValue -= 0.1;
    updatePerson = true;
    if (bodyValue < 0.0) bodyValue = 0.0;
  } else if (key == 'd' || key == 'D') {
    bodyValue += 0.1;
    if (bodyValue > 1.0) bodyValue = 1.0;        
    updatePerson = true;
  } else if (key == 'w' || key == 'W') {
    environmentalValue += 0.1;
    if (environmentalValue > 1.0) environmentalValue = 1.0;        
    updatePerson = true;
  } else if (key == 's' || key == 'S') {
    environmentalValue -= 0.1;
    if (environmentalValue < 0.0) environmentalValue = 0.0;
    updatePerson = true;
  } else if (key == 'q' || key == 'Q') {
    exit();
  }

  println("misfitPointThreshold: " + misfitPointThreshold);
  println("misfitRegionSoftness: " + misfitRegionSoftness);
  println("familiarityConstant: " + familiarityConstant);
  println("bodyValue: " + bodyValue);
  println("environmentalValue: " + environmentalValue);
}

void mouseClicked() {
  bodyValue = getBodyComponentFor(mouseX);
  environmentalValue = getEnvironmentComponentFor(height - mouseY);

  updatePerson = true;
}
