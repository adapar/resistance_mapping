// State variables
float disabilityPointThreshold = 0.3;
float disabilityRegionSoftness = 0.01;

float bodyValue = 0.5;
float environmentalValue = 0.5;
float familiarityConstant = 0.5;

// Settings
boolean useFullScreen = false;
boolean shiftModifier = false;
boolean controlModifier = false;

int canvasSize = 512;

color maxResistance = color(255, 255, 255);
color minResistance = color(0, 0, 0);

int personSize = 10;
color personColor = color(255, 0, 0);

public void settings() {
  if (useFullScreen) {
    fullScreen(2);
  } else {
    size (canvasSize, canvasSize);
  }
}

void setup() {
  background(minResistance); // Fill in black in case cells don't cover all the windows
}

void draw() {

  float bodyComponent;
  float environmentComponent;
  float resistance;
  color resistanceColor;
  
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      bodyComponent = getBodyComponentFor(x);
      environmentComponent = getEnvironmentComponentFor(y);
      resistance = getResistance(bodyComponent, environmentComponent);
      resistanceColor = getResistanceColor(resistance);
      stroke(resistanceColor);
      point(x, y);
      noStroke();
      fill(personColor);
      //circle(getPositionForBody(bodyValue), getPositionForEnvironment(environmentalValue), personSize);
    }
  }
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
  return (1 - familiarityConstant) * body * environment;
}

color getResistanceColor(float resistance) {
  color output;
  float delta = resistance - disabilityPointThreshold;
  if (abs(delta) <= disabilityRegionSoftness) {
    float interpolationRange = 2 * disabilityRegionSoftness;
    float interpolationRangeStart = disabilityPointThreshold - disabilityRegionSoftness;    
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
    if (keyCode == SHIFT) {
      shiftModifier = true;
    } else if (keyCode == CONTROL) {
      controlModifier = true;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) {
      if (shiftModifier) {
        disabilityPointThreshold += 0.1;
        if (disabilityPointThreshold > 1.0) disabilityPointThreshold = 1.0;        
      } else if (controlModifier) {
        disabilityRegionSoftness += 0.1;
        if (disabilityRegionSoftness > 1.0) disabilityRegionSoftness = 1.0;        
      } else {
        environmentalValue += 0.1;
        if (environmentalValue > 1.0) environmentalValue = 1.0;        
      }
    } else if (keyCode == DOWN) {
      if (shiftModifier) {
        disabilityPointThreshold -= 0.1;
        if (disabilityPointThreshold < 0.0) disabilityPointThreshold = 0.0;
      } else if (controlModifier) {
        disabilityRegionSoftness -= 0.1;
        if (disabilityRegionSoftness < 0.0) disabilityRegionSoftness = 0.0;
      } else {
        environmentalValue -= 0.1;
        if (environmentalValue < 0.0) environmentalValue = 0.0;
      }
    } else if (keyCode == LEFT) {
      if (shiftModifier) {
        familiarityConstant += 0.1;
        if (familiarityConstant > 1.0) familiarityConstant = 1.0;        
      } else {
        bodyValue += 0.1;
        if (bodyValue > 1.0) bodyValue = 1.0;        
      }
    } else if (keyCode == RIGHT) {
      if (shiftModifier) {
        familiarityConstant -= 0.1;
        if (familiarityConstant < 0.0) familiarityConstant = 0.0;
      } else {
        bodyValue -= 0.1;
        if (bodyValue < 0.0) bodyValue = 0.0;
      }
    }
  }
  shiftModifier = false;
  controlModifier = false;
}
