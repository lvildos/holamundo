#!/bin/bash


#STEP 1

# Crear usuario Tomcat
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# Refrescar la memoria caché del gestor de paquetes y realizar la instalación del Kit de Desarrollo de Java (JDK).
sudo apt update
sudo apt install -y openjdk-17-jdk

# Descargar e instalar Tomcat
Version="10.1.18"
sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v${Version}/bin/apache-tomcat-${Version}.tar.gz -P /tmp
sudo tar xzvf /tmp/apache-tomcat-${Version}.tar.gz -C /opt/tomcat --strip-components=1

# Configuramos los permisos
sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R u+x /opt/tomcat/bin

#STEP 2

# Configurar usuarios administradores en tomcat-users.xml
cat <<EOF | sudo tee -a /opt/tomcat/conf/tomcat-users.xml
<tomcat-users>
    <role rolename="manager-gui"/>
    <user username="manager" password='user1' roles="manager-gui"/>
    <role rolename="admin-gui" />
    <user username="admin" password='admin1' roles="manager-gui,admin-gui" />
</tomcat-users>
EOF

# Eliminar restricciones a los administradores en manager/context.xml
archivo="/opt/tomcat/webapps/manager/META-INF/context.xml"
sudo sed -i '/<Valve/,/<\/Valve>/ s/^/<!-- /; s/$/ -->/' "$archivo"

# Eliminar restricciones a los administradores en host-manager/context.xml
archivo="/opt/tomcat/webapps/host-manager/META-INF/context.xml"
sudo sed -i '/<Valve/,/<\/Valve>/ s/^/<!-- /; s/$/ -->/' "$archivo"

#STEP 3

# Capturar la ruta del archivo a partir de sudo update-java-alternatives -l y almacenarla en java_home
java_home=$(sudo update-java-alternatives -l | awk '{print $3}')

# Configurar el servicio systemd en /etc/systemd/system/tomcat.service
cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=$java_home"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Recargamos, reiniciamos, permitimos que se inicie con el sistema y permitimos el tráfico al puerto 8080
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat

#STEP 4


sudo ufw allow 8080
