#include <iostream>
#include <cstdlib>

int main(int argc, char** argv) {
	if (argc != 3) {
		printf("Wrong arguments!\n");
		printf("usage:  CutsceneMaker <CutsceneName> <PathToFolder>\n");
		printf("sample: CutsceneMaker Cutscene01 \"%%cd%%\\cs\\cs-intro\"\n");
		return 1;
	}
	
	char commandBuffer[2048];
	
	char* arg1 = argv[1];
	char* arg2 = argv[2];
	sprintf(
		commandBuffer, 
		"java -Dfile.encoding=UTF8 -jar \"%%CUTSCENE_MAKER_HOME%%\\CutsceneMaker.jar\" %s %s",
		arg1, arg2
	);
	system(commandBuffer);
	return 0;
}
