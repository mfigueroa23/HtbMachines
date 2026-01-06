#!/bin/bash 

# PAQUETES NECESARIOS
# 1) js-beautify
# 2) sponge

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Funcion de salida Ctrl + C
function ctrl_c () {
  echo -e "\n\n${redColour}[i] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# Crtl + C 
trap ctrl_c INT

# Variables
main_url="https://htbmachines.github.io/bundle.js"

# Funcion para el panel de ayuda
function helpPanel () {
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Para el correcto uso del script puedes proporcinar estos parametros:${endColour}\n"
  echo -e "\t${blueColour}[i]${endColour} ${redColour}-h\t\t\t${endColour} ${grayColour}Mostrar panel de ayuda${endColour}"
  echo -e "\t${blueColour}[i]${endColour} ${redColour}-u\t\t\t${endColour} ${grayColour}Actualiza archivos locales de busqueda desde [https://htbmachines.github.io/]${endColour}"
  echo -e "\t${blueColour}[i]${endColour} ${redColour}-m <nombre>\t\t${endColour} ${grayColour}Busca por nombre de maquinas en [https://htbmachines.github.io/]${endColour}"
  echo -e "\t${blueColour}[i]${endColour} ${redColour}-i <direccion-ip>\t${endColour} ${grayColour}Busca por direccion IP de maquinas en [https://htbmachines.github.io/]${endColour}\n"
}

# Funcion de actualizacion 
function updateFiles () {
  tput civis
  echo -e "\n${greenColour}[+]${endColour} ${grayColour}Actualizando base de archivos...${endColour}\n"
  if [ ! -f bundle.js ]; then
    echo -e "${redColour}[i]${endColour} ${yellowColour}El archivo bundle.js no existe${endColour}"
    echo -e "${greenColour}[i]${endColour} ${grayColour}Comenzando descarga...${endColour}\n"
    curl -s -X GET $main_url > bundle.js
    js-beautify bundle.js |sponge bundle.js
    echo -e "${greenColour}[i]${endColour} ${greenColour}Descarga completada${endColour}\n"
  else
    echo -e "${redColour}[i]${endColour} ${yellowColour}El archivo bundle.js existe${endColour}" 
    echo -e "${greenColour}[i]${endColour} ${grayColour}Comparando cambios...${endColour}"
    curl -s -X GET $main_url > bundle.tmp.js
    js-beautify bundle.tmp.js |sponge bundle.tmp.js
    echo -e "${greenColour}[i]${endColour} ${grayColour}Comparando Hash MD5...${endColour}\n"
    md5TempHash=$(md5sum bundle.tmp.js |awk '{print $1}')
    md5LocalHash=$(md5sum bundle.js |awk '{print $1}')
    if [ "$md5LocalHash" = "$md5TempHash" ]; then
      echo -e "${greenColour}[i]${endColour} ${greenColour}No hay actualizaciones${endColour}\n"
      rm ./bundle.tmp.js
    else
      echo -e "${greenColour}[i]${endColour} ${grayColour}Hay actualizaciones pendientes${endColour}"
      echo -e "${greenColour}[i]${endColour} ${grayColour}Actualizando archivo...${endColour}\n"
      rm ./bundle.js && mv ./bundle.tmp.js ./bundle.js
      echo -e "${greenColour}[i]${endColour} ${greenColour}Actualizacion completada${endColour}\n"
    fi
  fi
  tput cnorm
}

# Funcion para buscar maquinas por nombre
function searchMachine () {
  machine="$1"
  echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina:${endColour} ${yellowColour}$machine${endColour}\n"
  cat bundle.js |awk "/name: \"$machine\"/,/resuelta:/" |grep -Ev "id:|sku:|resuelta:" |tr -d '"' |tr -d ',' |sed 's/^ *//'
  echo -e ""
}

# Funcion para buscar maquinas por direccion IP
function searchIpAddress () {
  ipAdress=$1
  echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina con IP:${endColour} ${greenColour}$ipAdress${endColour}"
  machineName="$(cat bundle.js |grep "ip: \"$ipAdress\"" -B 3 |grep "name" |awk 'NF{print $NF}' |tr -d '",')"
  echo -e "${greenColour}[+]${endColour} ${grayColour}Maqina con nombre:${endColour} ${greenColour}$machineName${endColour}"
  searchMachine $machineName
}

# Indicador de parametros
declare -i parameter_counter=0

# Asignacion de parametros
while getopts "m:ui:h" arg; do
  case $arg in
    h) ;;
    u) let parameter_counter+=1;;
    m) machineName=$OPTARG; let parameter_counter+=2;;
    i) ipAdress=$OPTARG; let parameter_counter+=3;;
  esac
done

# Condicional para los parametros
if [ $parameter_counter -eq 1 ]; then
  updateFiles
elif [ $parameter_counter -eq 2 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 3 ]; then
  searchIpAddress $ipAdress
else
  helpPanel
fi

