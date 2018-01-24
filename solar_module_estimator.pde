//-----------------------------------------
// SKETCH NAME: solar_module_estimator
// AUTHOR    : Jordan Machan
// DATE (YYYY-MM-DD): 2017-12-30
// PURPOSE: the purpose of this sketch is to do the following:
// 1. reads and loads a TAB delimited target_area.txt file which represents roof areas for a particular house (sides of house)
//    edit this file and enter the roof area measurements and ensure that the 'Select at least one' column has at least one TRUE value.
// 2. reads and loads a TAB delimited solar_modules.txt file which represents the solar modules to compare
//    edit this file and enter the installation company, solar module, module type, power output and module dimensions and ensure that the 'Select only two' column has two and only two TRUE values.
// Using the selected rows from the two files this program then draws the roof area that was selected factoring in setbacks for eavestroughs etc. The first two rectangles (roof area) represent using the first solar module selected 
// and the last two rectangles (roof area) represent using the second solar module selected. The program determines the best fit with different orientations (i.e. landscape and portrait and a combination thereof).
// The program then determines which rectangle/solar module combination is the winner when compared to the other solar module/rectangle combination based on total power output. 
//-----------------------------------------
//overlay starts from top left x y
//underlay should start from bottom right x y
  boolean virgin = true;
  boolean and_the_winner_is = false;
  
  int[] totalModulesL;
  int[] totalModulesR;

  int[] powerOutputL;
  int[] powerOutputR;
  
  int[] totalPowerOutputL;
  int[] totalPowerOutputR;
  
  boolean debug = false;
  final String COLON = ": ";
  final String COMMA = ", ";
  final String TAB = "\t";
  final int ADD_PIXELS = 12;
  final int WHITE_SPACE = 12;

  boolean readyToPrint = true;
  String[] excelWinners;
  String[] excelLosers;

  boolean header = true;
  int targetAreaIndex = 0;

  final String buffersFileName = "buffers.txt";
  String[] buffersHeader;
  String[] buffersDetail;
  int obufferN;
  int obufferE;
  int obufferS;
  int obufferW;
  int nbufferN;
  int nbufferE;
  int nbufferS;
  int nbufferW;
  int bufferEavestrough;

  final String modulesFileName = "modules.txt";
  String[] modulesHeader;
  String[] modulesDetailL;
  String[] modulesDetailR;

  final String targetAreasFileName = "target_areas.txt";
  String[] targetAreasHeader;
  String[] targetAreasDetail;
  int textX;
  int textY;

  String[] leftInstallationCompanyName = new String[2];
  String[] leftmoduleCompanyName = new String[2];
  String[] leftModuleType = new String[2];
  int[] lefttotalModules = new int[2];
  int[] leftPowerOutput = new int[2];
  int[] leftTotalPowerOutput = new int[2];

  String[] rightInstallationCompanyName = new String[2];
  String[] rightmoduleCompanyName = new String[2];
  String[] rightModuleType = new String[2];
  int[] righttotalModules = new int[2];
  int[] rightPowerOutput = new int[2];
  int[] rightTotalPowerOutput = new int[2];

  int[] moduleLandX = new int[2];
  int[] moduleLandY = new int[2];
  int[] modulePortX = new int[2];
  int[] modulePortY = new int[2];

  final float ROOF_VENT_WIDTH_IN = 11.75;
  final float ROOF_VENT_LENGTH_IN = 11.75;
  final float ROOF_VENT_HEIGHT_IN = 4.25;
  PShape roofVent;
  int[] roofVentX = new int[4];
  int[] roofVentY = new int[4];

  PShape rectBig;
  int    rectBigLength = 0;
  int    rectBigWidth = 0;
  int[]  rectBigX = new int[4];
  int[]  rectBigY = new int[4];
  PShape rectInner;
  int    rectInnerLength = 0;
  int    rectInnerWidth = 0;
  int[]  rectInnerX = new int[4];
  int[]  rectInnerY = new int[4];
  PShape rectModule;

  String[] sideOfTheHouse;
  boolean[] centerThemodules;
  boolean[] justifyThemodules;
  boolean[] eavestroughN;
  boolean[] eavestroughE;
  boolean[] eavestroughS;
  boolean[] eavestroughW;
  int[] targetArea_length_ft;
  int[] targetArea_length_in;
  int[] targetArea_width_ft;
  int[] targetArea_width_in;
  
  boolean targetAreasFound = false;
  int targetAreasTrueCount = 0;

  String[] installationCompanyName;
  String[] moduleCompanyName;
  String[] moduleType;
  int[] powerOutput;
  float[] moduleDimension_width_mm;
  float[] moduleDimension_length_mm; 
  float[] moduleDimension_height_mm;
  float[] moduleDimension_width_in;
  float[] moduleDimension_length_in; 
  float[] moduleDimension_height_in;
  
  int[] module_length_ft;
  int[] module_length_in;
  int[] module_width_ft;
  int[] module_width_in;

  boolean modulesFound = false;
  int modulesTrueCount = 0;

  int rectSpacerHorizontal = 0;
  int rectSpacerVertical = 0;

  float[] overShapeLength = new float[1000];
  float[] overShapeWidth = new float[1000];
  float[] overShapeX = new float[1000];
  float[] overShapeY = new float[1000];
  float[] underShapeLength = new float[1000];
  float[] underShapeWidth = new float[1000];
  float[] underShapeX = new float[1000];
  float[] underShapeY = new float[1000];

  int countmodulesAdditional = 0;
  int countmodulesOverlay = 0;
  int countmodulesTotal = 0;
  int countmodulesUnderlay = 0;

void setup() 
{
  size(1300, 1300);
  rectSpacerHorizontal = (13*4);
  rectSpacerVertical = (13*4);
  getBuffersHeader();
  getBuffersDetail();
  getTargetAreasHeader();
  getModulesHeader();
  getTrueCounts();
  if (!targetAreasFound || !modulesFound)
  {
    printErrors();
    exit();
  }
  else
  {
    newSummaryArrays();
    newTargetAreasArrays();
    setTargetAreasArrays();
    setTargetAreasDetail();

    newModulesArrays();
    setModulesArrays();
    setInchesToFeet();
    setModulesDetail();
    println("press up or down key to continue ...");
  }
}

void keyPressed() 
{
  if (key == CODED) {
    if (keyCode == UP) {
      targetAreaIndex++;
    } else if (keyCode == DOWN) {
      targetAreaIndex--;
    } 
  }
  if (virgin)
  {
    virgin = false;
    targetAreaIndex = 0;
  }
  else
  {
    if (and_the_winner_is && (targetAreaIndex != targetAreasTrueCount))
    {
      targetAreaIndex = (targetAreasTrueCount-1);
    }
    if (targetAreaIndex == targetAreasTrueCount)
    {
      and_the_winner_is = true;
    }
    else
    {
      and_the_winner_is = false;
    }
    if (targetAreaIndex > (targetAreasTrueCount-1)) 
    {
      targetAreaIndex = (targetAreasTrueCount-1);
    }
    if (targetAreaIndex < 0)
    {
      targetAreaIndex = 0;
    }
  }
}

