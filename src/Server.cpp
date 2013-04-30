#include "Server.h"
#include "Connection.h"
#include "WebPageManager.h"

#include <QTcpServer>

Server::Server(QObject *parent) : QObject(parent) {
  m_tcp_socket = 0;
  m_tcp_server = new QTcpServer(this);
}

bool Server::start(int port) {
  connect(m_tcp_server, SIGNAL(newConnection()), this, SLOT(handleConnection()));
  return m_tcp_server->listen(QHostAddress::LocalHost, port);
}

quint16 Server::server_port() const {
  return m_tcp_server->serverPort();
}
QString Server::error_string() const {
  return m_tcp_server->errorString();
}

void Server::handleConnection() {
  QTcpSocket *socket = m_tcp_server->nextPendingConnection();
  connect(socket, SIGNAL(disconnected()), this, SLOT(handleDisconnection()));
  connect(socket, SIGNAL(disconnected()), socket, SLOT(deleteLater()));
  
  if (m_tcp_socket != 0) {
    socket->disconnectFromHost();
    return;
  }
  m_tcp_socket = socket;
  new Connection(m_tcp_socket, new WebPageManager(this), this);
}
void Server::handleDisconnection() {
  m_tcp_socket = 0;
}
