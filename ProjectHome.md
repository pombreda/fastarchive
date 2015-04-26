Most archival programs work serially. They start with the first file and start compressing iteratively until they get to the last one.

FastArchive uses standard formats in a multithreaded way to allow you to use the power of your machine's multiple CPUs. Each top-level set of files is compressed separately and in parallel, breaking a normally serial operation into many concurrent ones.

The resulting file format is a zip-of-zips with an SQLite database listing the high-level filesets in the archive. Generally, you'd use this the same way you'd use 'zip'. You don't normally need to know the internals, but if you find yourself without a decompression program, you can extract the contents with standard 'zip' or WinZip.

This is the reference implementation, written in PERL using standard CPAN libraries.