void drawRectangles(int targetAreaIndex)
{
  if (and_the_winner_is)
  {
    background(255);
    printSummary();
  }
  else
  {
    background(255);
    setSizes(targetAreaIndex);
    drawModules(targetAreaIndex, 0, 0, "landscape");
    drawModules(targetAreaIndex, 0, 1, "portrait");
    line(rectBigWidth*2+(rectSpacerVertical*2), 0, rectBigWidth*2+(rectSpacerVertical*2), height);
    drawModules(targetAreaIndex, 1, 2, "landscape");
    drawModules(targetAreaIndex, 1, 3, "portrait");
    printTheWinner(targetAreaIndex);
  }
}

void draw() 
{
  if (keyPressed == true)
  {
    drawRectangles(targetAreaIndex);
  }
}

int getTrueCount(String fileName)
{
  int retVal=0;
  String[] lines;
  lines = loadStrings(fileName);
  for (int x=0; x < lines.length; x++)
  {
    String[] pieces = split(lines[x], '\t');
    if (boolean(pieces[0]) == true)
    {
      retVal++;
    }
  }
  return retVal;
}

void getTrueCounts()
{
  targetAreasTrueCount = getTrueCount(targetAreasFileName);
  modulesTrueCount = getTrueCount(modulesFileName);
  targetAreasFound = false;
  modulesFound = false;
  if (targetAreasTrueCount >= 1) targetAreasFound = true;
  if (modulesTrueCount == 2) modulesFound = true;
}

void newSummaryArrays()
{
  totalModulesL = new int[targetAreasTrueCount];
  totalModulesR = new int[targetAreasTrueCount];

  powerOutputL = new int[targetAreasTrueCount];
  powerOutputR = new int[targetAreasTrueCount];
  
  totalPowerOutputL = new int[targetAreasTrueCount];
  totalPowerOutputR = new int[targetAreasTrueCount];
}

void newTargetAreasArrays()
{
  sideOfTheHouse = new String[targetAreasTrueCount];
  centerThemodules = new boolean[targetAreasTrueCount];
  justifyThemodules = new boolean[targetAreasTrueCount];
  eavestroughN = new boolean[targetAreasTrueCount];
  eavestroughE = new boolean[targetAreasTrueCount];
  eavestroughS = new boolean[targetAreasTrueCount];
  eavestroughW = new boolean[targetAreasTrueCount];
  targetArea_length_ft = new int[targetAreasTrueCount];
  targetArea_length_in = new int[targetAreasTrueCount];
  targetArea_width_ft = new int[targetAreasTrueCount];
  targetArea_width_in = new int[targetAreasTrueCount];
  excelWinners = new String[targetAreasTrueCount];
  excelLosers = new String[targetAreasTrueCount];
}

void newModulesArrays()
{
  installationCompanyName = new String[modulesTrueCount];
  moduleCompanyName = new String[modulesTrueCount];
  moduleType = new String[modulesTrueCount];
  powerOutput = new int[modulesTrueCount];
  moduleDimension_width_mm = new float[modulesTrueCount]; 
  moduleDimension_length_mm = new float[modulesTrueCount]; 
  moduleDimension_height_mm = new float[modulesTrueCount]; 
  moduleDimension_width_in = new float[modulesTrueCount]; 
  moduleDimension_length_in = new float[modulesTrueCount]; 
  moduleDimension_height_in = new float[modulesTrueCount]; 
  
  module_length_ft = new int[modulesTrueCount];
  module_length_in = new int[modulesTrueCount];
  module_width_ft = new int[modulesTrueCount];
  module_width_in = new int[modulesTrueCount];
}

void setTargetAreasDetail()
{
  int columnCount = 0;
  String[] lines;
  lines = loadStrings(targetAreasFileName);
  for (int x=0; x < lines.length; x++)
  {
    String[] pieces = split(lines[x], '\t');
    if (boolean(pieces[0]) == true)
    {
      for (int i=1; i < pieces.length; i++)
      {
        targetAreasDetail[columnCount] = pieces[i];
        columnCount++;
      }
    }
  }
  printStringArray("targetAreasDetail", targetAreasDetail);
}

void setTargetAreasArrays()
{
  int columnCount = 11;
  int trueCount = 0;
  String[] lines;
  lines = loadStrings(targetAreasFileName);
  for (int x=0; x < lines.length; x++)
  {
    String[] pieces = split(lines[x], '\t');
    if (boolean(pieces[0]) == true)
    {
      sideOfTheHouse[trueCount] = pieces[1];
      centerThemodules[trueCount] = boolean(pieces[2]);
      justifyThemodules[trueCount] = boolean(pieces[3]);
      eavestroughN[trueCount] = boolean(pieces[4]);
      eavestroughE[trueCount] = boolean(pieces[5]);
      eavestroughS[trueCount] = boolean(pieces[6]);
      eavestroughW[trueCount] = boolean(pieces[7]);
      targetArea_length_ft[trueCount] = int(pieces[8]);
      targetArea_length_in[trueCount] = int(pieces[9]);
      targetArea_width_ft[trueCount] = int(pieces[10]);
      targetArea_width_in[trueCount] = int(pieces[11]);
      trueCount++;
    }
  }
  targetAreasDetail = new String[columnCount*trueCount];
  printStringArray("sideOfTheHouse", sideOfTheHouse);
  printBooleanArray("centerThemodules", centerThemodules);
  printBooleanArray("justifyThemodules", justifyThemodules);
  printBooleanArray("eavestroughN", eavestroughN);
  printBooleanArray("eavestroughE", eavestroughE);
  printBooleanArray("eavestroughS", eavestroughS);
  printBooleanArray("eavestroughW", eavestroughW);
  printIntArray("targetArea_length_ft", targetArea_length_ft);
  printIntArray("targetArea_length_in", targetArea_length_in);
  printIntArray("targetArea_width_ft", targetArea_width_ft);
  printIntArray("targetArea_width_in", targetArea_width_in);
}

void setModulesDetail()
{
  boolean left = true;
  int columnCount;
  String[] lines;
  lines = loadStrings(modulesFileName);
  for (int x=0; x < lines.length; x++)
  {
    columnCount = 0;
    String[] pieces = split(lines[x], '\t');
    if (boolean(pieces[0]) == true)
    {
      if (left)
      {
        left = false;
        for (int i=1; i < pieces.length; i++)
        {
          modulesDetailL[columnCount] = pieces[i];
          columnCount++;
        }
      }
      else
      {
        for (int i=1; i < pieces.length; i++)
        {
          modulesDetailR[columnCount] = pieces[i];
          columnCount++;
        }
      }
    }
  }
  printStringArray("modulesDetailL", modulesDetailL);
  printStringArray("modulesDetailR", modulesDetailR);
}

