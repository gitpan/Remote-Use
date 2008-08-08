use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Remote::Use',
    VERSION_FROM      => 'lib/Remote/Use.pm', # finds $VERSION
    PREREQ_PM         => { 'File::Find' => '0',
                           'File::Path' => '0', 
                           'File::Spec' => '0', 
                           'File::Basename' => '0', 
                           'Getopt::Long' => '0', 
                         },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Remote/Use.pod', # retrieve abstract from module
       AUTHOR         => 'Programacion en paralelo 2 <pp2@>') : ()),
);

sub MY::postamble {
  # To check tests in remote machines. See goal remotetest
	my @machines = qw{orion beowulf};

	# To print: see goal pdf
	my @files = (
#	'TODO',
    'lib/Remote/Use.pm',
#   'lib/Remote/Which.pm',
    'script/pminstalled.pl',

#'examples/hello.pl'
#'examples/lwpmirrorconfig'
#'examples/lwput1.pl'
#'examples/lwput2.pl'
#'examples/main.pm'
'examples/prime2.pl',
#'examples/prime3.pl'
#'examples/primeex.pl'
#'examples/prime.pl'
#'examples/reqprime.pl'
#'examples/requirelwput1.pl'
#'examples/requirersyncsynopsis2.pl'
#'examples/requireut1config.pl'
'examples/rsyncconfig',
#'examples/rsyncconfig2'
#'examples/rsyncconfig3'
#'examples/rsyncconfigadded'
#'examples/rsyncsynopsis2.pl'
#'examples/rsyncsynopsis.pl'
#'examples/rsyncut1.pl'
#'examples/rsyncut2.pl'
#'examples/salida'
#'examples/synopsis2.pl'
#'examples/synopsis.pl'
#'examples/t1.pl'
#'examples/t2.pl'
#'examples/t3.pl'
#'examples/temp.pl'
#'examples/ut1config.pl'
#'examples/ut1.pl'
#'examples/ut1rsync.pl'
#'examples/ut1wget.pl'
#'examples/ut2.pl'
#'examples/ut3.pl'
#'examples/ut4.pl'
#'examples/ut5.pl'
'examples/wgetconfig',
	);

return <<"EOT";
doc:tt2/Use.tt2
	cd tt2; tpage  Use.tt2 > ../lib/Remote/Use.pod
	cd tt2; tpage  Tutorial.tt2 > ../lib/Remote/Use/Tutorial.pod
	cd tt2; tpage  pminstalled.tt2 > ../script/pminstalled.pod

pdf: @files
	atopdf @files -o /tmp/remoteuse.pdf

publicdist: publish rmdist dist
	chmod a+r Remote-Use-*.tar.gz
	cp Remote-Use-*.tar.gz /home/pp2/public_html/perlexamples/Remote-Use.tar.gz
	cp Remote-Use-*.tar.gz /tmp/
	chmod a+r /tmp/Remote-Use-*.tar.gz

rmdist:
	rm -fR Remote-Use-*.tar.gz
	rm -fR /tmp/Remote-Use-*.tar.gz

xdvi: doc
	pod2latex -full -prefile preamblegen.tex lib/Remote/Use.pod
	latex Use
	latex Use
	makeindex Use; latex Use.tex 
	pod2latex -full -prefile preamblegen.tex lib/Remote/Use/Tutorial.pod
	latex Tutorial
	latex Tutorial
	makeindex Tutorial; latex Tutorial.tex 
	pod2latex -full -prefile preamblegen.tex script/pminstalled.pod
	latex pminstalled
	latex pminstalled
	makeindex pminstalled; latex pminstalled

html: doc
	mpod2html -nowarnings -noverbose -nonavigation -nobanner -noidx -notoc lib/Remote/Use.pod
	mpod2html -nowarnings -noverbose -nonavigation -nobanner -noidx -notoc lib/Remote/Use/Tutorial.pod
	mpod2html -nowarnings -noverbose -nonavigation -nobanner -noidx -notoc script/pminstalled.pod

publish: doc html xdvi
	cp *.html /home/pp2/public_html/Remote_Use/
	cp *.dvi /home/pp2/public_html/Remote_Use/

remotetest:
	scripts/remotetest.pl \${DISTVNAME}.tar.gz @machines
EOT
}

