ninjaGen = (require "ninja-build-gen")
ninja = (ninjaGen "1.3")

ninja.rule "cat" .run "cat $in > $out"

ninja.edge("to.txt").from("from.txt").using("cat")

ninja.edge("phony default").from("to.txt")

ninja.byDefault \default
ninja.save "build.ninja"

