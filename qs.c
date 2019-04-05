#include <stdio.h>

void quicksort(int *data, int low, int high){
    while(low < high){
        int pivot = data[high];
        int i = low;

        for(int j = low; j < high; ++j){
            if(data[j] < pivot){
                int tmp = data[j];
                data[j] = data[i];
                data[i] = tmp;
                i += 1;
            }
        }
    
        int tmp = data[high];
        data[high] = data[i];
        data[i] = tmp;
        
        quicksort(data, low, i - 1);
        low = i + 1;
    }
}

int main(int argc, char ** argv){
    int data[26] = {1, 2, 0, 3, 5, 9, 8, 7, 6, 11, 10, 4, 5, 6, 7, 9, 4, 6, 8, 7, 2, 4, 1, 12, 40, 25};
    for(int i = 0; i < 26; ++i)
        printf("#: %d\n", data[i]);

    quicksort(data, 0, 25);
    for(int i = 0; i < 26; ++i)
        printf("%: %d\n", data[i]);
}
