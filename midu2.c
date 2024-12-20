#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>
#include <sys/stat.h>

/**
 * Imprime un mensaje de error
 */
void mostarError(){
    printf("ERROR. Modo de empleo: midu [opciones] [camino1 camino2 camino3 ...]\n");
}

/**
 * Atraviesa recursivamente un árbol de directorios e imprime el tamaño de cada directorio
 * 
 * @param limite la profundidad máxima del árbol de directorios
 * @param actual la profundidad actual de la recursividad
 * @param solofin si es 1, solo imprimirá el resultado final, si es 0, imprimirá el resultado de cada
 * directorio.
 * @param exclude el nombre del archivo a excluir
 * @param excluido 0 si el parámetro de exclusión está vacío, 1 de lo contrario
 * @param direccion el directorio a escanear
 * 
 * @return el tamaño del archivo.
 */
int VerContenido(int limite,int actual, int solofin, char *exclude, int excluido, char direccion[]){
    struct dirent *entry;
    struct stat st;
    stat(direccion,&st);
    int suma = 0;
    if(S_ISREG(st.st_mode))
    suma = st.st_size;
    else{
        DIR *directorio= opendir(direccion);
        while( (entry=readdir(directorio)))
        {
            // Obtiene el nombre del archivo o directorio
            char *nombre = entry -> d_name;
            int longitud = strlen(direccion) + strlen(nombre) + 1;
            char pref[longitud];
            strcpy(pref, "");
            strcat(pref,direccion);
            strcat(pref,"/");
            strcat(pref,nombre);
            //Si la dirreccion termina en "."
            int resultado1= strcmp(nombre, ".");
            //Si la dirreccion termina en ".."
            int resultado2= strcmp(nombre, "..");
            /* 
            * Obtiene el tamaño del archivo o direcotrio si no cumple las dos condiciones anteriores o el nombre
            * del directorio o archivo 
            */
            if (resultado1 != 0 && resultado2 != 0 && (strcmp(exclude, "") == 0 || (strstr(nombre,exclude) == NULL))){
                int tamano = VerContenido(limite, (actual+1), solofin, exclude, excluido,pref);
                suma = suma + tamano;
                // Si es un directorio se muestra el tamaño
                if (opendir(pref) != NULL && solofin == 0 && ((limite == 0) || (actual <= limite)))
                    printf("%10d %s \n", tamano,pref);
            }    
        }
        closedir(directorio);
    }
    return suma;
}

/**
 * Atraviesa recursivamente un árbol de directorios e imprime el tamaño total de todos los archivos en
 * el árbol
 * 
 * @param argc número de argumentos
 * @param argv 
 * 
 * @return La suma del tamaño de todos los archivos en el directorio.
 */
int main (int argc,char *argv[]){
    

    int solofin = 0, limite = 0, excluido = 0;
    char *exclude;
    char *caminos[argc-1];
    int i = 1;
    int cami = 0;
    // Lee los parametros
    while (i < argc)
    {
        char *param = argv[i++];
        if (strcmp(param, "-s") == 0)
            if (cami == 0) 
                solofin = 1 ;
            else{
                mostarError();
                return 1;
            }
        else if (strcmp(param,"--exclude")==0)
        {
            if (cami == 0){
                exclude = argv[i++];
                excluido = 1;
            }
            else{
                mostarError();
                return 1;
            }
        }else if (strcmp(param,"-d") == 0)
        {
            if (cami == 0)
                {
                    int k =0;
                    while(argv[i][k]!='\0'&&(argv[i][k]-'0')>=0&&(argv[i][k++]-'0')<=9);
                    if(argv[i][k]=='\0')
                        limite = atoi(argv[i++]);
                    else{
                        mostarError();
                        return 1;
                    }
                }
            else{
                mostarError();
                return 1;
            }
        }else{
            caminos[cami++] = param;
        } 
    }
    i=0;
    if (cami ==0)
    {
        char *direccion = ".";
         printf("Suma total %d en ./\n", VerContenido(limite, 1, solofin, exclude, excluido, direccion));
    }
    while(i< cami){
        char *direccion = caminos[i++];
        printf("Suma total %d en %s\n", VerContenido(limite, 1, solofin, exclude, excluido, direccion),direccion);
    }
    return 0;
}