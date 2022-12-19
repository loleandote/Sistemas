#include <unistd.h>
#include <stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <signal.h>

pid_t hijos[];
int numHijos;

void Manejador(int num){
    printf("HOLA\n");
    int j=0;
     for(;j<numHijos;j++)
            if(hijos[j]>0){
                kill(hijos[j],15);
                printf("matando hijo %d\n",hijos[j]);
            }
}
int main(int argc, char *argv[]){
    numHijos=argc-1;
    hijos[numHijos];
        int i=0;
        for(;i<argc-2;i++)
            hijos[i]=0;
    if(signal(SIGINT,Manejador)==SIG_ERR){
        fprintf(stderr,"Error en la manipulación de la señal\n");
        exit(EXIT_FAILURE);
    }
    if(argc<2){
        printf("ERROR. Modo de empleo: ./padre [camino1 camino2 camino3 ...]\n");
        return EXIT_FAILURE;
    }
        struct stat st;
        i=1;
        for(;i<argc;i++){
            stat(argv[i],&st);
            if(S_ISREG(st.st_mode)||S_ISDIR(st.st_mode))
                switch(hijos[i-1]=fork())
                {
                    case -1:
                        printf("Error en la creacion del proceso hijo\n");
                        return EXIT_FAILURE;
                    case 0:
                        // Es el hijo
                            sleep(5);
                            execlp("wc","wc",argv[i],NULL);
                        return 0;
                    default:
                        printf("Inicio hijo %d con %s\n",hijos[i-1], argv[i]);
                }
            else
                printf("No existe el archivo o directorio: %s\n",argv[i]);
        }
        i=0;
        for(;i<argc-1;i++)
        {
            pid_t hijo= wait(NULL);
            int j=0; 
            int salir=0;
            for(;j<argc-1&&salir==0;j++)
            if(hijos[j]== hijo){
                salir=1;
                hijos[j]= 0;
            }
            if(hijo>0)
            printf("Fin hijo %d\n",hijo);
        }
    return 0;
}