void setInchesToFeet()
{
  int feet=0;
  int inches=0;
  float conversionRate = 0.0833333;
  float floatingFeet;
  for (int i=0; i < modulesTrueCount; i++)
  {
    floatingFeet = moduleDimension_length_in[i]*conversionRate;
    feet = int(floatingFeet);
    inches = int(((floatingFeet) % feet)*12);
    module_length_ft[i] = feet;
    module_length_in[i] = inches;
    
    floatingFeet = moduleDimension_width_in[i]*conversionRate;
    feet = int(floatingFeet);
    inches = int(((floatingFeet) % feet)*12);
    module_width_ft[i] = feet;
    module_width_in[i] = inches;
  }
  printIntArray("module_length_ft", module_length_ft);
  printIntArray("module_length_in", module_length_in);
  printIntArray("module_width_ft", module_width_ft);
  printIntArray("module_width_in", module_width_in);
}

void setModulesArrays()
{
  int columnCount = 10;
  int trueCount = 0;
  String[] lines;
  lines = loadStrings(modulesFileName);
  for (int x=0; x < lines.length; x++)
  {
    String[] pieces = split(lines[x], '\t');
    if (boolean(pieces[0]) == true)
    {
      installationCompanyName[trueCount] = pieces[1];
      moduleCompanyName[trueCount] = pieces[2];
      moduleType[trueCount] = pieces[3];
      powerOutput[trueCount] = int(pieces[4]);
      moduleDimension_length_mm[trueCount] = float(pieces[5]);
      moduleDimension_width_mm[trueCount] = float(pieces[6]);
      moduleDimension_height_mm[trueCount] = float(pieces[7]);
      moduleDimension_length_in[trueCount] = float(pieces[8]);
      moduleDimension_width_in[trueCount] = float(pieces[9]);
      moduleDimension_height_in[trueCount] = float(pieces[10]);
      trueCount++;
    }
  }
  modulesDetailL = new String[columnCount*(trueCount-1)];
  modulesDetailR = new String[columnCount*(trueCount-1)];
  printStringArray("installationCompanyName", installationCompanyName);
  printStringArray("moduleCompanyName", moduleCompanyName);
  printStringArray("moduleType", moduleType);
  printIntArray("powerOutput", powerOutput);
  printFloatArray("moduleDimension_length_mm", moduleDimension_length_mm);
  printFloatArray("moduleDimension_width_mm", moduleDimension_width_mm);
  printFloatArray("moduleDimension_height_mm", moduleDimension_height_mm);
  printFloatArray("moduleDimension_length_in", moduleDimension_length_in);
  printFloatArray("moduleDimension_width_in", moduleDimension_width_in);
  printFloatArray("moduleDimension_height_in", moduleDimension_height_in);
}

//------------------------------------------------------
// object name: printErrors
//
// PURPOSE: 
//        this function prints out errors
// PARAMETERS:
//        none
// Returns:
//        none
//------------------------------------------------------
void printErrors()
{
  if (!targetAreasFound)
  {
    println(targetAreasFileName+" "+targetAreasHeader[0]+" column has "+targetAreasTrueCount+" value(s) of 'TRUE'"); 
  }
  if (!modulesFound)
  {
    println(modulesFileName+" "+modulesHeader[0]+" column has "+modulesTrueCount+" value(s) of 'TRUE'"); 
  }
}

//------------------------------------------------------
// object name: setSizes
//
// PURPOSE: this function sets the following:
//          1. setSizeBuffer
//          2. setSizeRect
//          3. setXY_Rect
//          4. setXY_Module
// PARAMETERS:
//        none
// Returns:
//        none
//------------------------------------------------------
void setSizes(int targetAreaIndex)
{
  setSizeBuffer(targetAreaIndex);
  setSizeRect(targetAreaIndex);
  setXY_Rect();
  setXY_Module();
}

void getBuffersHeader()
{
  String[] lines;

  lines = loadStrings(buffersFileName);
  for (int x=0; x < 1; x++)
  {
    String[] pieces = split(lines[x], '\t');
    buffersHeader = new String[pieces.length];
    for (int i=0; i < pieces.length; i++)
    {
      buffersHeader[i] = pieces[i];
    }
  }
  printStringArray("buffersHeader", buffersHeader);
}

void getBuffersDetail()
{
  int whatever;
  String[] lines;
  lines = loadStrings(buffersFileName);
  for (int x=1; x < 2; x++)
  {
    String[] pieces = split(lines[x], '\t');
    buffersDetail = new String[pieces.length];
    for (int i=0; i < pieces.length; i++)
    {
      buffersDetail[i] = pieces[i];
      whatever = int(pieces[i]);
      if (buffersHeader[i].equals("Buffer N")) obufferN = whatever;
      if (buffersHeader[i].equals("Buffer E")) obufferE = whatever; 
      if (buffersHeader[i].equals("Buffer S")) obufferS = whatever; 
      if (buffersHeader[i].equals("Buffer W")) obufferW = whatever; 
      if (buffersHeader[i].equals("Buffer Eavestrough")) bufferEavestrough = whatever; 
    }
  }
  printStringArray("buffersDetail", buffersDetail);
}

//------------------------------------------------------
// object name: setSizeBuffer
//
// PURPOSE: this function sets the buffer sizes
// PARAMETERS:
//        none
// Returns:
//        none
//------------------------------------------------------
void setSizeBuffer(int targetAreaIndex)
{
  nbufferN = obufferN;
  nbufferE = obufferE;
  nbufferS = obufferS;
  nbufferW = obufferW;
  if (eavestroughN[targetAreaIndex]) nbufferN = bufferEavestrough;
  if (eavestroughE[targetAreaIndex]) nbufferE = bufferEavestrough;
  if (eavestroughS[targetAreaIndex]) nbufferS = bufferEavestrough;
  if (eavestroughW[targetAreaIndex]) nbufferW = bufferEavestrough;
}

//------------------------------------------------------
// object name: setSizeRect
//
// PURPOSE: this function sets the big and inner rectangle size
// PARAMETERS:
//        none
// Returns:
//        none
//------------------------------------------------------
void setSizeRect(int targetAreaIndex)
{
  rectBigWidth = (targetArea_width_ft[targetAreaIndex]*12)+targetArea_width_in[targetAreaIndex];
  rectBigLength = (targetArea_length_ft[targetAreaIndex]*12)+targetArea_length_in[targetAreaIndex];
  rectInnerWidth = rectBigWidth - (nbufferW+nbufferE);
  rectInnerLength = rectBigLength - (nbufferN+nbufferS);
}

