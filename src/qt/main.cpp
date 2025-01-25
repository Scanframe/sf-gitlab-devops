#include <QApplication>
#include <QPushButton>
#include <hwl/hello.h>

int main(int argc, char* argv[])
{
	QApplication const app(argc, argv);
	QPushButton HelloWorld(
		QString::fromStdString(getHello(0)) +
		"\nTimestamp: " + QString::fromStdString(utcTimeString()) +
		"\nGCC Version: " + QString::fromStdString(getGCCVersion()) +
		"\nStandard: " + QString::fromStdString(getCppStandardVersion()) +
		"\nQt Library: v" + qVersion() +
		"\nQt Build  : v" + QT_VERSION_STR
	);
	HelloWorld.resize(300, 120);
	HelloWorld.show();
	return QApplication::exec();
}