import processing.video.*;
import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port
int numberReceived = 0; // number received from arduino

int currentVideoNumber = 0; // hold the number of the video currently being played

// All video paths below
String PATH_1 = "one.mp4"; // movie file name (this can be changed according to video file) 
String PATH_2 = "two.mp4";
String PATH_3 = "TEST1sound.mov";
String PATH_STATIC = "static.mp4";

// All movies below
Movie mov1; 
Movie mov2; 
Movie mov3; 
Movie movStatic;
Movie currentMovie;

void setup()
{
  //size(1280, 720);
  fullScreen();
  
// I know that the first port in the serial list on my mac
// is Serial.list()[0].
// On Windows machines, this generally opens COM1.
// Open whatever port is the one you're using.
  String portName = Serial.list()[1]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600); 
  
  setupVideo();
  playMovie(currentMovie);
}

void setupVideo() {
  frameRate(30);
  // initate all movies
  mov1 = initiateMovie(PATH_1);
  mov2 = initiateMovie(PATH_2);
  mov3 = initiateMovie(PATH_3);
  movStatic = initiateMovie(PATH_STATIC);
  currentMovie = movStatic;
}

Movie initiateMovie(String path) {
   Movie mov = new Movie(this, path);
   mov.speed(1);
   mov.volume(10);
   return mov;
}

void playMovie(Movie mov) {
  if (currentMovie != null) {
     currentMovie.stop();
  }
  currentMovie = mov;
  currentMovie.loop();
}

void playMovieForNumber(int numberOfMovie) {
   if (numberOfMovie == 1) {
     playMovie(mov1);
   } else if(numberOfMovie == 2) {
     playMovie(mov2);
   } else if(numberOfMovie == 3) {
     playMovie(mov3);
   } else if (numberOfMovie == 0) {
     playMovie(movStatic);
   }
}


void movieEvent(Movie m) {
  m.read();
}

void draw()
{
  if (currentMovie != null) 
    image(currentMovie, 0, 0, width, height);
  
  if ( myPort.available() > 0) 
  {  
    // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
   
   // try to parse integer from arduino
   // if an error happens, ignore it
    try
    {
      String valWithNoSpaces = trim(val);         // remove spaces from the string that was read from arduino
      numberReceived = Integer.parseInt(valWithNoSpaces);  // parse number from string
    }
    catch(Exception e) {}// some error happened, but it was ignored
  
    // if the value read from arduino is different from the video that is being played, 
    // then we need to change the video
    boolean videoNeedsToBeChanged = currentVideoNumber != numberReceived;
    if (videoNeedsToBeChanged) { 
      println(numberReceived);
      currentVideoNumber = numberReceived;
      // actually change video here
      playMovieForNumber(numberReceived);
    }
 } 
  
  //println(numberReceived); //print it out in the console
  delay(50);
}