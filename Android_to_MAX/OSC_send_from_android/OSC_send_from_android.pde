import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import oscP5.*;
import netP5.*;

Context context;
SensorManager manager;
Sensor sensor;
AccelerometerListener listener;
float ax, ay, az;
boolean touchStart = false;
boolean isRec = false;
boolean isLoop = false;
// Make sure to enable permissions INTERNET for the sketch
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  fullScreen();
  fill(255,0,0);
  rect(0,0, width / 2 , height / 2);
  fill(242,123,44);
  rect(width / 2, 0, width , height / 2);
  context = getActivity();
  manager = (SensorManager)context.getSystemService(Context.SENSOR_SERVICE);
  sensor = manager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
  listener = new AccelerometerListener();
  manager.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_GAME);
  
  textFont(createFont("SansSerif", 30 * displayDensity));
  oscP5 = new OscP5(this,32000);// listening to port 32000
  //myRemoteLocation = new NetAddress("10.6.33.156",6448); //lab
  myRemoteLocation = new NetAddress("192.168.75.60",6448); //home
}

void draw() {
  //background(0);
  fill(0);
  rect(0, height /2, width, height);
  stroke(192, 192,192);
  line(width / 2, height / 2, width /2, height);
  line(0, 3*height/4, width, 3*height/4);
  //text("X: " + ax + "\nY: " + ay + "\nZ: " + az, 0, 0, width, height);
  
  OscMessage myMessage = new OscMessage("/wek/inputs");
  myMessage.add(ax);
  myMessage.add(ay);
  myMessage.add(az);
  oscP5.send(myMessage, myRemoteLocation); 
  
  OscMessage myMessage1 = new OscMessage("/touchEvent");
  if(touchStart && mouseY > height / 2) {
    myMessage1.add(1);
    myMessage1.add(mouseX);
    myMessage1.add(mouseY);
  }
  
  oscP5.send(myMessage1, myRemoteLocation);
  
  if(mouseY > height / 2) {
  float r=0;
  float g=0;
    if(mouseX !=0) {
    r = mouseX*255 / width;
    g = mouseY*255 / height;
    }
  //text("X: " + r + "\nY: " + g , 0, 0, width, height);
  fill(r,g,0);
  circle(mouseX, mouseY, 100);
  }
}

void touchStarted() {
  //text("touch started x:" + mouseX + " mouseY: " + mouseY, mouseX , mouseY );
  touchStart = true;
  if(touches[0].x < width /2 && touches[0].y < height / 2) {
    if(isRec == false) {
      fill(0,255,0);
      rect(0,0,width /2, height /2);
      isRec = true;
      OscMessage myMessageRec = new OscMessage("/recordEvent");
      myMessageRec.add(1);
      oscP5.send(myMessageRec, myRemoteLocation); 
    } else {
      fill(255,0,0);
      rect(0,0,width/2, height /2);
      isRec = false;
      OscMessage myMessageRec = new OscMessage("/recordEvent");
      myMessageRec.add(0);
      oscP5.send(myMessageRec, myRemoteLocation); 
    }
  } else if (touches[0].x > width /2 && touches[0].y < height / 2) {
      if(isLoop == false) {
      fill(242,235,44);
      rect(width / 2 ,0,width, height /2);
      isLoop = true;
      OscMessage myMessageLoop = new OscMessage("/loopEvent");
      myMessageLoop.add(1);
      oscP5.send(myMessageLoop, myRemoteLocation); 
    } else {
      fill(242,123,44);
      rect(width /2,0,width, height /2);
      isLoop = false;
      OscMessage myMessageLoop = new OscMessage("/loopEvent");
      myMessageLoop.add(0);
      oscP5.send(myMessageLoop, myRemoteLocation); 
    }
  }
}

void touchMoved() {
  println("touch moved"); 
}

void touchEnded() {
  println("touch ended");
  touchStart = false;
}

class AccelerometerListener implements SensorEventListener {
  public void onSensorChanged(SensorEvent event) {
    ax = event.values[0];
    ay = event.values[1];
    az = event.values[2];    
  }
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
  }
}
