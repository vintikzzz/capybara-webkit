#include "Server.h"
#include "Connection.h"
#include "WebPageManager.h"

#include <QTcpServer>

Server::Server(QObject *parent) : QObject(parent) {
  m_tcp_server = new QTcpServer(this);
}

<<<<<<< HEAD
bool Server::start(int port) {
=======
bool Server::start() {
#if QT_VERSION < QT_VERSION_CHECK(5, 0, 0)
  QTextStream(stderr) <<
    "WARNING: The next major version of capybara-webkit " <<
    "will require at least version 5.0 of Qt. " <<
    "You're using version " << QT_VERSION_STR << "." << endl;
#endif

>>>>>>> upstream/master
  connect(m_tcp_server, SIGNAL(newConnection()), this, SLOT(handleConnection()));
  return m_tcp_server->listen(QHostAddress::LocalHost, port);
}

quint16 Server::server_port() const {
  return m_tcp_server->serverPort();
}
QString Server::error_string() const {
  return m_tcp_server->errorString();
}

void Server::stop() {
  foreach(int i, sockets.keys()){
    sockets[i]->close();
    sockets.remove(i);
  }
  m_tcp_server->close();
  std::cout << "Terminated" << std::endl;
}
void Server::handleTermination() {
  stop();
}
void Server::handleConnection() {
  QTcpSocket *socket = m_tcp_server->nextPendingConnection();
  int id = socket->socketDescriptor();
  sockets[id] = socket;
  std::cout << "Client connected: " << id << std::endl;
  connect(socket, SIGNAL(disconnected()), this, SLOT(handleDisconnection()));
  connect(socket, SIGNAL(disconnected()), socket, SLOT(deleteLater()));
  new Connection(socket, new WebPageManager(this), this);
}
void Server::handleDisconnection() {
  QTcpSocket *socket = qobject_cast<QTcpSocket *>(sender());
  int id = socket->socketDescriptor();
  sockets.remove(id);
  std::cout << "Client disconnected: " << id << std::endl;
}
