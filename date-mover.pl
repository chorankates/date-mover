#!/usr/bin/perl -w
## date-mover.pl - move files into subdirectories based on accessed/created/modified time

use strict;
use warnings;

use Cwd;
use File::Find; # not actually using this yet, but should <-- how do we want to handle recursion? should previously moved files be moved again if their mtime changes?
use File::Basename;
use File::Spec;


my %s = (
	home => Cwd::getcwd(),
	
	time => 'modified', # allow modified / accessed / created
	
	verbose => 1,
);

$s{time}  = ($s{time} eq 'created') ? 7 :
                     ($s{time} eq 'accessed') ? 8 :
					 9;
					 
$s{home} = shift @ARGV if -d $ARGV[0];
my @files = glob(File::Spec->catfile($s{home},'*'));

for my $file (@files) {
	next unless -f $file;
	# determine date of last modification
	my $fname = basename($file);
	my $key_time = (stat($file))[$s{time}];
	my @localtime = localtime($key_time);

	my $year = $localtime[5] + 1900;
	my $month = $localtime[4] + 1;
	my $day = $localtime[3];
	
	my $new_path = File::Spec->catdir($s{home}, join('-', ($year, $month, $day)));
	my $new_file = File::Spec->catdir($new_path, $fname);
	
	unless (-d $new_path) {
		my $lresults = 0;
	          $lresults = ('mkdir -p ' . $new_file) or $lresults = 1;
		warn "WARN:: unable to create '$new_path', skipping '$fname'" if $lresults;
		next;
	}
	
	my $cmd = "mv $file $new_file";
	
	my $results = system($cmd);
	
	warn "WARN:: unable to move '$file': $results" if $results;
}

exit;
