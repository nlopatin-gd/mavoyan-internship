# Documentation

## The task
### Monitoring part
1. Rebuild your spring-petclinic Docker image to run with JMX Prometheus exporter.
2. Validate that exporter endpoint is accessible at <ip_or_hostname>:<exporter_port>/metrics
3. Run Prometheus Docker container scrapping JMX metrics.
4. Validate that Prometheus gathers data by running the following queries:<br/>
a) java_lang_OperatingSystem_CpuLoad<br/>
b) java_lang_OperatingSystem_FreeMemorySize<br/>
c) java_lang_Memory_HeapMemoryUsage_used<br/>
d)java_lang_Runtime_Uptime<br/>
5. Play around with different views and explore the user interface
6. Run Grafana container, log in, explore browser and:
Create Prometheus data source in the user interface
Import dashboard with its id - 10519
7. OPTIONAL: Automate the creation of data_source and dashboard resources<br/>
 a) It may be: [
 Pure API requests,
 Grafonnet and API requests,
 Ansible,
 Terraform
]<br/>
b) Choose whatever fits you

### Logging part

1. Install Loki and Promtail
2. Run your spring-boot binary locally in the following way:<br>
    ``
    java <app>.jar > <app>.log
    ``
3. Run Loki with the default configuration
4. Prepare your Promtail config to read logs from <app>.log and send logs to Loki. Run it
5. Log in Grafana<br/>
a) Add Loki data source<br/>
b) ollow along to Explore tab and check out for logs

## Steps
1)Rebuild your spring-petclinic Docker image to run with JMX Prometheus exporter.<br/>
Clone git repository for spring petclinic application
```
git clone git@github.com:avmang/spring-petclinic.git
cd spring-petclinic/
```
I have added following files
 - ``config.yml``
 - ``prometheus.yml``
And changed the context of this files
 - ``Dockerfile``
 - ``docker-compose.yml``

### Changes in Dockerfile
I've added this part in Dockerfile for working with JMX exporter
```
ENV VERSION 0.11.0
ENV JAR jmx_prometheus_javaagent-$VERSION.jar

RUN mkdir -p /opt/jmx_exporter
RUN curl -L https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/$VERSION/$JAR -o /opt/jmx_exporter/$JAR
RUN chmod +x /opt/jmx_exporter/$JAR
COPY config.yml /opt/jmx_exporter/config.yaml
```
Exposed one more port for metrics
```
EXPOSE 10254
```
And changed CMD command to run with JMX Exporter
```
CMD java -javaagent:/opt/jmx_exporter/$JAR=10254:/opt/jmx_exporter/config.yaml -jar app.jar
```
The final content of ``Dockerfile``:<br/>
https://github.com/avmang/spring-petclinic/blob/main/Dockerfile

### Changes in Docker Compose 

I've added 
- ``10254:10254`` port mapping for app service.
- ``grafana`` service
- ``prometheus`` service
- volume for grafana 

The final content of ``Docker Compose``:<br/>
https://github.com/avmang/spring-petclinic/blob/main/docker-compose.yml

### Configurations for Monitoring

The content of config.yml for JMX exporter -> https://github.com/avmang/spring-petclinic/blob/main/config.yml

Configurations for prometheus -> https://github.com/avmang/spring-petclinic/blob/main/prometheus.yml

As a target for prometheus we need to set the host like this:
```
- targets:
      - app:10254 # <service_name>:<port>
```
Binding of prometheus.yml file in Docker Compose (line 41)
```
- ./prometheus.yml:/etc/prometheus/prometheus.yml
```
Binding of config.yml file in Dockerfile (line 30)
```
CMD java -javaagent:/opt/jmx_exporter/$JAR=10254:/opt/jmx_exporter/config.yaml -jar app.jar
```

2)Validate that exporter endpoint is accessible at <ip_or_hostname>:<exporter_port>/metrics

To validate the exporter endpoint ant first we need to do
```
 docker-compose up --build -d
```
![Screenshot](../screenshots/monitoring/containers.png)
Now we can visit to ``localhost:10254/metrics``
![Screenshot](../screenshots/monitoring/metrics.png)

