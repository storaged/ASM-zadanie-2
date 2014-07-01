#define cpuid(func,ax,bx,cx,dx)\
    __asm__ __volatile__ ("cpuid":\
        "=a" (ax), "=b" (bx), "=c" (cx), "=d" (dx) : "a" (func));
#define SSE_BIT     25
#define SSE2_BIT    26

#include <stdio.h>
#include <time.h>
#include <stdlib.h>

void print(int**, int);
void cleanUp(int**, int);
int decyzja(int, int);
extern void runda(int**, int**);

int main (int argc, char *argv[] ){
  
  int alignment = SZEROKOSC % 4 == 0 ? 0 : 4 - SZEROKOSC % 4;
  int aligned_szerokosc = 4 + SZEROKOSC + alignment + 4;
  int i, j, ilosc_rund;
  int ** plansza __attribute__ ((aligned (16))); 
  int ** tmp __attribute__ ((aligned (16))), ** tmp2;
  clock_t startTime, endTime;
  int iterTime = 0, summaryTime = 0;
  int a, b, c, d;
  int sse, sse2;
  
  /* sprawdznie argumentów */
  if(argc < 2){
    fprintf(stderr, "Użycie: ./gra <liczba_rund:int>\n");
    exit(1);
  }
   
  /* sprawdzenie dostępności rozszerzeń SSE i SEE2 */
  cpuid(1, a, b, c, d);
  sse = (d >> SSE_BIT) & 1;
  sse2 = (d >> SSE2_BIT) & 1; 
  if(sse == 0){
    fprintf(stderr, "SSE niedostępne\n");
    exit(1);
  }
  if(sse2 == 0){
    fprintf(stderr, "SSE2 niedostępne\n");
    exit(1);
  } 

  /* ustalenie ilosc generacji */
  ilosc_rund = atoi(argv[1]);

  /* alokacja i wczytanie planszy */
  plansza = malloc(sizeof(int*)*(WYSOKOSC + 2));
  tmp = malloc(sizeof(int*)*(WYSOKOSC + 2));
  
  for(i = 0; i < WYSOKOSC + 2; i++){
    plansza[i] = malloc(sizeof(int) * (aligned_szerokosc));
    tmp[i] = malloc(sizeof(int) * (aligned_szerokosc));
  }
  
  for (i = 0; i < WYSOKOSC+2; i++) {
    for (j = 0; j < aligned_szerokosc; j++) {
      if(i == 0 || i == WYSOKOSC + 1 || j < 4 || 
            j >= SZEROKOSC + 4){
        plansza[i][j] = 0;
      } else {
        scanf("%d ", &plansza[i][j]);
      }
      tmp[i][j] = 0;
    };
  };

  /* symulacja gry */
  for(i=0; i < ilosc_rund; i++){
   
    /* symuluj ewolucję */
    startTime = clock();
    runda(plansza, tmp);
    endTime = clock();
    
    /* sumuj czas spędzony na wykonanie instrukcji asemblera */
    iterTime = (endTime - startTime)/1000;
    summaryTime += iterTime;
    
    /* wyczyść pola poza tablicą */
    cleanUp(tmp, aligned_szerokosc);

    /* aktualizuj planszę */
    tmp2 = plansza;
    plansza = tmp;
    tmp = tmp2;
    
    /* wypisz stan planszy */
    print(plansza, aligned_szerokosc);
    if(i != ilosc_rund - 1)
      printf("\n");

  }

  fprintf(stderr, "Asembler execution: %d(ms)\n", summaryTime);
  return 0;
}

void print(int** p, int aligned_szerokosc){
  int i, j;
  for(i = 1; i < WYSOKOSC + 1; i++){
      for(j = 4; j < SZEROKOSC + 4; j++){
      if(j != SZEROKOSC + 3)
        printf("%d ", p[i][j]);
      else 
        printf("%d", p[i][j]);
    }
    printf("\n");
  }
}

void cleanUp(int** p, int aligned_szerokosc){
  int i, j;
  for(i = 1; i < WYSOKOSC + 1; i++){
    for(j = SZEROKOSC + 4; j < aligned_szerokosc; j++){
        p[i][j] = 0;
    }
  }
}
