FROM swift:4.2.2
EXPOSE 8080
COPY . /project
RUN cd /project && swift build --build-path=.build-ubuntu-epoll
CMD /project/.build-ubuntu-epoll/debug/DebugWebSocketServer
