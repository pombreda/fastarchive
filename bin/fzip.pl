#!/usr/bin/perl

# Author: David Spadea
# Date  : November 2008 
#
#
# LICENSE:
# 
#    CODE:
#
#    This software is released under the terms of the PERL Artistic License.
#
#    COMPATIBILITY:
# 
#    This program may not be ideal for all deployments, but it should serve
#    as the reference implmentation for all other implementations. All other
#    implementations should produce archives identical in format to those
#    produced by this program, such that this program can read and extract 
#    the original contents of the file.
#
#    In the event that you extend the original file format in a compatible way,
#    you must publicly document the extensions to the file format so that the
#    extensions may be incorporated into other readers. 
#
#    The spirit of this license is that the file format and all extensions and
#    modifications must remain public and implementable by other readers. You may
#    compete by offering faster, fuller-feaured software, but not by obfuscating
#    or adding to the file format in any secret way.
#

use strict;
use warnings;

use lib qw(../lib);

use Getopt::Long;
use Data::Dumper;

use Compress::FastArchive;


my %opts;

GetOptions (
	  '--max-threads=s' => \$opts{maxthreads}
	, '--extract' => \$opts{extract}
	  
);

my %opts_deflts = (
	  extract => 0
);

map {
	$opts{$_} = $opts_deflts{$_} unless defined($opts{$_});
} keys %opts_deflts;

grep { !/^-/ } @ARGV;

my $archive = shift @ARGV;
my @files = @ARGV;

if ( $opts{extract} )
{
	my $rc =
	&extract_files(   archive => $archive
			, maxthreads => $opts{maxthreads}
			, files => \@files
		      );

	exit ($rc ? 0 : $rc);
}
else
{
	my $rc =
	&create_archive(   archive => $archive
			 , maxthreads => $opts{maxthreads}
			 , files => \@files
		       );
	exit ($rc ? 0 : $rc);
}

exit 0;


sub extract_files 
{
	my %opts = @_;

	my $archive = Compress::FastArchive->load( %opts )
		or return undef;


}

sub create_archive 
{
	my %opts = @_;

	my $archive = Compress::FastArchive->new( %opts )
		or return undef;
	
	map {
		$archive->addFileSet( $_ );
	} @{ $opts{files} };

}

