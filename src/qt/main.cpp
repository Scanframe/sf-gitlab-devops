#include <QApplication>
#include <QPushButton>
#include <QThreadPool>
#include <hwl/hello.h>

int main(int argc, char* argv[])
{
	QApplication app(argc, argv);
	auto text = QString::fromStdString(getHello(argc)) + "\n";
	text += "Timestamp: " + QString::fromStdString(utcTimeString()) + "\n";
	text += QString("Qemu Virtualization: ").append(isQemu() ? "Yes" : "No") + "\n";
	text += QString("Wine Compatibility Layer: ").append(isWine() ? "Yes" : "No") + "\n";
	text += "CPU Architecture: " + QString::fromStdString(getCpuArchitecture()) + "\n";
	text += "Compiler: " + QString::fromStdString(getCompilerVersion()) + "\n";
	text += "Standard: " + QString::fromStdString(getCppStandardVersion()) + "\n";
	text += QString("Qt Library: v") + qVersion() + "\n";
	text += QString("Qt Build  : v") + QT_VERSION_STR;
	auto* btn = new QPushButton(text);
	btn->resize(300, 170);
	btn->show();
	QObject::connect(btn, &QPushButton::clicked, [] {
		QApplication::quit();
	});
	// Fix for hanging Qt threads in Wine since 6.9.1
	auto rv = QCoreApplication::exec();
	delete btn;
#if IS_MINGW_THREADLOCAL_BUGGY
	QThreadPool::globalInstance()->waitForDone();
	exit(rv);
#endif
	return rv;
}