//------------------------------------------------------
// object name: setXY_Rect
//
// PURPOSE: this function sets the big and inner rectangle x y starting coordinates
// PARAMETERS:
//        none
// Returns:
//        none
//------------------------------------------------------
void setXY_Rect()
{
  for (int i = 0; i < rectBigX.length; i++)
  {
    rectBigX[i] = rectBigWidth*i+rectSpacerVertical*i+WHITE_SPACE;
    rectBigY[i] = 0;
    
    rectInnerX[i] = rectBigWidth*i+rectSpacerVertical*i+WHITE_SPACE+nbufferW;
    rectInnerY[i] = nbufferN;
  }
  for (int i = 0; i < roofVentX.length; i++)
  {
    roofVentX[i] = rectBigWidth*i+rectSpacerVertical*i+WHITE_SPACE+nbufferW;
    roofVentY[i] = nbufferN;
  }
}    

//------------------------------------------------------
// object name: setXY_Module
//
// PURPOSE: this function sets the landscape and portrait solar module x y starting coordinates
// PARAMETERS:
//        none
// Returns:
//        none
//------------------------------------------------------
void setXY_Module()
{
  moduleLandX[0] = int(rectInnerLength/moduleDimension_width_in[0]);
  moduleLandY[0] = int(rectInnerWidth/moduleDimension_length_in[0]);
  moduleLandX[1] = int(rectInnerLength/moduleDimension_width_in[1]);
  moduleLandY[1] = int(rectInnerWidth/moduleDimension_length_in[1]);
  modulePortX[0] = int(rectInnerWidth/moduleDimension_width_in[0]);
  modulePortY[0] = int(rectInnerLength/moduleDimension_length_in[0]);
  modulePortX[1] = int(rectInnerWidth/moduleDimension_width_in[1]);
  modulePortY[1] = int(rectInnerLength/moduleDimension_length_in[1]);
}

//------------------------------------------------------
// object name: roofVents
//
// PURPOSE: this function creates the roof vent shape
// PARAMETERS:
//        none
// Returns:
//        none
//------------------------------------------------------
void roofVents()
{
  fill(255);
  for (int i = 0; i < roofVentX.length; i++)
  {
    println("roofVentX["+i+"] = "+roofVentX[i]);
    println("roofVentY["+i+"] = "+roofVentY[i]);
    roofVent = createShape(RECT, roofVentX[i], roofVentY[i], ROOF_VENT_WIDTH_IN, ROOF_VENT_LENGTH_IN);
    shape(roofVent);
  }
}  

//------------------------------------------------------
// object name: initmoduleCounts
//
// PURPOSE: this function initializes the module counts to zero
// PARAMETERS:
//        none
// Returns:
//        none
//------------------------------------------------------
void initmoduleCounts()
{
  countmodulesAdditional = 0;
  countmodulesUnderlay = 0;
  countmodulesOverlay = 0;
  countmodulesTotal = 0;
}

//------------------------------------------------------
// object name: countAdditionalmodules
//
// PURPOSE: this function counts if there are underlaying modules that fit in the roof area without impacting the overlaying modules
// PARAMETERS:
//        none
// Returns:
//        none
//------------------------------------------------------
void countAdditionalmodules()
{
  boolean addmodule = true;
  float x1;
  float x2;
  float y1;
  float y2;
  float topLeftX;
  float topLeftY;
  float topRightX;
  float topRightY;
  float botLeftX;
  float botLeftY;
  float botRightX;
  float botRightY;
  if (countmodulesOverlay > 0)
  {
    for (int i=0; i < countmodulesUnderlay; i++)
    {
      addmodule = true;
      for (int j=0; j < countmodulesOverlay; j++)
      {
        x1 = overShapeX[j];
        y1 = overShapeY[j];
        x2 = x1+overShapeWidth[j];
        y2 = y1+overShapeLength[j];
        topLeftX = underShapeX[i];
        topLeftY = underShapeY[i];
        botLeftX = topLeftX;
        botLeftY = topLeftY+underShapeLength[i];
        topRightX = topLeftX+underShapeWidth[i];
        topRightY = topLeftY;
        botRightX = topRightX;
        botRightY = botLeftY;
        if (((topLeftX >= x1) && (topLeftX <= x2)) && ((topLeftY >= y1) && (topLeftY <= y2))) 
        {
          addmodule = false;
        }
        if (((topRightX >= x1) && (topRightX <= x2)) && ((topRightY >= y1) && (topRightY <= y2))) 
        {
          addmodule = false;
        }
        if (((botLeftX >= x1) && (botLeftX <= x2)) && ((botLeftY >= y1) && (botLeftY <= y2))) 
        {
          addmodule = false;
        }
        if (((botRightX >= x1) && (botRightX <= x2)) && ((botRightY >= y1) && (botRightY <= y2))) 
        {
          addmodule = false;
        }
      }
      if (addmodule)
      {
        countmodulesAdditional++;
      }
    }
  }
  countmodulesTotal = countmodulesOverlay+countmodulesAdditional;
}

//------------------------------------------------------
// object name: popArrays
//
// PURPOSE: this function populates the underlay and overlay modules
// PARAMETERS:
//        boolean underlay - if true  populate the underlay solar modules with the supplied x y coordinates and solar module dimensions 
//                           if false populate the overlay  solar modules with the supplied x y coordinates and solar module dimensions
//        float topLeftX - top left x coordinate
//        float topLeftY - top left y coordinate
//        float ModuleWidth - solar module width
//        float ModuleLength - solar module length
// Returns:
//        none
//------------------------------------------------------
void popArrays(boolean underlay, float topLeftX, float topLeftY, float ModuleWidth, float ModuleLength)
{
  if (debug)
  {
    println("popArrays begin");
    println("underlay = "+underlay);
    println("topLeftX = "+topLeftX);
    println("topLeftY = "+topLeftY);
    println("ModuleWidth = "+ModuleWidth);
    println("ModuleLength = "+ModuleLength);
  }
  if (underlay)
  {
    underShapeX[countmodulesUnderlay] = topLeftX;
    underShapeY[countmodulesUnderlay] = topLeftY;
    underShapeWidth[countmodulesUnderlay] = ModuleWidth;
    underShapeLength[countmodulesUnderlay] = ModuleLength;
    countmodulesUnderlay++;
  }
  else
  {
    overShapeX[countmodulesOverlay] = topLeftX;
    overShapeY[countmodulesOverlay] = topLeftY;
    overShapeWidth[countmodulesOverlay] = ModuleWidth;
    overShapeLength[countmodulesOverlay] = ModuleLength;
    countmodulesOverlay++;
  }
}        

boolean determineJustification()
{
  boolean leftJustify = true;
  if (rectInnerWidth > rectInnerLength) leftJustify = false;
  return leftJustify;
}  

