#include <QObject>
#include <QThreadPool>

class QTcpServer;

class Server : public QObject {
  Q_OBJECT

  public:
    Server(QObject *parent);
    bool start(int port = 0);
    void stop();
    quint16 server_port() const;
    QString error_string() const;

  public slots:
    void handleTermination();

  private slots:
    void handleConnection();
    void handleDisconnection();

  private:
    QTcpServer *m_tcp_server;
    QMap<int, QTcpSocket *> sockets;
    QThreadPool *pool;
};

