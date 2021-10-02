#include <iostream>
#include <cstdlib>

int main(int argc, char** argv) {
	// system("start /b javaw -Dfile.encoding=UTF8 -jar \"%cd%/MapIconator.jar\"");
	system("start /b jre/bin/javaw -Dspring.profiles.active=mapicon -Dfile.encoding=UTF8 -jar \"%cd%/updater.jar\"");
	return 0;
}
