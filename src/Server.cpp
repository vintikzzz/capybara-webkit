#include "Server.h"
#include "Connection.h"
#include "WebPageManager.h"

#include <QTcpServer>

Server::Server(QObject *parent) : QObject(parent) {
  m_tcp_server = new QTcpServer(this);
}

bool Server::start(int port) {
#if QT_VERSION < QT_VERSION_CHECK(5, 0, 0)
  QTextStream(stderr) <<
    "WARNING: The next major version of capybara-webkit " <<
    "will require at least version 5.0 of Qt. " <<
    "You're using version " << QT_VERSION_STR << "." << endl;
#endif

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
  while (!queue.isEmpty()) {
    QTcpSocket *socket = queue.dequeue();
    socket->close();
  }
  m_tcp_server->close();
  std::cout << "Terminated" << std::endl;
}
void Server::handleTermination() {
  stop();
}
void Server::process() {
  QTcpSocket *socket = queue.head();
  int id = socket->socketDescriptor();
  std::cout << "Start processing: " << id << std::endl;
  Connection *conn = new Connection(socket, new WebPageManager(this), this);
  connect(socket, SIGNAL(disconnected()), this, SLOT(handleDisconnection()));
  connect(socket, SIGNAL(disconnected()), socket, SLOT(deleteLater()));
  connect(socket, SIGNAL(disconnected()), conn, SLOT(handleDisconnection()));
}
void Server::handleConnection() {
  QTcpSocket *socket = m_tcp_server->nextPendingConnection();
  int id = socket->socketDescriptor();
  std::cout << "Client connected: " << id << std::endl;
  queue.enqueue(socket);
  std::cout << "Queue length: " << queue.count() << std::endl;
  if (queue.count() == 1) {
    this->process();
  }
}
void Server::handleDisconnection() {
  QTcpSocket *socket = qobject_cast<QTcpSocket *>(sender());
  int id = socket->socketDescriptor();
  queue.dequeue();
  if(!queue.isEmpty()) {
    this->process();
  }
  std::cout << "Client disconnected: " << id << std::endl;
}
