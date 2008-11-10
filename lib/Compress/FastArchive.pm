# Author: David Spadea
# Date  : November 2008 
#
# This software is released under the terms of the PERL Artistic License.


package Compress::FastArchive;

use Compress::FastArchive::Manifest;
use MultiThread;
use Thread::Queue;
use File::Temp qw(tempdir);

sub new
{
        my $class = shift;
        my %opts = shift;
        
        my $self = {};
               
        $self->{WorkQueue} = Thread::Queue->new;
        $self->{ResponseQueue} = Thread::Queue->new;
        
        $self->{WorkDir} = $opts{WorkDir} ? $opts{WorkDir} : tempdir();
        
        $self->{Manifest} = Compress::FastArchive::Manifest->new( dbfile => $self->{WorkDir} . '/manifest.sqlite' )
                or ( warn ("Unable to create manifest...\n") and return undef);
                
        return bless ($self, $class);
}

sub addFileSet
{
        my $self = shift;
        my %opts = @_;
        
        return $self->{WorkQueue}->enqueue( $opts{FileSet} );
}

sub finish
{
        my $self = shift;
        $self->{WorkerPool}->shutdown;
        return;
}

sub setArchiveInfo
{
        my $self = shift;
        return $self->_setArchiveInfo('APPLICATION', @_);
}

sub _setArchiveInfo
{
        my $self = shift;
        my ($layer, $key, $val) = @_;
        
        return $self->{Manifest}->setArchiveInfo($layer, $key, $value);
}

1;
