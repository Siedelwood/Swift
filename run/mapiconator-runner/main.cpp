#include <iostream>
#include <cstdlib>

int main(int argc, char** argv) {
	system("start /b javaw -Dfile.encoding=UTF8 -jar \"%cd%/MapIconator.jar\"");
	return 0;
}
