# Documentation

## The task

1. Download/install Tomcat server.
2. Verify that it works by visiting the root page.
    a. What ports are used by the java process?
3. Remove all default applications (including manager), restart Tomcat.
4. Download Jenkins WAR and deploy into Tomcat.
5. Verify that application works (visit application URL).
6. Enable JMX in Tomcat.
    a. What ports are used by the java process?
    b. Change CATALINA_OPTS to use same for RMI as for JMX
    c. What ports are used by the java process?
7. Rerun tomcat with min heap size 10M and max heap size 20M.
    a. What type of error will you get?
    b. Increase min heap size to 1G and max heap size to 3G, enable parallel garbage collector.
8. Connect by JConsole to Tomcat and look around.
9. Stop Tomcat.
10. Launch Jenkins WAR as a standalone application, verify that it works.

## Steps

1) Download/install Tomcat server. <br/>
    I have downloaded the tar.gz of Tomcat 10 and installed that.
2) Verify that it works by visiting the root page. <br/>
    I have started the Tomcat with the startup.sh script.
    <br/>
    <img width="1320" alt="Screenshot 2025-01-08 at 11 54 20" src="https://github.com/user-attachments/assets/cc5920dc-e0ed-4a6d-b8b5-19c9a9599d77" />
    <br/>
    a. What ports are used by the java process?
    <br/>
    <img width="1512" alt="Screenshot 2025-01-07 at 10 00 48" src="https://github.com/user-attachments/assets/234ab9bc-2010-4a6e-828b-03fecaf8c78a" />
3) Remove all default applications (including manager), restart Tomcat.
    <br/>
    <img width="735" alt="Screenshot 2025-01-07 at 10 03 48" src="https://github.com/user-attachments/assets/cd663fe4-b612-4463-afb7-cf8003892d53" />
    <br/>
    For restarting tomcat(in bin directory): 
    `` sh shutdown.sh && sh startup.sh ``
4) Download Jenkins WAR and deploy into Tomcat.
    <br/>
    Downloaded Jenkins WAR from Jenkins site, moved that to apache-tomcat-10.1.34/webapps
    <img width="344" alt="Screenshot 2025-01-07 at 10 13 50" src="https://github.com/user-attachments/assets/746ee9ab-dbfb-4943-ad90-158b94cd7f9a" />
5) Verify that application works (visit application URL).
    <br/>
    Starting Tomcat and visiting localhost:8080/jenkins
    <br/>
    <img width="1505" alt="Screenshot 2025-01-07 at 10 14 38" src="https://github.com/user-attachments/assets/d7e91189-0f6c-47af-9de1-297ad90ca015" />

## Not sure in this steps
6) Enable JMX in Tomcat.
    <br/>
    For this point I have created setenv.sh file:
    `` vim setenv.sh && chmod 755 setenv.sh ``
    The content of the file:
    ```
    #!/bin/sh

    CATALINA_OPTS="-Dcom.sun.management.jmxremote \
    -Dcom.sun.management.jmxremote.port=9000 \
    -Dcom.sun.management.jmxremote.ssl=false \
    -Dcom.sun.management.jmxremote.authenticate=false \ 
    ```

    With this we setting the port for jmx to 9000 and disabling ssl and authentication.
    (I've used this documentation https://geekflare.com/dev/enable-jmx-tomcat-to-monitor-administer/)
    
    <br/>
    And then opened Monitoring and Managment console, using `` .jconsole.sh `` in java.
    <img width="891" alt="Screenshot 2025-01-07 at 10 46 52" src="https://github.com/user-attachments/assets/abf932c9-ca4f-4a25-8a0f-1abc2e2cecdf" />
    <br/>
    Connected with remote process using my localhost:9000
    <img width="894" alt="Screenshot 2025-01-07 at 10 59 47" src="https://github.com/user-attachments/assets/7f93eb65-defb-4ca6-bc68-1cacf7a37970" />
    <br/>
    a. What ports are used by the java process?
    <img width="1263" alt="Screenshot 2025-01-07 at 11 18 41" src="https://github.com/user-attachments/assets/bd1a97c1-9ea0-4be4-96d5-0ab714f3d5aa" />
    <br/>
    b. Change CATALINA_OPTS to use same for RMI as for JMX
    <br/>
    c. What ports are used by the java process?
    <br/>
    Added following to my setenv.sh 

    ```
    -Djava.rmi.server.hostname=localhost \
    -Dcom.sun.management.jmxremote.rmi.port=9000"
    ```

    <br/>
    <img width="1512" alt="Screenshot 2025-01-07 at 11 55 28" src="https://github.com/user-attachments/assets/7f780db0-fb2b-41e8-a60a-6a2bc0e7eebe" />

7. Rerun tomcat with min heap size 10M and max heap size 20M.
    <br/>
    Added following to my setenv.sh

        CATALINA_OPTS="$CATALINA_OPTS -Xms10m"
        CATALINA_OPTS="$CATALINA_OPTS -Xmx20m"
        export CATALINA_OPTS


    <br/>
    a. What type of error will you get?
    <br/>
    -I dont see any errors
    <br/>
    b. Increase min heap size to 1G and max heap size to 3G, enable parallel garbage collector.
    <br/>
    My setenv.sh:
    
    ```
    #!/bin/sh

    CATALINA_OPTS="-Dcom.sun.management.jmxremote \
    -Dcom.sun.management.jmxremote.port=9000 \
    -Dcom.sun.management.jmxremote.ssl=false \
    -Dcom.sun.management.jmxremote.authenticate=false \
    -Djava.rmi.server.hostname=localhost \
    -Dcom.sun.management.jmxremote.rmi.port=9000"

    CATALINA_OPTS="$CATALINA_OPTS -Xms1g"
    CATALINA_OPTS="$CATALINA_OPTS -Xmx3g"
    CATALINA_OPTS="$CATALINA_OPTS -XX:+UseParallelGC"
    export CATALINA_OPTS 
    ```

8. Connect by JConsole to Tomcat and look around.
    <img width="883" alt="Screenshot 2025-01-07 at 12 25 56" src="https://github.com/user-attachments/assets/459a4fdf-0f1c-4c2f-a55d-bd609f0a8ae4" />
    <br/>
    The Garbage collector: 
    <img width="877" alt="Screenshot 2025-01-07 at 12 25 24" src="https://github.com/user-attachments/assets/e5ca3a5a-58e6-4f82-8145-dab6403d31f7" />

## No problem with this part
10. Launch Jenkins WAR as a standalone application, verify that it works.
    </br>
    <img width="1263" alt="Screenshot 2025-01-07 at 12 41 09" src="https://github.com/user-attachments/assets/c01fad83-3eed-494a-b2f8-5a3cc175d69b" />









