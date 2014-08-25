clean:
	rm -f *.o *.dylib *.swiftdoc *.swiftmodule SetTests

module: clean
	xcrun -sdk macosx swiftc -emit-library -o libSwiftSets.dylib -Xlinker -install_name -Xlinker @rpath/libSwiftSets.dylib -emit-module -module-name SwiftSets -module-link-name SwiftSets Set.swift

test: module
	xcrun -sdk macosx swiftc SetTests.swift -o SetTests -I . -L . -Xlinker -rpath -Xlinker @executable_path/
	./SetTests
