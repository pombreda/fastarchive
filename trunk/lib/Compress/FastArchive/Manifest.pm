# Author: David Spadea
# Date  : November 2008 
#
# This software is released under the terms of the  PERL Artistic License.

package Compress::FastArchive::Manifest;

use DBI;
use DBD::SQLite;
use File::Temp;

use base qw(DBI);

sub new
{
	my $class = shift;
	my %opts = @_;

	my $self = $class->connect("dbi:SQLite:" . $opts{dbfile});

	unless ( $self->initdb )
	{
		warn("Manifest initdb failed. Must abort.\n" . $DBI::errstr);
		return undef;
	}

	$self->setArchiveInfo('MANIFEST', 'createtime', time);
	
	return $self;
}


package Compress::FastArchive::Manifest::db;

use base qw(DBI::db);


sub initdb {
	my $self = shift;
	my %opts = @_;

	my @sql = (

                "
	        -- basename     the name of the file immediately under the file root, and which serves as the basis of a subarchive.
	        -- subarchive	the name of the zip file that contains this set.
	        -- createtime   the archival time of the given fileset, to be populated immediately after the fileset compression completes.
	        create table filesets
	        (
		          basename	text
		        , subarchive	text
		        , createtime	timestamp
	        );

                ",
                
                "
	        -- set of key/value pairs for storing various attributes of the archive. Some of these will be standard, others
	        -- can be implementation specific.

	        --STANDARD KEYS:
	        -- createtime		int	representation of time using unix epoch
	          
	        -- Check FastZip.pm for further standard keys.
	          

	        create table archiveinfo
	        (
	                  applayer      text
		        , key		text
		        , value		text 
		        
		        , constraint ai_pk primary key (applayer, key)
	        );
	        "

        );

        map {
	        $self->do($_)
		        or return undef;
        } @sql;

	return 1;
	
}



sub _execSQL
{
	my $self = shift;
	my $sql = shift;
	my @args = @_;

	my $sth = $self->prepare($sql);

	return $sth->execute( @args );
}

sub setArchiveInfo
{
	my $self = shift;
	my ($l, $k, $v) = @_;

	# TODO: Allow re-set by doing an update if the key already exists.
	# Keys should only exist once.

	return $self->_execSQL("insert into archiveinfo(key, value) values (?, ?)", $l, $k, $v);
}

sub addFileSet
{
	my $self = shift;
	my %opts = @_;

	return $self->_execSQL("insert into filesets(basename, subarchive, createtime) values (?, ?, ?)"
		, $opts{basename}, $opts{subarchive}, time);
}

package Compress::FastArchive::Manifest::st;

use base qw(DBI::st);


1;
