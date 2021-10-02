#include <iostream>
#include <cstdlib>

int main(int argc, char** argv) {
	// system("start /b javaw -Dfile.encoding=UTF8 -jar \"%cd%/QuestSystemBehavior.jar\"");
	system("start /b jre/bin/javaw -Dspring.profiles.active=s5mapmaker -Dfile.encoding=UTF8 -jar \"%cd%/updater.jar\"");
	return 0;
}