//------------------------------------------------------
// object name: doLandscape
//
// PURPOSE: this function draws the solar modules in a landscape orientation
// PARAMETERS:
//        boolean underlay - if true  populate the underlay solar modules with the supplied x y coordinates and solar module dimensions 
//                           if false populate the overlay  solar modules with the supplied x y coordinates and solar module dimensions
//        int topLeftX - the roofs starting x coordinate
//        int topLeftY - the roofs starting y coordinate
//        int moduleX - the modules starting x coordinate
//        int moduleY - the modules starting y coordinate
//        float ModuleWidth - solar module width
//        float ModuleLength - solar module length
// Returns:
//        none
//------------------------------------------------------
void doLandscape(int targetAreaIndex, boolean underlay, float bottomRightX, float bottomRightY, float topLeftX, float topLeftY, int moduleX, int moduleY, float ModuleWidth, float ModuleLength)
{
  //if portrait leave the width and length alone
  //else if landscape switch the length and width
  float floatX;
  float floatY;
  float newX;
  float newY;
  float moduleLength = ModuleWidth;
  float moduleWidth = ModuleLength;
  float posX;
  float posY;
  float totalmoduleWidth;
  
  boolean leftJustify = false;
  leftJustify = determineJustification();

  if (!underlay)
  {
    if (centerThemodules[targetAreaIndex])
    {
      newY = moduleX*moduleLength;
      newY = (bottomRightY-newY)/2;
      if (justifyThemodules[targetAreaIndex])
      {
        if (leftJustify) topLeftY = newY+topLeftY;
      }
      else
      {
        topLeftY = newY+topLeftY;
      }
      totalmoduleWidth = moduleY*moduleWidth;
      newX = ((bottomRightX-topLeftX)-totalmoduleWidth)/2;
      if (justifyThemodules[targetAreaIndex])
      {
        if (!leftJustify) topLeftX = newX+topLeftX;
      }
      else
      {
        topLeftX = newX+topLeftX;
      }
    }
    for (int x=0; x < moduleX; x++)
    {
      posY = x*moduleLength;
      for (int y=0; y < moduleY; y++)
      {

        posX = y*moduleWidth;
        floatX = posX+topLeftX;
        floatY = posY+topLeftY;
        rectModule = createShape(RECT, floatX, floatY, moduleWidth,  moduleLength );
        shape(rectModule);
        popArrays(underlay, floatX, floatY, moduleWidth, moduleLength);
      }
    }
  }
  else
  {
    if (centerThemodules[targetAreaIndex])
    {
      newY = moduleX*moduleLength;
      newY = (bottomRightY-newY)/2;
      if (justifyThemodules[targetAreaIndex])
      {
        if (leftJustify) bottomRightY = bottomRightY-newY;
      }
      else
      {
        bottomRightY = bottomRightY-newY;
      }
      totalmoduleWidth = moduleY*moduleWidth;
      newX = ((bottomRightX-topLeftX)-totalmoduleWidth)/2;
      if (justifyThemodules[targetAreaIndex])
      {
        if (!leftJustify) bottomRightX = bottomRightX-newX;
      }
      else
      {
        bottomRightX = bottomRightX-newX;
      }
    }
    for (int x=0; x < moduleX; x++)
    {
      for (int y=0; y < moduleY; y++)
      {
        posX = bottomRightX-((y+1)*moduleWidth);
        posY = x*moduleLength;
        posY = (bottomRightY-posY)-moduleLength;
        rectModule = createShape(RECT, posX, posY, moduleWidth, moduleLength);
        shape(rectModule);
        popArrays(underlay, posX, posY, moduleWidth, moduleLength);
      }
    }
  }
}

//------------------------------------------------------
// object name: doPortrait
//
// PURPOSE: this function draws the solar modules in a portrait orientation
// PARAMETERS:
//        boolean underlay - if true  populate the underlay solar modules with the supplied x y coordinates and solar module dimensions 
//                           if false populate the overlay  solar modules with the supplied x y coordinates and solar module dimensions
//        int topLeftX - the roofs starting x coordinate
//        int topLeftY - the roofs starting y coordinate
//        int moduleX - the modules starting x coordinate
//        int moduleY - the modules starting y coordinate
//        float ModuleWidth - solar module width
//        float ModuleLength - solar module length
// Returns:
//        none
//------------------------------------------------------
void doPortrait(int targetAreaIndex, boolean underlay, float bottomRightX, float bottomRightY, float topLeftX, float topLeftY, int moduleX, int moduleY, float ModuleWidth, float ModuleLength)
{
  //if portrait leave the width and length alone
  //else if landscape switch the length and width
  float floatX;
  float floatY;
  float newX;
  float newY;
  float moduleLength = ModuleLength;
  float moduleWidth = ModuleWidth;
  float posX;
  float posY;
  float totalmoduleWidth;

  boolean leftJustify = false;
  leftJustify = determineJustification();

  if (!underlay)
  {
    if (centerThemodules[targetAreaIndex])
    {
      newY = moduleY*moduleLength;
      newY = (bottomRightY-newY)/2;
      if (justifyThemodules[targetAreaIndex])
      {
        if (leftJustify) topLeftY = newY+topLeftY;
      }
      else
      {
        topLeftY = newY+topLeftY;
      }
      totalmoduleWidth = moduleX*moduleWidth;
      newX = ((bottomRightX-topLeftX)-totalmoduleWidth)/2;
      if (justifyThemodules[targetAreaIndex])
      {
        if (!leftJustify) topLeftX = newX+topLeftX;
      }
      else
      {
        topLeftX = newX+topLeftX;
      }
    }
    for (int x=0; x < moduleX; x++)
    {
      posX = x*moduleWidth;
      for (int y=0; y < moduleY; y++)
      {
        posY = y*moduleLength;
        floatX = posX+topLeftX;
        floatY = posY+topLeftY;
        rectModule = createShape(RECT, floatX, floatY, moduleWidth, moduleLength);
        shape(rectModule);
        popArrays(underlay, floatX, floatY, moduleWidth, moduleLength);
      }
    }
  }
  else
  {
    if (centerThemodules[targetAreaIndex])
    {
      newY = moduleY*moduleLength;
      newY = (bottomRightY-newY)/2;
      if (justifyThemodules[targetAreaIndex])
      {
        if (leftJustify) bottomRightY = bottomRightY-newY;
      }
      else
      {
        bottomRightY = bottomRightY-newY;
      }

      totalmoduleWidth = moduleX*moduleWidth;
      newX = ((bottomRightX-topLeftX)-totalmoduleWidth)/2;
      if (justifyThemodules[targetAreaIndex])
      {
        if (!leftJustify) bottomRightX = bottomRightX-newX;
      }
      else
      {
        bottomRightX = bottomRightX-newX;
      }
    }
    for (int x=0; x < moduleX; x++)
    {
      posX = bottomRightX-((x+1)*moduleWidth);
      for (int y=0; y < moduleY; y++)
      {
        posY = y*moduleLength;
        posY = (bottomRightY-posY)-moduleLength;
        rectModule = createShape(RECT, posX, posY, moduleWidth, moduleLength);
        shape(rectModule);
        popArrays(underlay, posX, posY, moduleWidth, moduleLength);
      }
    }
  }
}

