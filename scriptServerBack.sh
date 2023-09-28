#########################Update Operative System#############################################
apt-get update -y
########################### Validate App ####################################################
## awk = nos permite seleccionar una columna determinada y mostrarla en pantala
## dpkg = es el paquete de las aplicaciones 
## wc -l = wc -l le dice a wc que cuente el número de líneas. Así es como se deduce el número total de palabras coincidentes
for app in nodejs npm 
do
if [ "$(dpkg -l | awk '/'$app'/ {print }'|wc -l)" -ge 1 ]; then
echo Instalado
else
echo No instalado
snap install node --classic
fi
done
########################### Instalacion de Express y repositorio clonado ###############################################
## validar si esta creada la carpeta ##
dir=$(ls /opt/app | grep "movie-analyst-api")
if ["$dir"== "movie-analyst-api"]; then
echo" Ya existe la carpeta movie-analyst-api "
else
mkdir /opt/app
cd /opt/app
git clone https://github.com/juan-ruiz/movie-analyst-api.git
cd movie-analyst-api
npm install express --save
echo " La carpeta fue creada, clonada e instalado express"
fi
############################################# Ejecucion de server.js #####################################################
mkdir /opt/app/scripts
cd /opt/app/scripts
touch server.sh
echo "PORT=3000 node /opt/app/movie-analyst-api/server.js" >> /opt/app/scripts/server.sh
chmod +x /opt/app/scripts/server.sh

############################################ creacion del servicio #######################################################

dir2=$(ls /etc/systemd/system/ | grep "serverjs.service")
if ["$dir2"== "serverjs.service"]; then
echo "Ya existe el servicio"
else
cd /etc/systemd/system/
touch serverjs.service
cat <<EOT >> serverjs.service
[Unit]
Description=Servicio serverjs
After=network.target
[Service]
User=root
ExecStart=/bin/bash -c /opt/app/scripts/server.sh
Restart=on-failure
RestartSec=5s
[Install]
WantedBy=multi-user.target

EOT
############################################ creacion del daemon #######################################################
systemctl daemon-reload
systemctl enable serverjs.service
systemctl start serverjs.service
fi








