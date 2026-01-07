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
  echo -e "\t${blueColour}[i]${endColour} ${redColour}-m${endColour} ${blueColour}<nombre>\t\t${endColour} ${grayColour}Busca por nombre de maquinas en [https://htbmachines.github.io/]${endColour}"
  echo -e "\t${blueColour}[i]${endColour} ${redColour}-i${endColour} ${blueColour}<direccion-ip>\t${endColour} ${grayColour}Busca por direccion IP de maquinas en [https://htbmachines.github.io/]${endColour}"
  echo -e "\t${blueColour}[i]${endColour} ${redColour}-y${endColour} ${blueColour}<nombre>\t\t${endColour} ${grayColour}Busca por nombre la resolucion de la maquina en YouTube en [https://htbmachines.github.io/]${endColour}"
  echo -e "\t${blueColour}[i]${endColour} ${redColour}-d${endColour} ${blueColour}<1-4>\t\t${endColour} ${grayColour}Busca por dificultad ( 1: Fácil | 2: Media | 3: Difícil | 4: Insane ) en [https://htbmachines.github.io/]${endColour}"
  echo -e "\t${blueColour}[i]${endColour} ${redColour}-s${endColour} ${blueColour}<1-2>\t\t${endColour} ${grayColour}Busca por sistema operativo ( 1: Linux | 2: Windows ) en [https://htbmachines.github.io/]${endColour}"
  echo -e "\t${blueColour}[i]${endColour} ${redColour}-c${endColour} ${blueColour}<1-11>\t\t${endColour} ${grayColour}Busca por certificaciones ( utilizar '0' para saber mas ) en [https://htbmachines.github.io/]${endColour}\n"
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
  machineName="$1"
  echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina:${endColour} ${yellowColour}$machineName${endColour}\n"
  machine=$(cat bundle.js |awk "/name: \"$machineName\"/,/resuelta:/" |grep -Ev "id:|sku:|resuelta:" |tr -d '"' |tr -d ',' |sed 's/^ *//')
  if [ $machine ]; then
    cat bundle.js |awk "/name: \"$machineName\"/,/resuelta:/" |grep -Ev "id:|sku:|resuelta:" |tr -d '"' |tr -d ',' |sed 's/^ *//'
  else
    echo -e "${redColour}[-]${endColour} ${grayColour}La maquina${endColour} ${greenColour}$machineName${endColour} ${grayColour}no existe en la base de datos${endColour}"
  fi
  echo -e ""
}

# Funcion para buscar maquinas por direccion IP
function searchIpAddress () {
  ipAddress=$1
  echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina con IP:${endColour} ${greenColour}$ipAddress${endColour}"
  machineName="$(cat bundle.js |grep "ip: \"$ipAddress\"" -B 3 |grep "name" |awk 'NF{print $NF}' |tr -d '",')"
  if [ $machineName ]; then
    echo -e "${greenColour}[+]${endColour} ${grayColour}Maqina con nombre:${endColour} ${greenColour}$machineName${endColour}"
    searchMachine $machineName
  else
    echo -e "${redColour}[-]${endColour} ${grayColour}La maquina con IP${endColour} ${greenColour}$ipAddress${endColour} ${grayColour}no existe en la base de datos${endColour}\n"
  fi
}

# Funcion para ver el link de youtube de una Maquina 
function searchYouTubeVideo () {
  machineName="$1"
  echo -e "\n${greenColour}[+]${endColour} ${grayColour}Obteniendo link de YouTube de la maquina ${yellowColour}$machineName${endColour} ${grayColour}resuelta.${endColour}"
  youtubeLink="$(cat bundle.js |awk "/name: \"$machineName\"/,/resuelta:/" |grep -Ev "id:|sku:|resuelta:" |tr -d '"' |tr -d ',' |sed 's/^ *//' |grep youtube |awk 'NF {print $NF}')"
  if [ $youtubeLink ]; then
    echo -e "${greenColour}[+]${endColour} ${grayColour}Link de YouTube:${endColour} ${greenColour}$youtubeLink${endColour}\n"
  else
    echo -e "${redColour}[-]${endColour} ${grayColour}La maquina${endColour} ${greenColour}$machineName${endColour} ${grayColour}no existe en la base de datos${endColour}\n"
  fi
}