//------------------------------------------------------
// object name: drawModules
//
// PURPOSE: this function draws the solar modules
// PARAMETERS:
//        int moduleNumber - the number of the solar module
//        int rectNumber - the number of the rectangle
//        String finalOrientation - the final orientation (i.e. landscape or portrait)
// Returns:
//        none
//------------------------------------------------------
void drawModules(int targetAreaIndex, int moduleNumber, int rectNumber, String finalOrientation)
{
  boolean underlay;
  int bottomRightX;
  int bottomRightY;
  int topLeftX;
  int topLeftY;

  fill(255);
  rectBig = createShape(RECT, rectBigX[rectNumber], rectBigY[rectNumber], rectBigWidth, rectBigLength);
  rectInner = createShape(RECT, rectInnerX[rectNumber], rectInnerY[rectNumber], rectInnerWidth, rectInnerLength);
  shape(rectBig);
  shape(rectInner);
  initmoduleCounts();
  bottomRightX = rectInnerX[rectNumber]+rectInnerWidth;
  bottomRightY = rectInnerY[rectNumber]+rectInnerLength;
  topLeftX = rectInnerX[rectNumber];
  topLeftY = rectInnerY[rectNumber];

  if (finalOrientation == "landscape")
  {
    fill(175);
    underlay = true;
    doPortrait(targetAreaIndex, underlay, bottomRightX, bottomRightY, topLeftX, topLeftY, modulePortX[moduleNumber], modulePortY[moduleNumber], moduleDimension_width_in[moduleNumber], moduleDimension_length_in[moduleNumber]);
    fill(125);
    underlay = false;
    doLandscape(targetAreaIndex, underlay, bottomRightX, bottomRightY, topLeftX, topLeftY, moduleLandX[moduleNumber], moduleLandY[moduleNumber], moduleDimension_width_in[moduleNumber], moduleDimension_length_in[moduleNumber]);
  }
  if (finalOrientation == "portrait")
  {
    fill(175);
    underlay = true;
    doLandscape(targetAreaIndex, underlay, bottomRightX, bottomRightY, topLeftX, topLeftY, moduleLandX[moduleNumber], moduleLandY[moduleNumber], moduleDimension_width_in[moduleNumber], moduleDimension_length_in[moduleNumber]);
    fill(125);
    underlay = false;
    doPortrait(targetAreaIndex, underlay, bottomRightX, bottomRightY, topLeftX, topLeftY, modulePortX[moduleNumber], modulePortY[moduleNumber], moduleDimension_width_in[moduleNumber], moduleDimension_length_in[moduleNumber]);
  }
  countAdditionalmodules();
  textX = rectBigWidth*rectNumber+rectSpacerVertical*rectNumber;
  textY = rectBigLength;
  printResults(targetAreaIndex, rectNumber, finalOrientation, moduleType[moduleNumber], countmodulesOverlay, countmodulesAdditional, powerOutput[moduleNumber]);
} //drawModules end

//------------------------------------------------------
// object name: printResults
//
// PURPOSE: this function prints the results for each rectangle (i.e. there will be 4 rectangles)
// PARAMETERS:
//        int rectNumber - the number of the rectangle
//        String finalOrientation - the final orientation (i.e. landscape or portrait)
//        String installationCompanyName - the name of the installation company
//        String moduleCompanyName - the name of the solar module company
//        String moduleType - the module or product type of the solar module
//        int countmodulesOverlay - the total number of overlay solar modules
//        int countmodulesAdditional - the total number of additional solar modules of a different orientation that does not impact the overlay solar modules and fits in the roof area
//        int powerOutput - the power output of the solar module
// Returns:
//        none
//------------------------------------------------------
void printResults(int targetAreaIndex, int rectNumber, String finalOrientation, String moduleType, int countmodulesOverlay, int countmodulesAdditional, int powerOutput)
{
  int ADD_PIXELS = 12;
  String orientation1 = " modules portrait";
  String orientation2 = " modules landscape";
  if (finalOrientation == "landscape")
  {
    orientation1 = " modules landscape";
    orientation2 = " modules portrait";
  }
  fill(0);
  textX = textX+WHITE_SPACE;
  textY = textY+ADD_PIXELS;
  text(rectNumber+1+sideOfTheHouse[targetAreaIndex].substring(0,1), textX, textY);
  textY = textY+ADD_PIXELS;
  text(moduleType, textX, textY);
  textY = textY+ADD_PIXELS;
  text(countmodulesOverlay + orientation1, textX, textY);
  textY = textY+ADD_PIXELS;
  text(countmodulesAdditional + orientation2, textX, textY);
  textY = textY+ADD_PIXELS;
  text(countmodulesTotal + " modules * " + powerOutput + "W", textX, textY);
  textY = textY+ADD_PIXELS;
  text(countmodulesTotal*powerOutput+"W", textX, textY);

  if (rectNumber < 2)
  {
    leftModuleType[rectNumber] = moduleType;
    lefttotalModules[rectNumber] = countmodulesTotal;
    leftPowerOutput[rectNumber] = powerOutput;
    leftTotalPowerOutput[rectNumber] = countmodulesTotal*powerOutput;
  }
  else
  {
    rightModuleType[rectNumber-2] = moduleType;
    righttotalModules[rectNumber-2] = countmodulesTotal;
    rightPowerOutput[rectNumber-2] = powerOutput;
    rightTotalPowerOutput[rectNumber-2] = countmodulesTotal*powerOutput;
  }
}

void printBuffersParameters()
{
  String   textLine;
  textY = textY+ADD_PIXELS;
  textLine = buffersFileName+" parameters";
  text(textLine,textX,textY);
  for (int i=0; i < buffersHeader.length; i++)
  {
    textY = textY+ADD_PIXELS;
    textLine = buffersHeader[i]+COLON+buffersDetail[i];
    text(textLine,textX,textY);
  }
}

void printTargetAreasParameters(int targetAreaIndex)
{
  int columnCount = targetAreasHeader.length;
  int index = columnCount*targetAreaIndex;
  String   textLine;
  textY = textY+ADD_PIXELS;
  textLine = targetAreasFileName+" parameters";
  text(textLine,textX,textY);
  for (int i=0; i < targetAreasHeader.length; i++)
  {
    textY = textY+ADD_PIXELS;
    textLine = targetAreasHeader[i]+COLON+targetAreasDetail[i+index];
    text(textLine,textX,textY);
  }
}

