ninjaGen = (require "ninja-build-gen")
lodash = (require "lodash")
glob = (require "glob")
path = (require "path")

ninja = (ninjaGen "1.3")

# Map function for infix
map = (arr, f) ->
	(lodash.map arr, f)

ninja.rule \concat .run "cat $in > $out"
ninja.rule \livescript .run "lsc < $in > $out"
ninja.rule \copy .run "cp $in $out"


error, files <-! glob "src/**/*.ls"
throw new Error(error) if error
throw new Error("No input files!") if files.length is 0

files `map` (file) ->
	inF = file

	pathParts = (file.split path.sep)
	pathParts[0] = "build"

	pathParts[pathParts.length-1] = (
		path.basename(inF).replace(/\..*$/, ".js")
	)

	outF = (path.join ...pathParts)

	ninja.edge outF .from file .using \livescript

ninja.edge \default .need "build/out.js"

ninja.byDefault \default
ninja.save "build.ninja"
