chai = (require \chai)
chai.use(require \chai-fs)
expect = chai.expect
exec = (require \child_process).exec
stat = (require \fs).stat
timeout = (time, f) -> (setTimeout f, time)

# "it" is a keyword in livescript
et = root[\it]

getMtime = (path, cb) !->
	error, stdout <-! exec "stat -c '%y' #{path}", cb

(describe "tests" !->
	(et "should run" !->
		expect(true).to.be.true
	)
)

(describe "make test" !->
	(et "should produce a single file" ((done) !->
		err, stdout, stderr <-! exec "make -C make/single"
		(expect err).not.to.be.false
		(expect "make/single/to.txt").to.be.a.file!
		done!
	))

	(beforeEach ->
		error <-! exec "rm -f make/single/to.txt"
		(expect error).not.to.be.ok
	)

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