void printModuleLengthWidth(boolean left)
{
  int index = 0;
  String textLine;

  if (left) index = 0;
  if (!left) index = 1;
  
  textY = textY+ADD_PIXELS;
  textLine = "Module length (ft)"+COLON+module_length_ft[index];
  text(textLine,textX,textY);
  
  textY = textY+ADD_PIXELS;
  textLine = "Module length (in)"+COLON+module_length_in[index];
  text(textLine,textX,textY);

  textY = textY+ADD_PIXELS;
  textLine = "Module width (ft)"+COLON+module_width_ft[index];
  text(textLine,textX,textY);
  
  textY = textY+ADD_PIXELS;
  textLine = "Module width (in)"+COLON+module_width_in[index];
  text(textLine,textX,textY);
}

void printModulesParameters(boolean left)
{
  String   textLine;
  textY = textY+ADD_PIXELS;
  textLine = modulesFileName+" parameters";
  text(textLine,textX,textY);
  for (int i=0; i < modulesHeader.length; i++)
  {
    textY = textY+ADD_PIXELS;
    textLine = modulesHeader[i]+COLON;
    if (left) textLine = textLine+modulesDetailL[i];
    if (!left) textLine = textLine+modulesDetailR[i];
    text(textLine,textX,textY);
  }
}

void excel_2DTL(int targetAreaIndex, boolean winner, String moduleType, String sideOfTheHouse, int totalModules, int powerOutput, int totalPowerOutput)
{
  if (winner) excelWinners[targetAreaIndex] = "Excel 2DTL"+TAB+moduleType+TAB+sideOfTheHouse+TAB+totalModules+TAB+powerOutput+TAB+totalPowerOutput;
  if (!winner) excelLosers[targetAreaIndex] = "Excel 2DTL"+TAB+moduleType+TAB+sideOfTheHouse+TAB+totalModules+TAB+powerOutput+TAB+totalPowerOutput;
}

void printExcel()
{
  if (excelWinners[targetAreasTrueCount-1] != null)
  {
    if (readyToPrint)
    {
      readyToPrint = false;
      String excelHDR = "Excel 1HDR"+TAB+"Module Type"+TAB+"Side Of The House"+TAB+"Total modules"+TAB+"Power Output (W)"+TAB+"Total Power Output (W)";
      println(excelHDR);
      for (int i=0; i < excelWinners.length; i++)
      {
        println(excelWinners[i]);
        println(excelLosers[i]);
      }
    }
  }
}

void printSummary()
{
  boolean left = true;
  int grandTotalModulesL = 0;
  int grandTotalModulesR = 0;
  int grandTotalPowerOutputL = 0;
  int grandTotalPowerOutputR = 0;
  String andTheWinnerIs;
  String textLine;
  
  for (int i=0; i < totalModulesL.length; i++)
  {
    grandTotalModulesL = grandTotalModulesL+totalModulesL[i];
    grandTotalModulesR = grandTotalModulesR+totalModulesR[i];
    grandTotalPowerOutputL = grandTotalPowerOutputL+totalPowerOutputL[i];
    grandTotalPowerOutputR = grandTotalPowerOutputL+totalPowerOutputR[i];
  }

  fill(0);
  textX = 0;
  textY = 0;
  textX = textX+WHITE_SPACE;

  textY = textY+ADD_PIXELS;
  textLine = "SUMMARY";
  text(textLine,textX,textY);
  textY = textY+ADD_PIXELS;

  textY = textY+ADD_PIXELS;
  textLine = "LEFT MODULE";
  text(textLine,textX,textY);
  left = true;
  printModulesParameters(left);
  for (int i=0; i < totalModulesL.length; i++)
  {
    textY = textY+ADD_PIXELS;
    textLine = "Side of the house"+COLON+sideOfTheHouse[i]+COMMA+"Total modules"+COLON+totalModulesL[i]+COMMA+"Power Output (W)"+COLON+powerOutputL[i]+COMMA+"Total Power Output (W)"+COLON+totalPowerOutputL[i];
    text(textLine,textX,textY);
  }
  textY = textY+ADD_PIXELS;
  textLine = "GRAND TOTAL";
  text(textLine,textX,textY);
  textY = textY+ADD_PIXELS;
  textLine = "Total modules"+COLON+grandTotalModulesL+COMMA+"Total Power Output (W)"+COLON+grandTotalPowerOutputL;
  text(textLine,textX,textY);
  textY = textY+ADD_PIXELS;

  textY = textY+ADD_PIXELS;
  textLine = "RIGHT MODULE";
  text(textLine,textX,textY);
  left = false;
  printModulesParameters(left);
  for (int i=0; i < totalModulesR.length; i++)
  {
    textY = textY+ADD_PIXELS;
    textLine = "Side of the house"+COLON+sideOfTheHouse[i]+COMMA+"Total modules"+COLON+totalModulesR[i]+COMMA+"Power Output (W)"+COLON+powerOutputR[i]+COMMA+"Total Power Output (W)"+COLON+totalPowerOutputR[i];
    text(textLine,textX,textY);
  }
  textY = textY+ADD_PIXELS;
  textLine = "GRAND TOTAL";
  text(textLine,textX,textY);
  textY = textY+ADD_PIXELS;
  textLine = "Total modules"+COLON+grandTotalModulesR+COMMA+"Total Power Output (W)"+COLON+grandTotalPowerOutputR;
  text(textLine,textX,textY);
  textY = textY+ADD_PIXELS;

  textY = textY+ADD_PIXELS;
  textLine = "Total Power Output Difference (W)"+COLON+abs(grandTotalPowerOutputL-grandTotalPowerOutputR);
  text(textLine,textX,textY);
  textY = textY+ADD_PIXELS;

  textY = textY+ADD_PIXELS;
  textLine = "and THE WINNER IS!";
  text(textLine,textX,textY);
  andTheWinnerIs = "RIGHT MODULE";
  if (grandTotalPowerOutputL > grandTotalPowerOutputR) andTheWinnerIs = "LEFT MODULE";
  textY = textY+ADD_PIXELS;
  textLine = andTheWinnerIs;
  text(textLine,textX,textY);
  textY = textY+ADD_PIXELS;
}

