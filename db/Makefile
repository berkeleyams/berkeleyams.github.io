PAGES=../fall08/index.html \
../spring09/index.html ../fall09/index.html \
../spring10/index.html ../fall10/index.html \
../spring11/index.html ../fall11/index.html \
../spring12/index.html ../fall12/index.html \
../spring13/index.html ../fall13/index.html \
../spring14/index.html ../fall14/index.html \
../spring15/index.html ../fall15/index.html \
../spring16/index.html ../fall16/index.html \
../spring17/index.html ../fall17/index.html \
../spring18/index.html ../fall18/index.html \
../spring19/index.html ../fall19/index.html \
../spring20/index.html ../fall20/index.html \
../spring21/index.html ../fall21/index.html 

all: $(PAGES)

# Special Makefile rule for current semester (which adds page index)

# ../spring21/index.html: spring21.sdb template.html sched.html compile.pl
# 	perl compile.pl -c $<
# 	cp ../spring21/index.html ../index.html

../fall21/index.html: fall21.sdb template.html sched.html compile.pl
	perl compile.pl -c $<
	cp ../fall21/index.html ../index.html


# General Makefile rule for semester page
../%/index.html: %.sdb template.html sched.html compile.pl
	perl compile.pl $<
