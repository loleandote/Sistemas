#!/bin/bash
shopt -s dotglob #recuperar ocultos  ####PROF: te falta esta linea para el recorrido de nodos ocultos (archivos regulares, directorios, ... que empiezan con un punto e.j.:".archivo.txt")
suma=0
function SumaRecursiva ()
{
    #local nivel =$1 ###PROF por ahora te quito lo de opciones para simplificar (primero computa bien el tamaño y el recorrido recursivo)
    #local sumaDirectorio=0 #### PROF esta variable loval no creo que te haga falta....
    if [ -d "$1" ]  #### PROF como no estás haciendo bien la recogida de opciones (como "-d num_entero") por ahora te lo he quitado para simplificar
    then          #### y dejar funcionando el tema del cómputo de tamaños...
        local camino
        for camino in $1/*   ####Al quitar el parámetro de otras opciones (para simplificar y ayudarte a poner en funcionamiento el tema del cómputo de tamaño) lo pongo como único param ($1)
        do
            if [ -d "$camino" ]
            then
               #si es un directorio se incrementa en uno para llamar de nuevo al mismo metodo
                #local nivelParametro=$(expr $nivel +1) #### PROF: tendrías que ir restando no sumando y sólo mostrar el nombre del subdirectorio  si "d" sigue siendo >=0...
                
                ####PROF: te añado codigo para salvaguardar el valor de la suma antes de resetearlo para la llamada recursiva a un subdirectorio (como en el pseudocógido facilitado) 
                local temp=$suma
                suma=0
                SumaRecursiva $camino
                ####PROF: imprime el tamaño (aquí tendrías que comprobar estado de funcione -d y -s para ver si lo tienes que imprimir o no...)
                echo $suma $camino

                # obtiene de vuelta el valor del tamaño del directorio
                # sumaDirectorio=$(expr $sumaDirectorio + $sumador)
                suma=$(expr $suma + $temp)
                # local sumador=$? #### PROF: esto se usa para ver si la salida de un comando (con exit) fue exitosa (==0) o no (!=0). NO lo puedes usar como pretendías con el return de la funcion recursiva 
            elif [ -f "$camino" ]
            then
                # variable=$(wc -c $camino | cut -d ' '-f1 | tr -s ' ') ###PROF no sé si esta forma que expones funciona creo que el -f1 no tiene que estar pegado...
                local variable=$(wc -c $camino | cut -d ' ' -f1 | tr -s ' ')   ###PROF se puede hacer más fácil con variable=$(wc -c < $camino)
                ###PROF si lo quieres en Bytes lo puedes hacer muy fácil con: local variable=$(wc -c < "$camino")
                #sumaDirectorio=$(expr $sumaDirectorio + $variable)  ####PROF suma directorio no te hace falta para nada lo haces todo con la variable global suma...
                suma=$(expr $suma + $variable) 
            fi
        done
    elif [ -f "$1" ] ###PROF si se invoca por primera vez la funcion de computo de tamaño con un archivo regular... simplemente es (comprobar opciones) y
    then                #si se cumple que se puede visualizar el tamaño del archivo, entonces, hacerlo
        suma=$(wc -c < "$1") ####PROF como solo tengo que calcular el tamaño de este archivo lo asigno a la variable global
    fi
    ################################################
    ####PROF todo esto de abajo te sobra... no sé muy bien qué haces en esta parte...
    # if [ $nivel -gt 1 ]
    # then
    # if [ -d $2 ]
    # then
    # printf "%-10s "$sumaDirectorio $(echo $camino | cut -d '/' -f1-"$nivel")
    # printf "\n"
    # fi
    # nivel=$(expr $nivel - 1)
    # fi
    # elif [ -f $2 ]
    # then
    # sumaDirectorio=$(wc -d $2 | cut -d ' ' -f1 | tr -s ' ')
    # fi
    # # acumula al tamaño total 
    # suma=$(expr $suma + $sumaDirectorio)
    #return $sumaDirectorio   ####PROF:No Alfonso el return aquí en BASH sólo permite mandar un entero de valor hasta 255... no puedes hacerlo así
}
if [ $# -eq 0 ]  ####PROF:Cuidaddo aquí porque puede que no tengas ningún camino o ruta pero sí tengas opciones... e.j.: ./midu -d 5
then
    #SumaRecursiva 1 "./"
    SumaRecursiva "."
else  ####PROF:Cuidaddo porque si tienes camino/s puedes tener más de uno... por lo que necesitas llamar a SumaRecursiva para cada uno de ellos (reseteando suma 
      ### entre las llamadas a SumaRecursiva (mira el código de control de errores que os pasé por Moodle para que vea)
    # SumaRecursiva 1 $1  ####PROF:la opcion -d puede estar o no... pero se trata de ir restando (no sumando) en cada nivel (nueva llamada recursiva) al que profundizas...
                        ####PROF: por ahora te quito la opción -d... porque no lo estás haciendo bien...
    SumaRecursiva $1
    echo "Suma total $suma $1" ###PROF imprimes el tamaño total...
    suma=0 
fi
