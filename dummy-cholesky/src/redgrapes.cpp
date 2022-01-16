#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <redGrapes/redGrapes.hpp>
#include <redGrapes/resource/ioresource.hpp>
#include "common.h"

redGrapes::RedGrapes<> rg(4);

void compute(LOG_TimeUnit *LOG_start,
             LOG_TimeUnit *LOG_mid,
             LOG_TimeUnit *LOG_stop, int DIM)
{
    std::vector<redGrapes::IOResource<int>> A( DIM*DIM );

    *LOG_start = LOG_getTimeStart();

    for (int k = 0; k < DIM; ++k) {
        rg.emplace_task(
            [](auto a) { LOG_TIMER("potrf"); },
            A[k*DIM + k].write());

        for (int m = k+1; m < DIM; ++m) {
            rg.emplace_task(
                [k, m](auto a, auto b) {
                    LOG_TIMER("trsm");
                },
                A[k*DIM + k].read(),
                A[m*DIM + k].write());
        }

        for (int m=k+1; m < DIM; ++m) {
            rg.emplace_task(
                [k, m](auto a, auto b) {
                    LOG_TIMER("syrk");
                },
                A[m*DIM + k].read(),
                A[m*DIM + m].write());

            for (int n=k+1; n < m; ++n) {
                rg.emplace_task(
                    [](auto a, auto b, auto c) {
                        LOG_TIMER("gemm");
                    },
                    A[m*DIM + k].read(),
                    A[n*DIM + k].read(),
                    A[m*DIM + n].write());
            }
        }
    }

    *LOG_mid = LOG_getTimeStop();

    rg.wait_for_all();

    *LOG_stop = LOG_getTimeStop();
}

int main(int argc, char *argv[]) {
    int n = 5;
    int n_threads = 1;

    if (argc > 1)
        n = atoi(argv[1]);
    if (argc > 2)
        delay = atoi(argv[2]);
    
    TIMING_init();

    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        LOG_TimeUnit LOG_start, LOG_mid, LOG_stop;
        compute(&LOG_start, &LOG_mid, &LOG_stop, n);
        TIMING_add(LOG_start, LOG_mid, LOG_stop);
        LOG_optional_break
    }

    TIMING_end(n);

    LOG_dump("redgrapes.log");
    return 0;
}
