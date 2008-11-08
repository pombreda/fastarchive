# Author: David Spadea
# Date  : November 2008 
#
# This software is released under the terms of the PERL Artistic License.


package Compress::FastArchive;

use MultiThread;
use Thread::Queue;

sub new
{
        my $class = shift;
        my %opts = shift;
        
        my $self = {};
               
        $self->{WorkQueue} = Thread::Queue->new;
        $self->{ResponseQueue} = Thread::Queue->new;
        
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
        
        return $self->{manifest}->setArchiveInfo($layer, $key, $value);
}

1;
