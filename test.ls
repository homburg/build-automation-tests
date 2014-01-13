path = (require \path)
chai = (require \chai)
chai.use(require \chai-fs)
expect = chai.expect
exec = (require \child_process).exec
timeout = (time, f) -> (setTimeout f, time)

# "it" is a keyword in livescript
et = root[\it]

getMtime = (path, cb) !->
	error, stdout <-! exec "stat -c '%y' #{path}", cb

lscCmd = "#{__dirname}/node_modules/.bin/lsc"

make = (wd, target, cb) !->
	target ||= "all"
	cmd = "make -C #{wd} #{target}"
	(exec cmd, cb)

(describe "tests" !->
	(et "should run" !->
		expect(true).to.be.true
	)
)

(describe "make test" !->
	(beforeEach ->
		error <-! exec "rm -f make/single/to.txt"
		(expect error).not.to.be.ok
	)

	(et "should produce a single file" ((done) !->
		err, stdout, stderr <-! exec "make -C make/single"
		(expect err).not.to.be.false
		(expect "make/single/to.txt").to.be.a.file!
		done!
	))

	(et "should not update file twice" ((done) !->
		# question mode
		error, stdout <-! exec "make -C make/single -q"
		(expect error).to.be.ok

		# Make sez: not up to date
		(expect error.code).to.be.equal 1

		<-! exec "make -C make/single"
		error, _mtime <-! getMtime "make/single/to.txt"
		(expect error).not.to.be.ok
		mtime = _mtime
		(expect mtime).not.to.be.equal ""

		<-! exec "make -C make/single"
		error, _mtime <-! getMtime "make/single/to.txt"
		(expect error).not.to.be.ok
		(expect _mtime).to.be.equal(mtime)
		done!
	))

	(et "should update file mtime", ((done) ->
		<-! exec "echo 'test' > out.txt"
		error, _mtime <-! getMtime "out.txt"
		(expect error).not.to.be.ok
		mtime = _mtime

		<-! exec "echo 'test' > out.txt"
		error, _mtime <-! getMtime "out.txt"
		(expect error).not.to.be.ok

		# mtime is updated
		(expect _mtime).not.to.be.equal(mtime)
		done!
	))
)

(describe "ninja build tool" !->
	makeMake = (wd) ->
		(target, cb) -> (make wd, target, cb)

	(describe "building single file" !->
		wd = "ninja/single"
		ninjaMake = (makeMake wd)

		conf = (cb) !->
			ninjaMake "configure", cb

		(beforeEach (done) !->
			error <-! ninjaMake "clean"
			(expect error).to.not.be.ok
			done!
		)

		(et "should start with a clean slate", !->
			(expect (path.join wd, "build.ninja")).to.not.be.a.path!
			(expect (path.join wd, "to.txt")).to.not.be.a.path!
		)

		(et "should convert config to a ninja build file", (done) !->
			error, stdout <-! conf
			(expect error).not.to.be.ok
			(expect (path.join wd, "build.ninja")).to.be.a.file!
			done!
		)

		(et "should produce a single file", (done) !->
			error <-! ninjaMake "all"
			(expect error).not.to.be.ok
			(expect (path.join wd, "to.txt")).to.be.a.file!
			done!
		)

		(et "should only build once", (done) !->

			error <-! ninjaMake "all"
			(expect error).not.to.be.ok

			error, mtime1 <-! getMtime (path.join wd, "to.txt")
			(expect error).not.to.be.ok

			error <-! ninjaMake "all"
			(expect error).not.to.be.ok

			error, mtime2 <-! getMtime (path.join wd, "to.txt")
			(expect error).not.to.be.ok

			(expect mtime1).to.be.equal(mtime2)

			done!
		)
	)

	(describe "building multiple files" !->
		wd = "ninja/multiple"
		ninjaMake = (makeMake wd)
		out = (path.join wd, "build", "out.js")

		(beforeEach (done) !->
			error <-! ninjaMake "clean"
			(expect error).not.to.be.ok
			done!
		)

		(et "should start with a clean slate" !->
			(expect (path.join wd, "build.ninja")).not.to.be.a.path!
			(expect out).not.to.be.a.path!
		)

		(et "should build them all" (done) !->
			error, stdout <-! ninjaMake "all"
			(expect error).not.to.be.ok
			(expect out).to.be.a.file!
			done!
		)

		(et "should only build once" (done) !->
			error, stdout <-! ninjaMake "all"
			(expect error).not.to.be.ok
			(expect out).to.be.a.file!

			error, mtime <-! getMtime out
			(expect error).not.to.be.ok

			error, stdout <-! ninjaMake "all"
			(expect error).not.to.be.ok
			(expect out).to.be.a.file!

			error, mtime2 <-! getMtime out
			(expect error).not.to.be.ok
			(expect mtime).to.be.equal(mtime2)

			done!
		)
	)
)
