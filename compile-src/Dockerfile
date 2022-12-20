FROM openjdk:8-jdk

RUN apt install apt-transport-https ca-certificates
RUN apt-get update && apt-get install -y openssh-server iproute2 net-tools iputils-ping supervisor vim ant maven python python3 python3-pip python-six psmisc

RUN pip3 install six
RUN apt-get install iptables -y

ADD general-setup.sh /usr/local/bin/general-setup.sh
RUN sh /usr/local/bin/general-setup.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 1. Put code in it
COPY apache-cassandra-4.0.7 /cassandra/apache-cassandra-4.0.7
COPY apache-cassandra-4.1.0 /cassandra/apache-cassandra-4.1.0

# 2. System setup.
RUN pip3 install cassandra-driver
ADD cassandra-clusternode.sh /usr/local/bin/cassandra-clusternode

# This can be overwritten in docker-compose.yaml by setting command
EXPOSE 22 9160
CMD ["/usr/bin/supervisord"]
