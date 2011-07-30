#!/usr/bin/perl -w
## date-mover.pl - move files into subdirectories based on accessed/created/modified time

use strict;
use warnings;

use Cwd;
use File::Find; # not actually using this yet, but should <-- how do we want to handle recursion? should previously moved files be moved again if their mtime changes?
use File::Basename;
use File::Spec;
use Getopt::Long;

my %s = (
	home    => Cwd::getcwd(),
	verbose => 1,

	time      => 'modified', # allow modified / accessed / created
	recursion => 1,          # right now boolean, may expand in the future
	filemask  => '*',        # _file_ mask, will not match against path. * = .*
);

GetOptions(\%f, "help", "home:s", "verbose:i", "time:s", "recursion:i", "filemask:s");
$s{$_} = $f{$_} foreach (keys %s);

$s{time}  = ($s{time} eq 'created')  ? 7 :
            ($s{time} eq 'accessed') ? 8 :
									   9;

# handle multiple directories (asterisk separated values)
if ($s{home} =~ /\*/) { 
	@{$s{dirs}} = split('*', $s{home});	
} else {
	push @{$s{dirs}}, $s{home};
}

my @files = get_files($s{dirs}, $s{filemask}, $s{recursion});

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
	       $lresults = system('mkdir -p ' . $new_file) or $lresults = $?;

		if ($lresults) { 
			warn "WARN:: unable to create '$new_path', skipping '$fname'" if $lresults;
			next;
		}
	    # end of directory creation
	}

	
	my $cmd = "mv $file $new_file";
	
	my $results = system($cmd);
	
	warn "WARN:: unable to move '$file': $results" if $results;
}

exit;

## subs below

sub get_files {
	# get_files($directory, $filemask, $recursion) - returns @array of FFPs that match specifications
    # if $directory is an array ref, returned array will include all unique filepaths in all directories specified
	## do we want to return a hash populated with filename, ffp, and all time fields here? -- not until there is only one search mechanism, don't want to support File::Find and glob() 
	my ($directory, $filemask, $recursion) = @_;
	my (@dirs, @files);

	if (ref $directory eq 'ARRAY') { 
		@dirs = @{$directory};
	} else {
		@dirs = ($directory);
	}

	$filemask = '*' unless defined $filemask;
	$recursion = 0  unless defined $recursion;

	for my $directory (@dirs) {

		if ($recursion) { 
			# could use the recursive glob written for ClassPath
        	$filemask =~ s/\./\.\*/g; # simplistic glob->regex conversion

			find(
				sub {
					return if -d $_;

					my $ffp   = $File::Find::name;
					my $fname = $_;

					return unless -f $_;
					return unless $name =~ /$filemask/i; # do we want to provide an option for /i? 
		  	 	 	push @files, $ffp;

					}, $directory
		   	 );

		} else {
			# could write a non-recursive File::Find call instead..

			@files = glob(File::Spec->catfile($directory, $filemask));
	    }

	# end of dir loop
	}

	return @files;
}

sub help {
	# help() - displays some useful information about usage

	warn "WARN:: documentation has not been written";

    exit 0;
}

