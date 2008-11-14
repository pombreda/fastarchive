# Author: David Spadea
# Date  : November 2008 
#
# This software is released under the terms of the PERL Artistic License.


package Compress::FastArchive;

use Compress::FastArchive::Manifest;
use MultiThread;
use Thread::Queue;
use File::Temp qw(tempdir);
use Data::Dumper;

sub new
{
        my $class = shift;
        my %opts = shift;
        
        my $self = {};
               
        $self->{MaxThreads} = $opts{maxthreads};
        
        $self->{WorkDir} = $opts{WorkDir} ? $opts{WorkDir} : tempdir();
        
        $self->{Manifest} = Compress::FastArchive::Manifest->new( dbfile => $self->{WorkDir} . '/manifest.sqlite' )
                or ( warn ("Unable to create manifest...\n") and return undef);
                
        $self = bless ($self, $class);
        
        $self->startCompressors;
        
        map {
                $self->addFileSet($_);
        } @{ $opts{FileSets} }
                
        return $self;
}

sub startCompressors
{
        my $self = shift;
        
        $self->{WorkerPool} = MultiThread::WorkerPool->new(  EntryPoint => \&compressFileSet
                                                           , MaxWorkers => $self->{MaxThreads}
                                                           )
}

# This is the thread entry point. It is responsible for consuming requests and
# effecting the compression.

sub compressFileSet
{
        my $request = shift;
        print Dumper($request);
        return 1;
}

sub addFileSet
{
        my $self = shift;
        my %opts = @_;
        
        return $self->{WorkerPool}->enqueue( $opts{FileSet} );
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
