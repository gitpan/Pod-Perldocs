package Pod::Perldocs;
use strict;
use warnings;
require Pod::Perldoc;
use base qw(Pod::Perldoc);
our ($VERSION);
$VERSION = '0.1';

################################################################
# Change the following to reflect your setup
my $soap_uri = 'http://theoryx5.uwinnipeg.ca/Apache/DocServer';
my $soap_proxy = 'http://theoryx5.uwinnipeg.ca/cgi-bin/docserver.cgi';
###############################################################

sub grand_search_init {
    my($self, $pages, @found) = @_;
    @found = $self->SUPER::grand_search_init($pages, @found);
    return @found if @found;
    my $soap = make_soap() or return @found; # no SOAP::Lite available
    print STDERR "Searching on remote soap server ...\n";
    my $result = $soap->get_doc($pages->[0]);
    defined $result && defined $result->result or do {
        print STDERR "No matches found there either.\n";
        return @found;
    };
    my $lines = $result->result();
    unless ($lines and ref($lines) eq 'ARRAY') {
        print STDERR "Documentation not found there either.\n";
        return @found;
    }
    my ($fh, $filename) = $self->new_tempfile();
    print $fh @$lines;
    push @found, $filename;
    return @found;
}

sub make_soap {
  unless (eval { require SOAP::Lite }) {
    print STDERR "SOAP::Lite is unavailable to make remote call\n";
    return undef;
  } 

  return SOAP::Lite
    ->uri($soap_uri)
      ->proxy($soap_proxy,
	      options => {compress_threshold => 10000})
	->on_fault(sub { my($soap, $res) = @_; 
			 print STDERR "SOAP Fault: ", 
                           (ref $res ? $res->faultstring 
                                     : $soap->transport->status),
                           "\n";
                         return undef;
		       });
}

1;

=head1 NAME

Pod::Perldocs - view remote pod via Pod::Perldoc

=head1 DESCRIPTION

This is a drop-in replacement for C<perldoc> based on
C<Pod::Perldoc>. Usage is the same, except in the case
when documentation for a module cannot be found on the
local machine, in which case a query (via SOAP::Lite) will
be made to a remote pod repository and, if the documentation is
found there, the results will be displayed as usual.

=head1 NOTE

The values of C<$soap_uri> and
C<$soap_proxy> at the top of this script reflect
the location of the remote pod repository.

=head1 SERVER

See the I<CPAN-Search-Lite> project on SourceForge at
L<http://sourceforge.net/projects/cpan-search/>
for the software needed to set up a remote pod
repository used by C<perldocs>.

=head1 SEE ALSO

L<Pod::Perldoc>.

=head1 COPYRIGHT

This software is copyright 2004 by Randy Kobes
E<lt>r.kobes@uwinnipeg.caE<gt>. Usage and redistribution
is under the same terms as Perl itself.

=cut