# Funcion para buscar nombres de maquina por dificultad
function searchMachineByDifficulty () {
  difficulty=$1
  if [ $difficulty -eq 1 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas con dificultad${endColour} ${greenColour}Fácil${endColour}\n"
    cat bundle.js |grep 'dificultad: "Fácil"' -B 5 |grep 'name: ' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $difficulty -eq 2 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas con dificultad${endColour} ${greenColour}Media${endColour}\n"
    cat bundle.js |grep 'dificultad: "Media"' -B 5 |grep 'name: ' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $difficulty -eq 3 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas con dificultad${endColour} ${greenColour}Difícil${endColour}\n"
    cat bundle.js |grep 'dificultad: "Difícil"' -B 5 |grep 'name: ' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $difficulty -eq 4 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas con dificultad${endColour} ${greenColour}Insane${endColour}\n"
    cat bundle.js |grep 'dificultad: "Insane"' -B 5 |grep 'name: ' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}Opción inválida. Las opciones permitidas son:${endColour}\n"
    echo -e "\t${greenColour}1${endColour}${grayColour}: Maquinas faciles${endColour}"
    echo -e "\t${greenColour}2${endColour}${grayColour}: Maquinas medias${endColour}"
    echo -e "\t${greenColour}3${endColour}${grayColour}: Maquinas dificiles${endColour}"
    echo -e "\t${greenColour}4${endColour}${grayColour}: Maquinas insane${endColour}\n"
  fi
}

