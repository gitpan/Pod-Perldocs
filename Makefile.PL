use strict;
use ExtUtils::MakeMaker;

my @exe_files = qw(bin/perldocs);
my %opts = (
            NAME => 'Pod::Perldocs',
            VERSION_FROM => 'lib/Pod/Perldocs.pm',
            EXE_FILES => \@exe_files,
            PL_FILES => {},
	    dist   => {
			 SUFFIX   => 'gz',
			 COMPRESS => 'gzip -9f',
			},
	   );

if ($ExtUtils::MakeMaker::VERSION >= 5.43) {
   $opts{ABSTRACT_FROM} = 'lib/Pod/Perldocs.pm';
   $opts{AUTHOR} = 'Randy Kobes <r.kobes@uwinnipeg.ca>';
}

my %prereqs = ('Pod::Perldoc' => 0,
               'SOAP::Lite' => 0.60,
	       );

WriteMakefile( %opts, PREREQ_PM => \%prereqs);

print <<'END';

The supplied test just verifies that the module loads OK.

END
