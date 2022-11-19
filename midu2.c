#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <string.h>
#include <sys/stat.h>

void mostarError(){
    printf("ERROR. Modo de empleo: midu [opciones] [camino1 camino2 camino3 ...]\n");
}

int calcularTamano(char *direcion){
    struct stat sb;
    if(stat(direcion, &sb)==-1){
        perror("he fallado");
        return -1;
    }
    return sb.st_size;
}

int VerContenido(int limite,int actual, int solofin, char *exclude, int excluido, char direccion[]){
    struct dirent *entry;
    DIR *directorio;
    directorio=opendir(direccion);
    int suma=0;
    if(directorio == NULL)
    suma =calcularTamano(direccion);
    else{
        while( (entry=readdir(directorio)))
        {
                char *nombre= entry->d_name;
                int longitud=strlen(direccion)+strlen(nombre)+1;
                char pref[longitud];
                strcpy(pref, "");
                strcat(pref,direccion);
                strcat(pref,"/");
                strcat(pref,nombre);
                int resultado1= strcmp(nombre, ".");
                int resultado2= strcmp(nombre, "..");
            if (resultado1 !=0 && resultado2 !=0 &&(strcmp(exclude, "")==0||(strstr(nombre,exclude)==NULL))){
                int tamano =VerContenido(limite, (actual+1), solofin, exclude, excluido,pref);
                suma=suma+tamano;
                if (opendir(pref)!=NULL)
                printf("%10d %s\n", tamano,pref);
            }    
        }
        closedir(directorio);
    }
    return suma;
}

int main (int argc,char *argv[]){
    int solofin=0, limite=0,excluido=0;
    char *exclude;
    char *caminos[argc];
    int i=1;
    int cami=0;
    //leer parametros
    while (i<argc)
    {
        char *param= argv[i++];
        char letra ='f';
        if (strcmp(param, "-s")==0)
            if (cami ==0) 
                solofin=1;
            else{
                mostarError();
                return 1;
            }
        else if (strcmp(param,"--exclude")==0)
        {
            if (cami ==0){
                exclude= argv[i++];
                excluido=1;
            }
            else{
                mostarError();
                return 1;
            }

        }else if (strcmp(param,"-d")==0)
        {
            if (cami ==0)
                limite = atoi(argv[i++]);
            else{
                mostarError();
                return 1;
            }
        }else{
            caminos[cami++]= param;
        } 
    }
    i=0;
    while(i< cami){
    char *direccion= caminos[i++];
    printf("Suma total %d en %s\n", VerContenido(limite, 1, solofin, exclude, excluido, direccion),direccion);
    }
    return 0;
}