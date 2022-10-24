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
    if [[ ! "$4" == *"$OPTION_EXCL"* ]]
    then 
        if [ -d "$4" ]
        then
            local camino
            for camino in $4/*
            do
                if [[ ! "$camino" == *"$OPTION_EXCL"* ]]
                then
                    if [ -d $camino ]
                    then	
                        local temp=$suma
                        suma=0
                        computingSize $1 $2 $3 $camino $(expr $5 + 1)
                        if [ $OPTION_S -eq -99999 ]
                        then
                            if [ "$OPTION_D" -eq -99999 ]
                            then
                                echo $suma $camino
                                elif [ $5 -le "$OPTION_D" ]
                                then
                                    echo $suma $camino
                            fi
                        fi
                        suma=$(expr $suma + $temp)
                    elif [ -f "$camino" ]
                    then
                        local variable=$(wc -c $camino | cut -d ' ' -f1 | tr -s ' ')
                        suma=$(expr $suma + $variable)
                    fi
                fi
            done
    elif [ -f "$4" ]
    then
        suma=$(wc -c < "$4")
    fi
    else
    echo "$4"
    fi
   
}
##################Comprobacion de errores#####################
OPTION=""
CONTADOR=1 #Se empieza en el arg 1
OPTION_D=-99999; OPTION_S=-99999; OPTION_EXCL=-99999 #Para que las variables con las opciones -d -s y --exclude se pasen siempre como param de la funcion
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
    computingSize $OPTION_D $OPTION_S $OPTION_EXCL "." 1
    # acciones con el tamanyo..
else
    for i in "${CAMINOS[@]}"; do
        computingSize $OPTION_D $OPTION_S $OPTION_EXCL $i 1
        # acciones con el tamanyo..
        echo "Suma total $suma en $i" ###PROF imprimes el tamaño total...
        suma=0 
    done
fi
exit 0