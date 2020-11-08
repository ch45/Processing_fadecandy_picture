// Processing_fadecandy_picture.pde
//
// Show a slide show of picture files
// Move the image to make it more interesting on the grid of LEDs

OPC opc;
final String fcServerHost = "127.0.0.1";
final int fcServerPort = 7890;

final int boxesAcross = 2;
final int boxesDown = 2;
final int ledsAcross = 8;
final int ledsDown = 8;
// initialized in setup()
float spacing;
int x0;
int y0;

PImage images[];
int duration = 15;

int exitTimer = 0; // Run forever unless set by command line
String fileRegEx = "^.+\\.(gif|jpg|jpeg|tga|png)$";


void setup()
{
  apply_cmdline_args();

  size(720, 640, P3D);

  images = loadImageData(dataPath(""));

  opc = new OPC(this, fcServerHost, fcServerPort); // Connect to an instance of fcserver

  spacing = (float)min(height / (boxesDown * ledsDown + 1), width / (boxesAcross * ledsAcross + 1));
  x0 = (int)(width - spacing * (boxesAcross * ledsAcross - 1)) / 2;
  y0 = (int)(height - spacing * (boxesDown * ledsDown - 1)) / 2;

  final int boxCentre = (int)((ledsAcross - 1) / 2.0 * spacing); // probably using the centre in the ledGrid8x8 method
  int ledCount = 0;
  for (int y = 0; y < boxesDown; y++) {
    for (int x = 0; x < boxesAcross; x++) {
      opc.ledGrid8x8(ledCount, x0 + spacing * x * ledsAcross + boxCentre, y0 + spacing * y * ledsDown + boxCentre, spacing, 0, false, false);
      ledCount += ledsAcross * ledsDown;
    }
  }
}


void draw()
{
  int m = millis();
  int index = (m / (duration * 1000)) % images.length;
  int z1 = (int)( sin(TWO_PI * (float)m /  6000) * 32);
  int z2 = (int)( cos(TWO_PI * (float)m /  9000) * 32);
  int z3 = (int)(-sin(TWO_PI * (float)m / 12000) * 32);
  int z4 = (int)(-cos(TWO_PI * (float)m / 15000) * 32);
  PImage img = scaleCentreForDisplay(images[index]);
  
  background(0);
  translate(width / 2, height / 2);
  beginShape();
  texture(img);
  vertex(-img.width / 2 + z1, -img.height / 2 + z1, z1, 0,     0);
  vertex( img.width / 2 + z2, -img.height / 2 + z2, z2, width, 0);
  vertex( img.width / 2 + z3,  img.height / 2 + z3, z3, width, height);
  vertex(-img.width / 2 + z4,  img.height / 2 + z4, z4, 0,     height);
  endShape();

  check_exit();
}


PImage[] loadImageData(String path) {
  
  ArrayList<PImage> imgs = new ArrayList<PImage>();
  String[] filenames = listFileNames(path);

  for (String name : filenames) {
    if (name.matches(fileRegEx)) {
      println("name="+name);
      imgs.add(loadImage(name));
    }
  }

  return imgs.toArray(new PImage[0]);
}


// This function returns all the files in a directory as an array of Strings
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}


PImage scaleCentreForDisplay(PImage src) {
  PImage dest = createImage(width, height, RGB);
  int widthScale = 0;
  int heightScale = 0;
  if (src.height / src.width > height / width) {
    heightScale = height;
  } else {
    widthScale = width;
  }
  src.resize(widthScale, heightScale);
  dest.copy(src, 0, 0, src.width, src.height, (width - src.width) / 2, (height - src.height) / 2, src.width, src.height);

  return dest;
}


void apply_cmdline_args()
{
  if (args == null) {
    return;
  }
  for (String exp: args) {
      String[] comp = exp.split("=");
      switch (comp[0]) {
        case "duration":
          duration = parseInt(comp[1], 10);
          println("duration of " + duration + "s");
          break;
        case "fileRegEx":
          fileRegEx = comp[1];
          println("use fileRegEx " + fileRegEx);
          break;
        case "exit":
          exitTimer = parseInt(comp[1], 10);
          println("exit after " + exitTimer + "s");
          break;
      }
  }
}

void check_exit()
{

  if (exitTimer == 0) { // skip if not run from cmd line
    return;
  }

  int m = millis();
  if (m / 1000 >= exitTimer) {
    println(String.format("average %.1f fps", (float)frameCount / exitTimer));
    exit();
  }
}
