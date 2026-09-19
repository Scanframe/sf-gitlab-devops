#include <QApplication>
#include <QPushButton>
#include <QThreadPool>
#include <hwl/hello.h>

int main(int argc, char* argv[])
{
	QApplication const app(argc, argv);
	auto text = QString::fromStdString(getHello(argc)) + "\n";
	text += "Application: " + QString::fromStdString(getApplicationVersion()) + "\n";
	text += "Timestamp: " + QString::fromStdString(utcTimeString()) + "\n";
	text += QString("Qemu Virtualization: ").append(isQemu() ? "Yes" : "No") + "\n";
	text += QString("Wine Compatibility Layer: ").append(isWine() ? "Yes" : "No") + "\n";
	text += "CPU Architecture: " + QString::fromStdString(getCpuArchitecture()) + "\n";
	text += "Compiler: " + QString::fromStdString(getCompilerVersion()) + "\n";
	text += "Standard: " + QString::fromStdString(getCppStandardVersion()) + "\n";
	text += QString("Qt Library: v") + qVersion() + "\n";
	text += QString("Qt Build  : v") + QT_VERSION_STR;
	const auto btn = std::make_unique<QPushButton>(text, nullptr);
	btn->resize(300, 200);
	btn->show();
	QObject::connect(btn.get(), &QPushButton::clicked, []() -> void {
		QApplication::quit();
	});
	// Fix for hanging Qt threads in Wine since 6.9.1
	const auto exit_code = QCoreApplication::exec();
#if IS_MINGW_THREADLOCAL_BUGGY
	QThreadPool::globalInstance()->waitForDone();
	exit(exit_code);
#endif
	return exit_code;
}