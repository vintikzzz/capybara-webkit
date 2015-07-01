#include "Server.h"
#include "IgnoreDebugOutput.h"
#include "StdinNotifier.h"
#include <QApplication>
#include <QCommandLineOption>
#include <iostream>
#ifdef Q_OS_UNIX
  #include <unistd.h>
#endif

int main(int argc, char **argv) {
#ifdef Q_OS_UNIX
  if (setpgid(0, 0) < 0) {
    std::cerr << "Unable to set new process group." << std::endl;
    return 1;
  }
#endif

  QApplication app(argc, argv);
  app.setApplicationName("capybara-webkit");
  app.setOrganizationName("thoughtbot, inc");
  app.setOrganizationDomain("thoughtbot.com");
  QCommandLineParser parser;
  parser.setApplicationDescription("capybara-webkit");
  parser.addHelpOption();
  QCommandLineOption portOption(QStringList() << "p" << "port",
    QCoreApplication::translate("main", "Sets <port> to listen."),
    QCoreApplication::translate("main", "port"), "0");
  parser.addOption(portOption);
  parser.process(app);
  int port = parser.value(portOption).toInt();
  StdinNotifier notifier;
  if (port == 0)
  {
    QObject::connect(&notifier, SIGNAL(eof()), &app, SLOT(quit()));
  }

  ignoreDebugOutput();
  Server server(0);

  QObject::connect(&app, SIGNAL(aboutToQuit()), &server, SLOT(handleTermination()));
  if (server.start(port)) {
    std::cout << "Capybara-webkit server started, listening on port: " << server.server_port() << std::endl;
    return app.exec();
  } else {
    std::cerr << "Couldn't start capybara-webkit server: " << server.error_string().toUtf8().constData() << std::endl;
    return 1;
  }
}
