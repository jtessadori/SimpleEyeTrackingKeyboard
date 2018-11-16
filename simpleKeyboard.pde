import processing.net.*;
import processing.serial.*;
import hypermedia.net.*;

UDP udp;
String receivedFromUDP = "";
int PORT_RX=11000; //port
int screenWidth, screenHeight;
float textVcenter=0.4;
float buttonLowerLimRel=0.55;
int textMargin=20;
float buttonHeightRel=.3;
String currentText="";
String[] keys;
String[] mainButtonsString;
float buttonWidth;
int nButtons;
float[] buttonLeftLims;
int selectionTime = 1500;
int currSelectedKey=-1;
int prevSelectedKey;
int timerStart;
boolean mainKeySet=true;
int currKeySet=-1;

void setup()
{
  textSize(64);
  fullScreen(1);
  screenWidth=displayWidth;
  screenHeight=displayHeight;
  keys= new String[29];
  keys[0]="A";
  keys[1]="B";
  keys[2]="C";
  keys[3]="D";
  keys[4]="E";
  keys[5]="F";
  keys[6]="G";
  keys[7]="H";
  keys[8]="I";
  keys[9]="J";
  keys[10]="K";
  keys[11]="L";
  keys[12]="M";
  keys[13]="N";
  keys[14]="O";
  keys[15]="P";
  keys[16]="Q";
  keys[17]="R";
  keys[18]="S";
  keys[19]="T";
  keys[20]="U";
  keys[21]="V";
  keys[22]="W";
  keys[23]="X";
  keys[24]="Y";
  keys[25]="Z";
  keys[26]="Bs";
  keys[27]="Clear";
  keys[28]="_";
  nButtons=ceil(sqrt(keys.length));
  mainButtonsString = new String[nButtons];
  buttonLeftLims=new float[nButtons];
  int maxButtonsPerString=ceil(sqrt(keys.length));
  for (int currButton=0;currButton<nButtons;currButton++)
  {
    buttonWidth=screenWidth/(nButtons+2);
    buttonLeftLims[currButton]=buttonWidth*(1+currButton);
    for (int secButton=0;secButton<maxButtonsPerString;secButton++)
    {
      if ((nButtons)*currButton+secButton<keys.length)
      {
        if (mainButtonsString[currButton]==null)
        {
          mainButtonsString[currButton]=keys[(nButtons)*currButton+secButton];
        }
        else
        {
          mainButtonsString[currButton]=mainButtonsString[currButton]+" "+keys[(nButtons)*currButton+secButton];
        }
      }
    }
  }
  initialize();
}

void initialize() {
  // Setup udp listening for incoming Tobii data
  udp = new UDP(this, PORT_RX);
  // udp.log(true);
  udp.listen(true);
 
}

void draw()
{
  background(60);
  text(currentText,.1*screenWidth,textVcenter*screenHeight,width,height);
  for (int currButton=0;currButton<nButtons;currButton++)
  {
    fill(255);
    rect(buttonLeftLims[currButton],buttonLowerLimRel*screenHeight,buttonWidth,buttonHeightRel*screenHeight,buttonWidth/10);
  }
  if (mainKeySet)
  {
    for (int currButton=0;currButton<nButtons;currButton++)
    {
      //println(mainButtonsString[currButton]);
      fill(0);
      if (mainButtonsString[currButton]!=null)
      {
        text(mainButtonsString[currButton],buttonLeftLims[currButton]+textMargin,buttonLowerLimRel*screenHeight+textMargin,buttonWidth-textMargin,buttonHeightRel*screenHeight-textMargin);
      }
    }
  }
  else
  {
    for (int currButton=0;currButton<nButtons;currButton++)
    {
      //println(mainButtonsString[currButton]);
      fill(0);
      if (currKeySet*nButtons+currButton<keys.length)
      {
        text(keys[currKeySet*nButtons+currButton],buttonLeftLims[currButton]+20,buttonLowerLimRel*screenHeight+20,buttonWidth-20,0.2*screenHeight-20);
      }
    }
  }
  //println(rX + " " + rY);
  if (rY>buttonLowerLimRel*screenHeight&&rY<(buttonLowerLimRel+0.2)*screenHeight)
  {
    prevSelectedKey=currSelectedKey;
    currSelectedKey=floor(rX/buttonWidth);
    if (prevSelectedKey==currSelectedKey)
    {
      if (millis()-timerStart>selectionTime)
      {
        timerStart=millis();
        keyPress(currSelectedKey);
      }
    }
    else
    {
      timerStart=millis();
    }
  }
}

void keyPress(int currSelectedKey)
{
  if (mainKeySet)
  {
    mainKeySet=false;
    currKeySet=currSelectedKey-1;
  }
    else
  {
    mainKeySet=true;
    switch(keys[currKeySet*nButtons+currSelectedKey-1])
    {
      case "Clear":
        currentText="";
        break;
      case "Bs":
        currentText=currentText.substring(0,currentText.length()-1);
        break;
       case "_":
        currentText=currentText+" ";
        break;
      default:
        currentText=currentText+keys[currKeySet*nButtons+currSelectedKey-1];
    }
   }
}

float rX=-1, rY=-1;
float previousRx = 0, previousRy = 0;
float gazeSpeed = 1;
String value2="";
int timeCounter=0;

void receive(byte[] data, String ip, int port )  {
    if (port == 9050) {                                     // Tobii 
               // println( "receive Message from EYE tracker");
                String value=new String(data);
                String value1 = value.replaceAll(";", " ");
                value2 = value1.replaceAll(",", ".");
              
              //Compute X and Y round gaze coordinates
                if(value2.length() > 30) {
                  String[] parts = value2.split(" ");
                  rX = Float.parseFloat(parts[0]);
                  rY = Float.parseFloat(parts[1]); //+ predatorY;   // it was added to run on the second Predator manitor
                }
                
                if (previousRx == 0) {
                  previousRx = rX;
                  previousRy = rY;
                }
          
              // Filter rX and rY
              gazeSpeed = sqrt(sq(rX - previousRx) + sq(rY - previousRy)) / sqrt(sq(width) + sq(height));
              rX = previousRx * (1 - 1 * sqrt(gazeSpeed)) + rX * sqrt(gazeSpeed);
              rY = previousRy * (1 - 1 * sqrt(gazeSpeed)) + rY * sqrt(gazeSpeed);
              previousRx = rX;
              previousRy = rY;
}
}