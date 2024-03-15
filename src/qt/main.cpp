#include <QApplication>
#include <QPushButton>
#include <hwl/hello.h>

int main(int argc, char* argv[])
{
	QApplication a(argc, argv);
	QPushButton HelloWorld(QString::fromStdString(getHello(0)));
	HelloWorld.resize(300, 60);
	HelloWorld.show();
	return a.exec();
}