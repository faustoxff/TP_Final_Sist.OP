#!/bin/bash

# Variables de configuración
LOCAL_DIR="/ruta/local/de/archivos"    # Cambia esta ruta por el directorio local
REMOTE_USER="usuario_remoto"           # Cambia por el nombre de usuario en el servidor remoto
REMOTE_HOST="servidor_remoto.com"      # Cambia por la dirección del servidor remoto
REMOTE_DIR="/ruta/remota/de/archivos"  # Cambia por la ruta del directorio remoto
LOG_FILE="registro_actualizaciones.log"

# Códigos de colores
COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_RED="\e[31m"
COLOR_YELLOW="\e[33m"
COLOR_BLUE="\e[34m"
COLOR_CYAN="\e[36m"

# Función para limpiar archivos temporales
limpiar_archivos() {
    echo -e "${COLOR_YELLOW}Limpiando archivos temporales...${COLOR_RESET}" | tee -a "$LOG_FILE"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo -e "${COLOR_YELLOW}Eliminando archivos en %TEMP%${COLOR_RESET}" | tee -a "$LOG_FILE"
        rm -rf "/c/Users/$USER/AppData/Local/Temp/*"
    else
        sudo rm -rf /tmp/* | tee -a "$LOG_FILE"
        sudo apt-get clean | tee -a "$LOG_FILE"
    fi
    echo -e "${COLOR_GREEN}Limpieza completada.${COLOR_RESET}" | tee -a "$LOG_FILE"
}

# Función para verificar e instalar actualizaciones
verificar_e_instalar_actualizaciones() {
    echo -e "${COLOR_YELLOW}Verificando e instalando actualizaciones...${COLOR_RESET}" | tee -a "$LOG_FILE"

    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        if ! command -v winget &> /dev/null; then
            echo -e "${COLOR_RED}winget no está disponible en este sistema.${COLOR_RESET}" | tee -a "$LOG_FILE"
            return
        fi
        echo -e "${COLOR_BLUE}Actualizando sistema en Windows...${COLOR_RESET}" | tee -a "$LOG_FILE"
        echo -e "${COLOR_BLUE}Presiona Y para continuar con la actualización (Y/N):${COLOR_RESET}"
        read -r respuesta
        if [[ "$respuesta" == "Y" || "$respuesta" == "y" ]]; then
            winget upgrade --all | tee -a "$LOG_FILE"
        else
            echo -e "${COLOR_RED}Actualización cancelada por el usuario.${COLOR_RESET}" | tee -a "$LOG_FILE"
        fi
    else
        echo -e "${COLOR_BLUE}Actualizando sistema en Linux...${COLOR_RESET}" | tee -a "$LOG_FILE"
        echo -e "${COLOR_BLUE}Presiona Y para continuar con la actualización (Y/N):${COLOR_RESET}"
        read -r respuesta
        if [[ "$respuesta" == "Y" || "$respuesta" == "y" ]]; then
            sudo apt-get update | tee -a "$LOG_FILE"
            sudo apt-get upgrade -y | tee -a "$LOG_FILE"
        else
            echo -e "${COLOR_RED}Actualización cancelada por el usuario.${COLOR_RESET}" | tee -a "$LOG_FILE"
        fi
    fi

    echo -e "${COLOR_GREEN}Actualización completada.${COLOR_RESET}" | tee -a "$LOG_FILE"
}

# Función para sincronizar archivos con robocopy (Windows) o rsync (Linux)
sincronizar_archivos() {
    echo -e "${COLOR_YELLOW}Sincronizando archivos...${COLOR_RESET}" | tee -a "$LOG_FILE"

    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        if ! command -v robocopy &> /dev/null; then
            echo -e "${COLOR_RED}robocopy no está disponible en este sistema.${COLOR_RESET}" | tee -a "$LOG_FILE"
            return
        fi
        DESTINO="C:/ruta/del/destino"  # Cambia esto a una ruta válida
        echo -e "${COLOR_BLUE}Sincronizando archivos a $DESTINO...${COLOR_RESET}" | tee -a "$LOG_FILE"
        
        # Redirigir stderr a /dev/null para ocultar mensajes de error
        robocopy "$LOCAL_DIR" "$DESTINO" /MIR 2>/dev/null | tee -a "$LOG_FILE"
        if [ $? -eq 0 ]; then
            echo -e "${COLOR_GREEN}¡Sincronización completada con éxito en Windows!${COLOR_RESET}" | tee -a "$LOG_FILE"
        else
            echo -e "${COLOR_RED}Error en la sincronización en Windows.${COLOR_RESET}" | tee -a "$LOG_FILE"
        fi
    else
        if command -v rsync &> /dev/null; then
            rsync -avz --delete "$LOCAL_DIR/" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" | tee -a "$LOG_FILE"
            if [ $? -eq 0 ]; then
                echo -e "${COLOR_GREEN}¡Sincronización completada con éxito en Linux!${COLOR_RESET}" | tee -a "$LOG_FILE"
            else
                echo -e "${COLOR_RED}Error en la sincronización en Linux.${COLOR_RESET}" | tee -a "$LOG_FILE"
            fi
        else
            echo -e "${COLOR_RED}rsync no está disponible en este sistema. Instálalo para sincronizar archivos.${COLOR_RESET}" | tee -a "$LOG_FILE"
        fi
    fi
}

# Menú interactivo
while true; do
    echo -e "${COLOR_CYAN}---------------------------------------${COLOR_RESET}" | tee -a "$LOG_FILE"
    echo -e "${COLOR_CYAN}        Menú de Opciones${COLOR_RESET}" | tee -a "$LOG_FILE"
    echo -e "${COLOR_CYAN}---------------------------------------${COLOR_RESET}" | tee -a "$LOG_FILE"
    echo -e "${COLOR_GREEN}1. Limpiar archivos temporales y caché${COLOR_RESET}" | tee -a "$LOG_FILE"
    echo -e "${COLOR_GREEN}2. Verificar e instalar actualizaciones del sistema${COLOR_RESET}" | tee -a "$LOG_FILE"
    echo -e "${COLOR_GREEN}3. Sincronizar archivos con servidor remoto${COLOR_RESET}" | tee -a "$LOG_FILE"
    echo -e "${COLOR_GREEN}4. Salir${COLOR_RESET}" | tee -a "$LOG_FILE"
    echo -e "${COLOR_CYAN}---------------------------------------${COLOR_RESET}" | tee -a "$LOG_FILE"
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) limpiar_archivos ;;
        2) verificar_e_instalar_actualizaciones ;;
        3) sincronizar_archivos ;;
        4) echo -e "${COLOR_YELLOW}Saliendo...${COLOR_RESET}" | tee -a "$LOG_FILE"; exit 0 ;;
        *) echo -e "${COLOR_RED}Opción no válida, por favor intenta nuevamente.${COLOR_RESET}" | tee -a "$LOG_FILE" ;;
    esac
done
