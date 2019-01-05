#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <cstdlib>

#include <iostream>
#include <algorithm>

#include "ipc.h"

namespace senn {
namespace ipc {

Connection* Connection::ConnectTo(const std::string &socket_name) {
  // std::cout << "ConnectTo: called" << std::endl;

  sockaddr_un addr;
  addr.sun_family = AF_LOCAL;
  strcpy(addr.sun_path, socket_name.c_str());

  int socket_fd = socket(PF_LOCAL, SOCK_STREAM, 0);
  if (socket_fd < 0) {
    std::cerr << "Failed to create socket" << std::endl;
    std::exit(1);
  }

  if ((connect(socket_fd,
               reinterpret_cast<sockaddr*>(&addr),
               SUN_LEN(&addr))) < 0) {
    std::cerr << "Failed to connect" << std::endl;
    std::exit(1);
  }

  return new Connection(socket_fd);
}


Connection::Connection(const int socket_fd)
  : socket_fd_(socket_fd) {
}


void Connection::Write(const std::string &content) {
  write(socket_fd_, content.c_str(), content.size());
}


void Connection::ReadLine(std::string *output) {
  char buffer[1024];

  while (1) {
    int bytes_read = read(socket_fd_, buffer, sizeof(buffer) - 1);

    if (bytes_read == -1) {
      std::cerr << "Failed to read" << std::endl;
      std::exit(1);
    }

    if (bytes_read == 0) {
      return;
    }

    *output += std::string(buffer, size_t(bytes_read));
    if (buffer[bytes_read - 1] == '\n') {
      output->erase(std::find_if(
                        output->rbegin(),
                        output->rend(),
                        [](int ch) { return !std::isspace(ch); }
                    ).base(),
                    output->end());
      return;
    }

    return;
  }
}


void Connection::Close() {
  close(socket_fd_);
}

} // ipc
} // senn