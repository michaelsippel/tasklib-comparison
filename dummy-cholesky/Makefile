CXXFLAGS = -Wall -O3
CFLAGS = -Wall -O3

THIRDPARTY=../thirdparty
SMPSS=$(THRIDPARTY)/smpss/bin/smpss-cc -Wc,-Wall -O3
OMPSS=$(THIRDPARTY)/ompss/bin/mcc --ompss -Wall -O3
SUPERGLUEINC=-I $(THIRDPARTY)/superglue/include
QUARKINC=-I $(THIRDPARTY)/quark-0.9.0/install/include/
QUARKLIB=-L $(THIRDPARTY)/quark-0.9.0/install/lib/ -lquark
SWANINC=-I $(THIRDPARTY)/swan/scheduler -I $(THIRDPARTY)/swan/obj/scheduler -I$(THIRDPARTY)/swan/obj/util -I $(THIRDPARTY)/swan/obj/ 
SWANLIB=$(THIRDPARTY)/swan/obj/scheduler/libschedulers.a
SWANCC       = gcc
SWANCXX      = g++
SWANCFLAGS   = -Wall -O3 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0
SWANCXXFLAGS = -Wall -O3 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 --std=c++0x -momit-leaf-frame-pointer -fno-omit-frame-pointer -pthread
REDGRAPESINC=-I $(THIRDPARTY)/redGrapes/ -I $(THIRDPARTY)/redGrapes/share/thirdParty/cameron314/concurrentqueue/include/ -I $(THIRDPARTY)/redGrapes/share/thirdParty/akrzemi/optional/include/

PKG_CONFIG_STARPU=env PKG_CONFIG_PATH=$(THIRDPARTY)/hwloc/lib/pkgconfig/:$(THIRDPARTY)/starpu/lib/pkgconfig pkg-config
STARPU_CFLAGS = -Wall -O3 $(shell $(PKG_CONFIG_STARPU) --cflags starpu-1.1)
STARPU_LDFLAGS = $(shell $(PKG_CONFIG_STARPU) --libs starpu-1.1)

PKG_CONFIG=env PKG_CONFIG_PATH=$(THIRDPARTY)/xkaapi/lib/pkgconfig pkg-config
kaapi_CFLAGS=-Wall -O3 $(shell $(PKG_CONFIG) --cflags kaapi++)
kaapi_LIBS=$(shell $(PKG_CONFIG) --libs kaapi++)

PKG_CONFIG=env PKG_CONFIG_PATH=$(THIRDPARTY)/xkaapi/lib/pkgconfig pkg-config
kaapic_CFLAGS=-Wall -O3 $(shell $(PKG_CONFIG) --cflags kaapic)
kaapic_LIBS=$(shell $(PKG_CONFIG) --libs kaapic)

ALL=smpss ompss superglue quark swan xkaapi kaapic starpu redgrapes
ALL:=$(addprefix bin/,$(ALL))
ALL:=$(ALL) $(addsuffix .log,$(ALL))

all: $(ALL)

bin/:
	mkdir -p bin

bin/smpss: src/smpss.c src/common.h
	$(SMPSS) src/smpss.c -o $@

bin/smpss.log: src/smpss.c src/common.h
	$(SMPSS) -DLOGGING src/smpss.c -o $@

bin/ompss: src/ompss.c src/common.h 
	$(OMPSS) src/ompss.c -o $@

bin/ompss.log: src/ompss.c src/common.h
	$(OMPSS) -DLOGGING src/ompss.c -o $@

bin/superglue: src/superglue.cpp src/common.h
	$(CXX) $(CXXFLAGS) $(SUPERGLUEINC) src/superglue.cpp -pthread -o $@

bin/superglue.log: src/superglue.cpp src/common.h
	$(CXX) $(CXXFLAGS) -DLOGGING $(SUPERGLUEINC) src/superglue.cpp -pthread -o $@

bin/quark: src/quark.c src/common.h
	$(CC) $(CFLAGS) $(QUARKINC) src/quark.c $(QUARKLIB) -pthread -o $@

bin/quark.log: src/quark.c src/common.h
	$(CC) $(CFLAGS) -DLOGGING $(QUARKINC) src/quark.c $(QUARKLIB) -pthread -o $@

bin/swan: src/swan.cpp src/common.h
	$(SWANCXX) $(SWANCXXFLAGS) $(SWANINC) src/swan.cpp $(SWANLIB) -o $@

bin/swan.log: src/swan.cpp src/common.h
	$(SWANCXX) $(SWANCXXFLAGS) -DLOGGING $(SWANINC) src/swan.cpp $(SWANLIB) -o $@

bin/xkaapi: src/xkaapi.cpp src/common.h
	$(CXX) $(kaapi_CFLAGS) src/xkaapi.cpp $(kaapi_LIBS) -o $@ -pthread

bin/xkaapi.log: src/xkaapi.cpp src/common.h
	$(CXX) $(kaapi_CFLAGS) -DLOGGING src/xkaapi.cpp $(kaapi_LIBS) -o $@ -pthread

bin/kaapic: src/kaapic.c src/common.h
	$(CC) $(kaapic_CFLAGS) src/kaapic.c $(kaapic_LIBS) -o $@ -pthread

bin/kaapic.log: src/kaapic.c src/common.h
	$(CC) $(kaapic_CFLAGS) -DLOGGING src/kaapic.c $(kaapic_LIBS) -o $@ -pthread

bin/starpu: src/starpu.c src/common.h
	$(CC) $(STARPU_CFLAGS) src/starpu.c $(STARPU_LDFLAGS) -o $@

bin/starpu.log: src/starpu.c src/common.h
	$(CC) $(STARPU_CFLAGS) -DLOGGING src/starpu.c $(STARPU_LDFLAGS) -o $@

bin/redgrapes: src/redgrapes.cpp src/common.h
	$(CXX) $(CXXFLAGS) -std=c++14 -DLOGGING $(REDGRAPESINC) src/redgrapes.cpp -pthread -lfmt -lboost_context -o $@

bin/counttasks: src/counttasks.c
	$(CXX) src/counttasks.c -o $@

runstarpu:
	LD_LIBRARY_PATH=$(THIRDPARTY)/starpu/lib/:$(LD_LIBRARY_PATH) ./bin/starpu

runstarpu.log:
	LD_LIBRARY_PATH=$(THIRDPARTY)/starpu/lib/:$(LD_LIBRARY_PATH) ./bin/starpu.log

clean:
	rm -f $(ALL)

.PHONY: all clean runstarpu
