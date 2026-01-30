#include <QApplication>
#include <QPushButton>
#include <hwl/hello.h>

int main(int argc, char* argv[])
{
	auto* app = new QApplication(argc, argv);
	auto text = QString::fromStdString(getHello(argc)) + "\n";
	text += "Timestamp: " + QString::fromStdString(utcTimeString()) + "\n";
	text += QString("Qemu Virtualization: ").append(isQemu() ? "Yes" : "No") + "\n";
	text += QString("Wine Compatibility Layer: ").append(isWine() ? "Yes" : "No") + "\n";
	text += "CPU Architecture: " + QString::fromStdString(getCpuArchitecture()) + "\n";
	text += "Compiler: " + QString::fromStdString(getCompilerVersion()) + "\n";
	text += "Standard: " + QString::fromStdString(getCppStandardVersion()) + "\n";
	text += QString("Qt Library: v") + qVersion() + "\n";
	text += QString("Qt Build  : v") + QT_VERSION_STR;
	auto* HelloWorld = new QPushButton(text);
	HelloWorld->resize(300, 170);
	HelloWorld->show();
	auto rv = app->exec();
// Fix for hanging Qt threads in Wine since 6.9.1
#if defined(__MINGW32__) && QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
	killOtherThreads();
#endif
	delete HelloWorld;
	delete app;
	return rv;
}