PAL:=tools/palbart

.PHONY: test tools clean distclean

all:	tools test


test:
	$(PAL) tests/test1.pal
	./palreport.sh < tests/test1.lst > tests/test1.log
	diff -w -B tests/test1.log tests/test1.ok


tools:
	mkdir -p tools
	git clone --depth=1 https://github.com/SmallRoomLabs/palbart.git tools/palbart-src
	cd tools/palbart-src; make; cp palbart ..; cd ..; rm -rf palbart-src


clean:
	rm -rf *~ tests/*~ tests/*.bin tests/*.err tests/*.lst tests/*.prm tests/*.rim tests/*.map tests/*.log

distclean:
	make clean
	rm -rf tools/
	