# Funcion para buscar nombres de maquinas por sistema operativo
function searchMachineByOperatingSystem () {
  operatingSystem=$1
  if [ $operatingSystem -eq 1 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas por sistema operativo${endColour} ${yellowColour}Linux${endColour}\n"
    cat bundle.js |grep 'so: "Linux"' -B 4 |grep 'name: ' |tr -s 's/ *//' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $operatingSystem -eq 2 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas por sistema operativo${endColour} ${yellowColour}Windows${endColour}\n"
    cat bundle.js |grep 'so: "Windows"' -B 4 |grep 'name: ' |tr -s 's/ *//' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  else
    echo -e "\n${redColour}[!]${endColour} ${yellowColour}Opción Inválida.${endColour} ${grayColour}Los argumentos aceptados son:${endColour}\n"
    echo -e "\t${greenColour}1${endColour}${grayColour}: Sistemas Linux${endColour}"
    echo -e "\t${greenColour}2${endColour}${grayColour}: Sistemas Windows${endColour}"
  fi
}

# Funcion para buscar nombres de maquinas por dificultad y sistema operativo
function searchMachineByDifficultyAndOperatingSystem () {
  difficulty=$1
  operatingSystem=$2
  if [ $difficulty -eq 1 ] && [ $operatingSystem -eq 1 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas${endColour} ${yellowColour}linux${endColour} ${grayColour}con dificultad${endColour} ${yellowColour}fácil${endColour}\n"
    cat bundle.js |grep 'so: "Linux"' -B 4 -A 1 |grep 'dificultad: "Fácil"' -B 5 |grep "name:" |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $difficulty -eq 2 ] && [ $operatingSystem -eq 1 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas${endColour} ${yellowColour}linux${endColour} ${grayColour}con dificultad${endColour} ${yellowColour}media${endColour}\n"
    cat bundle.js |grep 'so: "Linux"' -B 4 -A 1 |grep 'dificultad: "Media"' -B 5 |grep "name:" |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $difficulty -eq 3 ] && [ $operatingSystem -eq 1 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas${endColour} ${yellowColour}linux${endColour} ${grayColour}con dificultad${endColour} ${yellowColour}difícil${endColour}\n"
    cat bundle.js |grep 'so: "Linux"' -B 4 -A 1 |grep 'dificultad: "Difícil"' -B 5 |grep "name:" |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $difficulty -eq 4 ] && [ $operatingSystem -eq 1 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas${endColour} ${yellowColour}linux${endColour} ${grayColour}con dificultad${endColour} ${yellowColour}insane${endColour}\n"
    cat bundle.js |grep 'so: "Linux"' -B 4 -A 1 |grep 'dificultad: "Insane"' -B 5 |grep "name:" |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $difficulty -eq 1 ] && [ $operatingSystem -eq 2 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas${endColour} ${yellowColour}windows${endColour} ${grayColour}con dificultad${endColour} ${yellowColour}fácil${endColour}\n"
    cat bundle.js |grep 'so: "Windows"' -B 4 -A 1 |grep 'dificultad: "Fácil"' -B 5 |grep "name:" |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $difficulty -eq 2 ] && [ $operatingSystem -eq 2 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas${endColour} ${yellowColour}windows${endColour} ${grayColour}con dificultad${endColour} ${yellowColour}media${endColour}\n"
    cat bundle.js |grep 'so: "Windows"' -B 4 -A 1 |grep 'dificultad: "Media"' -B 5 |grep "name:" |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $difficulty -eq 3 ] && [ $operatingSystem -eq 2 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas${endColour} ${yellowColour}windows${endColour} ${grayColour}con dificultad${endColour} ${yellowColour}difícil${endColour}\n"
    cat bundle.js |grep 'so: "Windows"' -B 4 -A 1 |grep 'dificultad: "Difícil"' -B 5 |grep "name:" |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $difficulty -eq 4 ] && [ $operatingSystem -eq 2 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquinas${endColour} ${yellowColour}windows${endColour} ${grayColour}con dificultad${endColour} ${yellowColour}insane${endColour}\n"
    cat bundle.js |grep 'so: "Windows"' -B 4 -A 1 |grep 'dificultad: "Insane"' -B 5 |grep "name:" |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  else
    echo -e "\n${redColour}[!]${endColour} ${yellowColour}Opción Inválida.${endColour} ${grayColour}Los argumentos aceptados son:${endColour}\n"
    echo -e "\t${yellowColour}[i]${endColour} ${greenColour}-d${endColour}"
    echo -e "\t\t${greenColour}1${endColour}${grayColour}: Maquinas faciles${endColour}"
    echo -e "\t\t${greenColour}2${endColour}${grayColour}: Maquinas medias${endColour}"
    echo -e "\t\t${greenColour}3${endColour}${grayColour}: Maquinas dificiles${endColour}"
    echo -e "\t\t${greenColour}4${endColour}${grayColour}: Maquinas insane${endColour}\n"
    echo -e "\t${yellowColour}[i]${endColour} ${greenColour}-s${endColour}\n"
    echo -e "\t\t${greenColour}1${endColour}${grayColour}: Sistemas Linux${endColour}"
    echo -e "\t\t${greenColour}2${endColour}${grayColour}: Sistemas Windows${endColour}\n"
  fi
}

# Funcion para buscar maquinas por certificaciones
function searchMachineByCertification () {
  certification="$1"
  if [ $certification -eq 1 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}eCPPTv2${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'eCPPTv2' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 2 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}eCPTXv2${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'eCPTXv2' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 3 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}eJPT${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'eJPT' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 4 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}eWPT${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'eWPT' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 5 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}eWPTXv2${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'eWPTXv2' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 6 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}OSCP${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'OSCP' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 7 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}OSWE${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'OSWE' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 8 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}OSEP${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'OSEP' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 9 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}OSED${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'OSED' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 10 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}Active Directory${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'Active Directory' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 11 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Buscando maquina que contengan parecido con la certificacion${endColour} ${yellowColour}Buffer Overflow${endColour}\n"
    cat bundle.js |grep 'like: ' -B 7 |grep 'Buffer Overflow' -C 7 |grep 'name:' |awk 'NF {print $NF}' |tr -d '",' |column
    echo ""
  elif [ $certification -eq 0 ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Los argumentos aceptados son:${endColour}\n"
    echo -e "\t${greenColour}1${endColour}${grayColour}:${endColour} ${yellowColour}eCPPTv2${endColour}"
    echo -e "\t${greenColour}2${endColour}${grayColour}:${endColour} ${yellowColour}eCPTXv2${endColour}"
    echo -e "\t${greenColour}3${endColour}${grayColour}:${endColour} ${yellowColour}eJPT${endColour}"
    echo -e "\t${greenColour}4${endColour}${grayColour}:${endColour} ${yellowColour}eWPT${endColour}"
    echo -e "\t${greenColour}5${endColour}${grayColour}:${endColour} ${yellowColour}eWPTXv2${endColour}"
    echo -e "\t${greenColour}6${endColour}${grayColour}:${endColour} ${yellowColour}OSCP${endColour}"
    echo -e "\t${greenColour}7${endColour}${grayColour}:${endColour} ${yellowColour}OSWE${endColour}"
    echo -e "\t${greenColour}8${endColour}${grayColour}:${endColour} ${yellowColour}OSEP${endColour}"
    echo -e "\t${greenColour}9${endColour}${grayColour}:${endColour} ${yellowColour}OSED${endColour}"
    echo -e "\t${greenColour}10${endColour}${grayColour}:${endColour} ${yellowColour}Active Directory${endColour}"
    echo -e "\t${greenColour}11${endColour}${grayColour}:${endColour} ${yellowColour}Buffer Overflow${endColour}\n"
  else
    echo -e "\n${redColour}[!] Opción invalida.${endColour} ${grayColour}Los argumentos aceptados son:${endColour}\n"
    echo -e "\t${greenColour}1${endColour}${grayColour}:${endColour} ${yellowColour}eCPPTv2${endColour}"
    echo -e "\t${greenColour}2${endColour}${grayColour}:${endColour} ${yellowColour}eCPTXv2${endColour}"
    echo -e "\t${greenColour}3${endColour}${grayColour}:${endColour} ${yellowColour}eJPT${endColour}"
    echo -e "\t${greenColour}4${endColour}${grayColour}:${endColour} ${yellowColour}eWPT${endColour}"
    echo -e "\t${greenColour}5${endColour}${grayColour}:${endColour} ${yellowColour}eWPTXv2${endColour}"
    echo -e "\t${greenColour}6${endColour}${grayColour}:${endColour} ${yellowColour}OSCP${endColour}"
    echo -e "\t${greenColour}7${endColour}${grayColour}:${endColour} ${yellowColour}OSWE${endColour}"
    echo -e "\t${greenColour}8${endColour}${grayColour}:${endColour} ${yellowColour}OSEP${endColour}"
    echo -e "\t${greenColour}9${endColour}${grayColour}:${endColour} ${yellowColour}OSED${endColour}"
    echo -e "\t${greenColour}10${endColour}${grayColour}:${endColour} ${yellowColour}Active Directory${endColour}"
    echo -e "\t${greenColour}11${endColour}${grayColour}:${endColour} ${yellowColour}Buffer Overflow${endColour}\n"
  fi
}

# Indicador de parametros
declare -i parameter_counter=0
declare -i parameter_difficulty=0
declare -i parameter_operatingSystem=0

# Asignacion de parametros
while getopts "m:ui:y:d:s:c:h" arg; do
  case $arg in
    h) ;;
    u) let parameter_counter+=1;;
    m) machineName=$OPTARG; let parameter_counter+=2;;
    i) ipAddress=$OPTARG; let parameter_counter+=3;;
    y) machineName=$OPTARG; let parameter_counter+=4;;
    d) difficulty=$OPTARG; parameter_difficulty=1; let parameter_counter+=5;;
    s) operatingSystem=$OPTARG; parameter_operatingSystem=1; let parameter_counter+=6;;
    c) certification=$OPTARG; parameter_counter+=7;;
  esac
done

# Condicional para los parametros
if [ $parameter_counter -eq 1 ]; then
  updateFiles
elif [ $parameter_counter -eq 2 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 3 ]; then
  searchIpAddress $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  searchYouTubeVideo $machineName
elif [ $parameter_counter -eq 5 ]; then
  searchMachineByDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  searchMachineByOperatingSystem $operatingSystem
elif [ $parameter_counter -eq 7 ]; then
  searchMachineByCertification $certification
elif [ $parameter_difficulty -eq 1 ] && [ $parameter_operatingSystem -eq 1 ]; then
  searchMachineByDifficultyAndOperatingSystem $difficulty $operatingSystem
else
  helpPanel
fi

