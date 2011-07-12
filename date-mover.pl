#!/usr/bin/perl -w
## date-mover.pl - move files into subdirectories based on their last modification time

use strict;
use warnings;

use Cwd;
use File::Basename;
use File::Spec;

my %s = (
	home => Cwd::getcwd(),
	
	verbose => 1,
);


exit;
