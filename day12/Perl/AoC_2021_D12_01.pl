use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D12.txt');

my %rules;
foreach my $rule (@puzzle) {
	$rule =~ s/^\s|\s$//;
	my ($start, $dest) = split("-", $rule);
	push(@{$rules{$start}}, $dest);
	push(@{$rules{$dest}}, $start);
}

my %detected_paths;

step_down_to("start", \%detected_paths, "");

say "Number of possible paths: " . scalar(keys(%detected_paths));
sub step_down_to {
	my ($point, $detected_paths, $current_path) = @_;

	# Lower case points are allowed just once
	if ($point =~ m/[a-z]/) {
		return if $current_path =~ m/(^|,)$point,/;
	}

	$current_path .= $point . ",";

	if ($point eq 'end') {
		$detected_paths->{$current_path} = 1;
		return;
	}

	# Step down the tree
	foreach my $dest (@{$rules{$point}}) {
		step_down_to($dest, $detected_paths, $current_path);
	}
}

#print Data::Dumper::Dumper(\%rules);
#print Data::Dumper::Dumper(\%detected_paths);

