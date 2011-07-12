#!/usr/bin/perl -w
## date-mover.pl - move files into subdirectories based on their last modification time

use strict;
use warnings;

use Cwd;
use File::Find; # not actually using this yet, but should
use File::Basename;
use File::Spec;


my %s = (
	home => Cwd::getcwd(),
	
	verbose => 1,
);

my @files = glob(File::Spec->catfile($s{home},'*'));

for my $file (@files) {
	next unless -f $file;
	# determine date of last modification
	my $fname = basename($file);
	my $modified_time = (stat($file))[9]; # 7 is created, 8 is accessed
	my @localtime = localtime($modified_time);
	
	my $year = $localtime[5] + 1900;
	my $month = $localtime[4] + 1;
	my $day = $localtime[3];
	
	my $new_path = join('-', ($year, $month, $day));
	my $new_file = File::Spec->catdir($s{home}, $new_path, $fname);
	
	my $cmd = "mv $file $new_file";
	
	my $results = system($cmd);
	
	warn "WARN:: unable to move '$file': $results" if $results;
}

exit;
