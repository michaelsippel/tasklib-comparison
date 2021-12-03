#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <redGrapes/redGrapes.hpp>
#include "common.h"

LOG_TimeUnit LOG_start, LOG_mid, LOG_stop;

redGrapes::RedGrapes<> * rg;

void test(int n) {
    int i;
    LOG_start = LOG_getTimeStart();
   
    for (i = 0; i < n; ++i)
        rg->emplace_task([]{ LOG_TIMER("task"); });

    LOG_mid = LOG_getTimeStop();

    rg->wait_for_all();

    LOG_stop = LOG_getTimeStop();
}

int main(int argc, char *argv[]) {
    int i;
    int n = 1000000;

    if (argc > 1)
        n = atoi(argv[1]);
    if (argc > 2)
        delay = atoi(argv[2]);

    TIMING_init();

    rg = new redGrapes::RedGrapes<>();

    for (i = 0; i < NUM_ITERATIONS; ++i) {
        test(n);
        TIMING_add(LOG_start, LOG_mid, LOG_stop);
        LOG_optional_break
    }

    delete rg;
    
    TIMING_end(n);
    LOG_dump("redGrapes.log");

    return 0;
}

