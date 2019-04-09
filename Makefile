KCOMPILER=kotlinc
KEXEC=kotlin
TEMPLATE=weaver.jar compiler.jar microcompiler.jar

$(TEMPLATE): %: $(%:.jar=.kt)
	$(KCOMPILER) $(@:.jar=.kt) -d $@

all: weaver.jar compiler.jar microcompiler.jar

clean:
	rm -f weaver.jar
	rm -f compiler.jar
	rm -f microcompiler.jar
