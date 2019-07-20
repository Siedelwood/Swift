#include <iostream>
#include <cstdlib>

int main(int argc, char** argv) {
	system("java -Dfile.encoding=UTF8 -jar \"%CUTSCENE_MAKER_HOME%/CutsceneMaker.jar\" %*");
	return 0;
}
