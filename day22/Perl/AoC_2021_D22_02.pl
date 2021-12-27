use strict;
use warnings FATAL => 'all';
use feature "say";

use File::Slurp;
use Data::Dumper;
use List::Util;

$Data::Dumper::Sortkeys = 1;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D22.txt');

my @raw_rules;

foreach my $line (@puzzle) {
	$line =~ s/^\s+|\s+$//g;
	next unless $line;
	next unless $line =~ m/^(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)/;
	# Load raw rules of the input file
	push(@raw_rules, { "mode" => $1 eq 'on' ? 1 : 0, "minX" => $2, "maxX" => $3, "minY" => $4, "maxY" => $5, "minZ" => $6, "maxZ" => $7 });
}

# Store final rules of cubes which are just on
my @final_rules;
# As long as not all raw rules have been processed move on
while (@raw_rules) {
	# Process next rule
	my $this_rule = shift(@raw_rules);

	print "Calculating result... (" . scalar(@raw_rules) . ";" . scalar(@final_rules) . ")\r";

	if ($this_rule->{remove}) {
		@final_rules = grep {$_ ne $this_rule->{remove}} @final_rules;
		next;
	};

	# Check rule against all so far verified rules
	foreach my $final_rule (@final_rules) {

		# Check if final rule overlaps this rule completely
		my $fr_overlaps_completely = 1;
		foreach my $axe (qw(X Y Z)) {
			if ($this_rule->{"min$axe"} < $final_rule->{"min$axe"} || $this_rule->{"max$axe"} > $final_rule->{"max$axe"}) {
				$fr_overlaps_completely = 0;
				last
			}
		}

		# Final rule overlaps this rule completely?
		if ($fr_overlaps_completely) {
			# This rule should activate things and is some part of final rule? No need to keep this rule because final rule does the job.
			if ($this_rule->{"mode"}) {
				$this_rule = undef;
				last;
			}
			# This rule should remove things? Lets put this rule before related final rule took place to block it accordingly
			else {
				$this_rule->{"mode"} = 2;

				my @new_raw_rules;
				my @still_final_rules;
				my $redo = 0;
				foreach my $fr (@final_rules) {
					if ($fr eq $final_rule) {
						$redo = 1;
					}
					if ($redo) {
						push(@new_raw_rules, $fr);
					}
					else {
						push(@still_final_rules, $fr);
					}
				}
				@final_rules = @still_final_rules;

				my $new_rule = ({ %$this_rule });
				$new_rule->{remove} = $this_rule;

				unshift(@raw_rules, $this_rule, @new_raw_rules, $new_rule);

				$this_rule = undef;
				last;
			}
		}

		# Check if this rule overlaps final rule completely
		if ($final_rule->{"mode"} != 2) {
			my $tr_overlaps_completely = 1;
			foreach my $axe (qw(X Y Z)) {
				if ($final_rule->{"min$axe"} < $this_rule->{"min$axe"} || $final_rule->{"max$axe"} > $this_rule->{"max$axe"}) {
					$tr_overlaps_completely = 0;
					last
				}
			}

			# this rule overlaps final rule completely?
			if ($tr_overlaps_completely) {
				# This rule should just set things? Related rule could just get ignored because this one will do the job.
				if ($this_rule->{"mode"}) {
					@final_rules = grep {$_ ne $final_rule} @final_rules;
					next;
				}
				# Related final rule could just get removed because this one would swipe it away anyway.
				else {
					@final_rules = grep {$_ ne $final_rule} @final_rules;
					next;
				}
			}
		}

		# Check if this rule does intersect with some rule gathered before
		my $no_intersection = 0;
		foreach my $axe (qw(X Y Z)) {
			if
			($this_rule->{"max$axe"} < $final_rule->{"min$axe"} || $this_rule->{"min$axe"} > $final_rule->{"max$axe"}) {
				$no_intersection = 1;
				last;
			}
		}

		# No intersection? Lets keep both
		next if $no_intersection;

		# Both rules do intersect? Lets create new rules for each sub block
		foreach my $axe (qw(X Y Z)) {
			if ($this_rule->{"min$axe"} < $final_rule->{"min$axe"} && $this_rule->{"max$axe"} >= $final_rule->{"min$axe"}) {
				my ($new_rule1, $new_rule2) = ({ %$this_rule }, { %$this_rule });
				$new_rule1->{"max$axe"} = $final_rule->{"min$axe"} - 1;
				$new_rule2->{"min$axe"} = $final_rule->{"min$axe"};

				unshift(@raw_rules, $new_rule1, $new_rule2);

				$this_rule = undef;

				last;
			}
			elsif ($this_rule->{"max$axe"} > $final_rule->{"max$axe"} && $this_rule->{"min$axe"} <= $final_rule->{"max$axe"}) {
				my ($new_rule1, $new_rule2) = ({ %$this_rule }, { %$this_rule });
				$new_rule1->{"min$axe"} = $final_rule->{"max$axe"} + 1;
				$new_rule2->{"max$axe"} = $final_rule->{"max$axe"};

				unshift(@raw_rules, $new_rule1, $new_rule2);

				$this_rule = undef;

				last;
			}
		}

		last;
	}
	push(@final_rules, $this_rule) if $this_rule && $this_rule->{"mode"};
}

my $cubes_on_in_total = 0;
foreach my $rule (@final_rules) {
	my $val = 1;
	foreach my $axe (qw(X Y Z)) {
		$val *= ($rule->{"max$axe"} - $rule->{"min$axe"} + 1);
	}
	$cubes_on_in_total += $val;
}

say "\nNumber of cubes on in total: " . $cubes_on_in_total;