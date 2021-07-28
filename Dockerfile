FROM centos:7

RUN yum -y update && yum -y install python3 python3-dev python3-pip python3-virtualenv \
	java-1.8.0-openjdk wget

RUN python -V
RUN python3 -V

ENV PYSPARK_DRIVER_PYTHON python3
ENV PYSPARK_PYTHON python3

RUN pip3 install --upgrade pip
RUN pip3 install numpy panda
RUN pip3 install pandas

RUN cd /opt && wget https://apache.osuosl.org/spark/spark-3.1.2/spark-3.1.2-bin-hadoop2.7.tgz && tar -xzf spark-3.1.2-bin-hadoop2.7.tgz && rm spark-3.1.2-bin-hadoop2.7.tgz


RUN ln -s /opt/spark-3.1.2-bin-hadoop2.7 /opt/spark
RUN (echo 'export SPARK_HOME=/opt/spark' >> ~/.bashrc && echo 'export PATH=$SPARK_HOME/bin:$PATH' >> ~/.bashrc && echo 'export PYSPARK_PYTHON=python3' >> ~/.bashrc)

RUN mkdir /code
RUN mkdir code/testdata.model/

COPY wine_test_data_2.py /code/ 
COPY testdata.model/ /code/testdata.model
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN /bin/bash -c "source ~/.bashrc"
RUN /bin/sh -c "source ~/.bashrc"

WORKDIR /code

ENTRYPOINT ["/opt/spark/bin/spark-submit",  "wine_test_data_2.py"]