#include <QApplication>
#include <QPushButton>
#include <hwl/hello.h>

int main(int argc, char* argv[])
{
	QApplication const app(argc, argv);
	QPushButton HelloWorld(
		QString::fromStdString(getHello(0)) +
		"\n Qt Library: v" + qVersion() +
		"\n Qt Build  : v" + QT_VERSION_STR
	);
	HelloWorld.resize(300, 60);
	HelloWorld.show();
	return QApplication::exec();
}