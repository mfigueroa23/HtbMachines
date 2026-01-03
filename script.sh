#!/bin/bash 

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
function ctrl_c() {
  echo -e "\n\n${redColour}[i] Saliendo...${endColour}\n"
  tput cnorm; exit 1
}

# Crtl + C 
trap ctrl_c INT

# Funcion para el panel de ayuda
function helpPanel() {
  echo -e "\n[+] Uso:"
}

# Funcion para buscar maquinas
function searchMachine() {
  machine="$1"
  echo -e "\n[+] Buscando maquina: $machine"
}

# Indicador de parametros
declare -i parameter_counter=0

# Asignacion de parametros
while getopts "m:h" arg in; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
    h) helpPanel;;
  esac
done

# Condicional para los parametros
if [ $parameter_counter == 1 ]; then
  searchMachine $machineName
else
  helpPanel
fi