//------------------------------------------------------
// object name: printTheWinner
//
// PURPOSE: this function prints the final results - the winner
// PARAMETERS:
//        none
// Returns:
//        none
//------------------------------------------------------
void printTheWinner(int targetAreaIndex)
{
  boolean left;
  int     diffTotalPowerOutput;
  int     leftRectNumber = 0;

  String  loserPrefix;
  String  loserModuleType;
  int     loserPowerOutput;
  String  loserRectNumber;
  int     loserTotalModules;
  int     loserTotalPowerOutput;

  int     maxLeftTotalPowerOutput = 0;
  int     maxRightTotalPowerOutput = 0;
  int     rectNumber = 0;
  int     rightRectNumber = 0;
  String  textLine;
  
  String  winnerPrefix;
  String  winnerModuleType;
  int     winnerPowerOutput;
  String  winnerRectNumber;
  int     winnerTotalModules;
  int     winnerTotalPowerOutput;

  for (int i = 0; i < leftTotalPowerOutput.length; i++)
  {
    if (leftTotalPowerOutput[i] > maxLeftTotalPowerOutput)
    {
      maxLeftTotalPowerOutput = leftTotalPowerOutput[i];
      leftRectNumber = i;
    }
  }

  for (int i = 0; i < rightTotalPowerOutput.length; i++)
  {
    if (rightTotalPowerOutput[i] > maxRightTotalPowerOutput)
    {
      maxRightTotalPowerOutput = rightTotalPowerOutput[i];
      rightRectNumber = i;
    }
  }

  powerOutputL[targetAreaIndex] = leftPowerOutput[leftRectNumber];
  powerOutputR[targetAreaIndex] = rightPowerOutput[leftRectNumber];
  totalModulesL[targetAreaIndex] = lefttotalModules[leftRectNumber];
  totalModulesR[targetAreaIndex] = righttotalModules[leftRectNumber];
  totalPowerOutputL[targetAreaIndex] = leftTotalPowerOutput[leftRectNumber];
  totalPowerOutputR[targetAreaIndex] = rightTotalPowerOutput[leftRectNumber];

  if (maxLeftTotalPowerOutput > maxRightTotalPowerOutput)
  {
    left = true;
    rectNumber = leftRectNumber;

    winnerRectNumber = str(leftRectNumber+1);
    winnerModuleType = leftModuleType[leftRectNumber];
    winnerTotalModules = lefttotalModules[leftRectNumber];
    winnerPowerOutput = leftPowerOutput[leftRectNumber];
    winnerTotalPowerOutput = leftTotalPowerOutput[leftRectNumber];

    loserRectNumber = str(rightRectNumber+3);
    loserModuleType = rightModuleType[rightRectNumber];
    loserTotalModules = righttotalModules[rightRectNumber];
    loserPowerOutput = rightPowerOutput[rightRectNumber];
    loserTotalPowerOutput = rightTotalPowerOutput[rightRectNumber];
  }
  else
  {
    left = false;
    rectNumber = rightRectNumber+2;

    winnerRectNumber = str(rightRectNumber+3);
    winnerModuleType = rightModuleType[rightRectNumber];
    winnerTotalModules = righttotalModules[rightRectNumber];
    winnerPowerOutput = rightPowerOutput[rightRectNumber];
    winnerTotalPowerOutput = rightTotalPowerOutput[rightRectNumber];

    loserRectNumber = str(leftRectNumber+1);
    loserModuleType = leftModuleType[leftRectNumber];
    loserTotalModules = lefttotalModules[leftRectNumber];
    loserPowerOutput = leftPowerOutput[leftRectNumber];
    loserTotalPowerOutput = leftTotalPowerOutput[leftRectNumber];
  }
  diffTotalPowerOutput = winnerTotalPowerOutput-loserTotalPowerOutput;

  winnerPrefix = winnerRectNumber+sideOfTheHouse[targetAreaIndex].substring(0,1);
  loserPrefix = loserRectNumber+sideOfTheHouse[targetAreaIndex].substring(0,1);

  fill(0);
  textX = (rectBigWidth*rectNumber)+(rectSpacerVertical*rectNumber);
  textX = textX+WHITE_SPACE;
  
  textY = textY+ADD_PIXELS;
  printBuffersParameters();

  textY = textY+ADD_PIXELS;
  printTargetAreasParameters(targetAreaIndex);

  textY = textY+ADD_PIXELS;
  textY = textY+ADD_PIXELS;
  textLine = "and THE WINNER IS!";
  text(textLine,textX,textY);

  textY = textY+ADD_PIXELS;
  printModulesParameters(left);
  printModuleLengthWidth(left);
  
  textY = textY+ADD_PIXELS;
 
  textY = textY+ADD_PIXELS;
  textLine = winnerPrefix+COLON+"Module Type"+COLON+winnerModuleType+COLON+"Total modules"+COLON+winnerTotalModules+COLON+"Power Output (W)"+COLON+winnerPowerOutput+COLON+"Total Power Output (W)"+COLON+winnerTotalPowerOutput;
  text(textLine,textX,textY);
  
  textY = textY+ADD_PIXELS;
  textLine = loserPrefix+COLON+"Module Type"+COLON+loserModuleType+COLON+"Total modules"+COLON+loserTotalModules+COLON+"Power Output (W)"+COLON+loserPowerOutput+COLON+"Total Power Output (W)"+COLON+loserTotalPowerOutput;
  text(textLine,textX,textY);

  textY = textY+ADD_PIXELS;
  textY = textY+ADD_PIXELS;
  textLine = "Total Power Output Difference (W)"+COLON+diffTotalPowerOutput;
  text(textLine,textX,textY);

  excel_2DTL(targetAreaIndex, true, winnerModuleType, sideOfTheHouse[targetAreaIndex], winnerTotalModules, winnerPowerOutput, winnerTotalPowerOutput);
  excel_2DTL(targetAreaIndex, false, loserModuleType, sideOfTheHouse[targetAreaIndex], loserTotalModules, loserPowerOutput, loserTotalPowerOutput);
  printExcel();
}

void printBooleanArray(String arrayName, boolean[] arrayValue)
{
  for (int i=0; i<arrayValue.length; i++)
  {
    if (debug) println(arrayName+"["+i+"] = "+arrayValue[i]);
  }
}

void printFloatArray(String arrayName, float[] arrayValue)
{
  for (int i=0; i<arrayValue.length; i++)
  {
    if (debug) println(arrayName+"["+i+"] = "+arrayValue[i]);
  }
}

void printIntArray(String arrayName, int[] arrayValue)
{
  for (int i=0; i<arrayValue.length; i++)
  {
    if (debug) println(arrayName+"["+i+"] = "+arrayValue[i]);
  }
}

void printStringArray(String arrayName, String[] arrayValue)
{
  for (int i=0; i<arrayValue.length; i++)
  {
    if (debug) println(arrayName+"["+i+"] = "+arrayValue[i]);
  }
}

void getModulesHeader()
{
  String[] lines;

  lines = loadStrings(modulesFileName);
  for (int x=0; x < 1; x++)
  {
    String[] pieces = split(lines[x], '\t');
    modulesHeader = new String[pieces.length-1];
    for (int i=1; i < pieces.length; i++)
    {
      modulesHeader[i-1] = pieces[i];
    }
  }
  printStringArray("modulesHeader", modulesHeader);
}

void getTargetAreasHeader()
{
  String[] lines;

  lines = loadStrings(targetAreasFileName);
  for (int x=0; x < 1; x++)
  {
    String[] pieces = split(lines[x], '\t');
    targetAreasHeader = new String[pieces.length-1];
    for (int i=1; i < pieces.length; i++)
    {
      targetAreasHeader[i-1] = pieces[i];
    }
  }
  printStringArray("targetAreasHeader", targetAreasHeader);
}