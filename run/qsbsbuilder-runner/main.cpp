#include <iostream>

/* run this program using the console pauser or add your own getch, system("pause") or input loop */

int main(int argc, char** argv) {
	system("start /b javaw -Djava.awt.headless=false -Dfile.encoding=utf-8 -Dspring.profiles.active=pro -jar \"%cd%/qsb-s-builder.jar\"");
	return 0;
}
