KCOMPILER=kotlinc
KEXEC=kotlin
TEMPLATE=weaver.jar compiler.jar microcompiler.jar

$(TEMPLATE): %: $(%:.jar=.kt)
	$(KCOMPILER) $(@:.jar=.kt) -d $@

all: weaver.jar compiler.jar microcompiler.jar
