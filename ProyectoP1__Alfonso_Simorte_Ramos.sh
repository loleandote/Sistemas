#!/bin/bash
shopt -s dotglob #recuperar ocultos
suma=0
###################Mostrar error y forzar salida################
function mostrarError() {
    echo "ERROR. Modo de empleo: midu [opciones] [camino1 camino2 camino3 ...]"
    exit 1
}
#######################Funcion recursiva#######################
function computingSize() {
        if [ -d "$5" ]
        then
            local camino
            for camino in $5/*
            do
                if [ "$4" -eq 0 ] || [[ ! "$camino" == *"$3"* ]] #Comprueba que el parametro --exclude no se ha introducido y en caso de ser asi lo compara con la ruta del directorio
                then
                    if [ -d $camino ]
                    then	
                        local temp=$suma
                        suma=0
                        computingSize $1 $2 $3 $excluido $camino $(expr $6 + 1) #Se le pasa el valor de las opciones
                        if [ $2 -eq -99999 ] #Comprueba que la variable "OPTION_S" no se modificado y si es asi muestra el tamaño de los directorios 
                        then
                            if [ $1 -le 0 ] || [ $6 -le "$1" ] #Comprueba si se ha introducido una profundidad, 
                            then                                #en caso de ser asi,
                                echo $suma $camino              #comprueba que el la profuncidad del directorio sea menor que el valor de la variable "OPTION_D" en caso contrario no muestra el tamaño del directorio
                            fi
                        fi
                        suma=$(expr $suma + $temp)
                    elif [ -f "$camino" ]
                    then
                        #Ejecuta el comando wc -c el cual devuelve el tamaño en bytes del archivo en formato "tamaño del archivo" "nombre del archivo"
                        #Para obtener el dato del tamaño se corta el resultado en el primer espacio y se substitullen los espacios que puedan contener por caracter vacio
                        #dejando así el numero aislado
                        local variable=$(wc -c $camino | cut -d ' ' -f1 | tr -s ' ')
                        suma=$(expr $suma + $variable)
                    fi
                fi
            done
    #por si la ruta introducida como parametro al script coincide con un archivo
    elif [ -f "$5" ]
    then
        if [ "$4" -eq 0 ] || [[ ! "$5" == *"$3"* ]] #Comprueba que el parametro --exclude no se ha introducido y en caso de ser asi lo compara con la ruta del archivo
        then
            suma=$(wc -c < "$5")
        fi
    fi
}
##################Comprobacion de errores#####################
OPTION=""
CONTADOR=1 #Se empieza en el arg 1
OPTION_D=-99999; OPTION_S=-99999; OPTION_EXCL=-99999  #Para que las variables con las opciones -d -s y --exclude se pasen siempre como param de la funcion
excluido=0 #Comprueba que el usuario ha introducido un valor puesto que podría haber introducido el valor por defecto
for i in $@; do
    case $i in
    "-s" | "-d" | "--exclude")
        if [ $CAMINOS ]; then #Error si ya se ha recogido antes uno o más caminos
            mostrarError
        fi
        case $i in
        "-d" | "--exclude")
            if [ $CONTADOR -eq $# ]; then #Error si -d o --exclude es el ultimo param (y no tiene ningun valor detras)
                mostrarError
            fi
            OPTION=$i
            ;;
        "-s")
            OPTION_S=1 #La opcion -s no tiene ningun parametro detras
            ;;
        esac
        ;;
    *)
        case $OPTION in                                   #Se recogen los parametros para la opcion correspondiente y/o el/los caminos##
        "-d")                                             #Deberia recoger ahora el param asociado a la opcion -d de la iter. anterior
            NIVELES=$(expr $i / 1)                        #Paso a entero
            if [ ! $NIVELES ] || [ $NIVELES -lt 0 ]; then #La primera parte tambien podria ser:  if [ -z $NIVELES ] ; then
                mostrarError
            fi
            OPTION_D=$NIVELES
            ;;
        "--exclude") #Param de --exclude
            OPTION_EXCL=$i 
            excluido=1
            ;;
        "")
            CAMINOS+=("$i") #$i representa un camino/ruta la anyadimos al array/vector
            ;;
        esac
        OPTION="" #Se resetea tras recoger la opcion adecuada
        ;;
    esac
    CONTADOR=$(expr $CONTADOR + 1)
done
#####################################################################
if [ ! $CAMINOS ]; then # Tratar cuando no se especifica un camino (".")
    computingSize $OPTION_D $OPTION_S $OPTION_EXCL $excluido "." 1
    # acciones con el tamanyo..
else
    for i in "${CAMINOS[@]}"; do
        computingSize $OPTION_D $OPTION_S $OPTION_EXCL $excluido $i 1 
        # acciones con el tamanyo..
        echo "Suma total $suma en $i" ###PROF imprimes el tamaño total...
        suma=0 
    done
fi
exit 0