4) Validate that Prometheus gathers data by running the following queries:<br/>
- java_lang_OperatingSystem_CpuLoad<br/>
-  java_lang_OperatingSystem_FreeMemorySize<br/>
- java_lang_Memory_HeapMemoryUsage_used<br/>
- java_lang_Runtime_Uptime<br/>

To do this visit to ``localhost:9090``
![Screenshot](../screenshots/monitoring/1.png)
![Screenshot](../screenshots/monitoring/2.png)
![Screenshot](../screenshots/monitoring/3.png)
![Screenshot](../screenshots/monitoring/4.png)

6)  Run Grafana container, log in, explore browser and:
Create Prometheus data source in the user interface
Import dashboard with its id - 10519

To automated grafana we will use terraform.<br/>
We will need service account and token for that. To gather that use this requests.
```
curl -X POST -H "Content-Type: application/json" -d '{"name":"terraform", "role": "Admin"}' http://admin:admin@localhost:3000/api/serviceaccounts
```
![Screenshot](../screenshots/monitoring/r1.png)
```
curl -X POST -H "Content-Type: application/json" -d '{"name":"terraform-token"}' http://admin:admin@localhost:3000/api/serviceaccounts/<service account id>/tokens
```
![Screenshot](../screenshots/monitoring/r2.png)
Go to terraform directory
```
cd terraform
```
terraform file -> https://github.com/avmang/spring-petclinic/blob/main/terraform/grafana.tf<br/>
Download Json file for jmx exporter dashboard
```
 wget -O jmx_exporter_dashboard.json https://grafana.com/api/dashboards/10519/revisions/2/download
```
```
terraform init
terraform validate
terraform plan
terraform apply
```
Set generated token as input variable
```
terraform destroy #for destroying
```
Manual:<br/>
Go to ``localhost:3000``<br/>
Log in with admin:admin <br/>
Add prometheus datasourse. <br/>
![Screenshot](../screenshots/monitoring/ds.png)
![Screenshot](../screenshots/monitoring/pds.png)
Url must be with prometheus service name. Test and Save.
![Screenshot](../screenshots/monitoring/tas.png)
Add Dashboard.
![Screenshot](../screenshots/monitoring/db.png)
![Screenshot](../screenshots/monitoring/idb.png)
Write 10519 as ID.
![Screenshot](../screenshots/monitoring/dashboard.png)
Result:
![Screenshot](../screenshots/monitoring/res1.png)
![Screenshot](../screenshots/monitoring/res2.png)


### Logging part

I've added services for promtail and loki in docker-compose file, and changed grafana service to automaticlly add datasource of loki.<br/>
Docker-compose file -> https://github.com/avmang/spring-petclinic/blob/main/docker-compose.yml

Changed the CMD command in Dockerfile to save logs in app.log file.
```
CMD java -javaagent:/opt/jmx_exporter/$JAR=10254:/opt/jmx_exporter/config.yaml -jar app.jar > logs/app.log
```
For promtail we need to configure the file from where promtail will read logs and the loki server to send logs.
```
__path__: /var/log/app.log
```
```
clients:
  - url: http://loki:3100/loki/api/v1/push
```
Config file for promtail -> https://github.com/avmang/spring-petclinic/blob/main/logging/config.yml

To run all that services we need to run this command
```
docker-compose up --build -d
```
To see loki is up go to ``localhost:3100/ready``
![Screenshot](../screenshots/monitoring/lokir.png)

To see promtail navigate to ``localhost:9080/targets``
![Screenshot](../screenshots/monitoring/promtarget.png)

To see the final result go to grafana ``localhost:3000``

Data soruces -> Loki
![Screenshot](../screenshots/monitoring/gloki.png)
Explore data
![Screenshot](../screenshots/monitoring/exploredata.png)
Select lables
![Screenshot](../screenshots/monitoring/labels.png)
Click on run query button
![Screenshot](../screenshots/monitoring/runquery.png)
Result:
![Screenshot](../screenshots/monitoring/logres.png)