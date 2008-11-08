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
use Sys::CPU;
use Data::Dumper;

use Compress::FastArchive;
use Compress::FastArchive::Manifest;

my %opts;

GetOptions (
	  '--max-threads=s' => \$opts{maxthreads}
	, '--extract' => \$opts{extract}
	  
);

my %opts_deflts = (
	  maxthreads => &getNumCPUs()
	, extract => 0
);

map {
	$opts{$_} = $opts_deflts{$_} unless defined($opts{$_});
} keys %opts_deflts;

grep { !/^-/ } @ARGV;

my $archive = shift @ARGV;
my @files = @ARGV;

print join("\n", @files) . "\n";

my $manifest = Compress::FastArchive::Manifest->new( dbfile => '/home/dave/Desktop/testManifest.sqlite' )
        or die ("Unable to create manifest...\n");
        
print Dumper($manifest);

$manifest->setArchiveInfo( 'backuptag',  'testing manifest object.' )
        or die ("Unable to set backuptag.");
$manifest->addFileSet( basename => '/home/dave/Desktop', subarchive => 'fileset-1.zip' );
$manifest->addFileSet( basename => '/home/dave/dev', subarchive =>  'fileset-2.zip' );

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


sub getNumCPUs
{
	return Sys::CPU::cpu_count();
}

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

}

