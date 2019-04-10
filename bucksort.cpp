#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define BUCKETS 0b1000
#define BUCKET_SIZE 20
#define LENGTH 32

int count = 0;
bool LT(int a, int b)
{
	count++;
	return a < b;
}

// Bucket/Insertion sort (except final merge). C-style pseudocode
void bi_sort(short *data){
    short *buckets;
    short pc_, ir_, ar, gr, hr, lc_, ir_;

    for(pc_ = 0xE0; pc_ != 0; ++pc_){
        // Fetch and hash
        ar = data[pc_];
        gr = data[pc_];
        
        ar = ar >> 9;
        ar = ar & 0b1111000;
        hr = ar;

        ar = buckets[ar];    // Index 0 is pointer to end of array
        
        ++ar;
        buckets[hr] = ar;    // Increment pointer (since we're inserting a new value)
        --ar;

        ir_ = pc_;           // Push pc
        pc_ = ar;            // Copy start index to pc (for fast indexing)
        ar = ar - hr;        // Compute length

        lc_ = ar;            // Loop AR-times

        --lc_;

        while(lc_ != 0){
            ++pc_;
            hr = data[pc_];
            if(hr > gr){
                data[pc_] = gr;
                // Insert here
                while(lc_ != 0){
                    ++pc_;
                    gr = data[pc_];
                    data[pc_] = hr;
                    hr = gr;
                    --lc_;
                }

                goto END;
            }
            --lc_;
        }

        ++pc_;

        data[pc_] = gr;      // GR was the biggest. Insert it at the end

END:
        pc_ = ir_;           // Pop pc
    }
}

void sort(short *data, int length)
{
	short buckets[BUCKETS][BUCKET_SIZE] = {};
	short a_, pc, c, d;

	// Bucketsort
	for (a_ = 0; a_ < length; a_++)
	{
		c = data[a_];
		d = (c >> 13) & 0b111;
		pc = buckets[d][0];
		pc++;
		buckets[d][0] = pc;
		buckets[d][pc] = c;
	}

	for (short q = 0; q < BUCKETS; q++)
	{
		short *curr = buckets[q];
		int length = curr[0];
		printf("buck: %d\tlength: %hd\n", q, curr[0]);
		for (short i = 0; i < length; i++)
		{
			printf("%hd, ", curr[i + 1]);
		}
		printf("\n");
	}
#if 0
i ← 1
while i < length(A)
	x ← A[i]
	j ← i - 1
	while j >= 0 and A[j] > x
		A[j+1] ← A[j]
		j ← j - 1
	end while
	A[j+1] ← x
	i ← i + 1
end while
#endif
	
	// Insertion Sort
	for (short q = 0; q < BUCKETS; q++)
	{
		short length = buckets[q][0];
		short *curr = buckets[q] + 1;
		a_ = 1;
		while (a_ < length)
		{
			c = curr[a_];
			pc = a_ - 1;
			while (pc >= 0 && LT(curr[pc], c))
			{
				curr[pc+1] = curr[pc];
				pc--;
			}
			curr[pc+1] = c;
			a_++;
		}
	}

	// Merge the buckets
	pc = 0;
	int h = 0b100;
	for (short q = 0; q < BUCKETS; q++)
	{
		short *curr = buckets[h];
		h = (h + 1) & 0b111;
		a_ = curr[0];
		while (a_ >= 1)
		{
			data[pc] = curr[a_];
			pc++;
			a_--;
		}
	}
}

int main(int *argc, char **argv)
{
	short data[LENGTH] = {};

	srand(clock());
	for (int i = 0; i < LENGTH; i++)
	{
		data[i] = rand() % 0xFFFF;
	}

	sort(data, LENGTH);

	printf("Num compares: %d\n", count);
	for (int i = 0; i < LENGTH; i++)
	{
		printf("%hd, ", data[i] & 0xFFFF);
	}
	printf("\n");
	return 0;
}
