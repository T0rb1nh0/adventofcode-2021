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

	print "\rRules left to be processed: " . scalar(@raw_rules) . "\t Final rules being found " . scalar(@final_rules);

	if ($this_rule->{remove}) {
		@final_rules = grep {$_ ne $this_rule->{remove}} @final_rules;
		next;
	};

	# Check rule against all so far verified rules
	foreach my $final_rule (@final_rules) {

		# Check if rules overlap each other completely
		my $overlap_completely = 1;
		foreach my $axe (qw(X Y Z)) {
			if ($this_rule->{"min$axe"} < $final_rule->{"min$axe"} || $this_rule->{"max$axe"} > $final_rule->{"max$axe"}) {
				$overlap_completely = 0;
				last;
			}
		}
		# They overlap completely?
		if ($overlap_completely) {
			# This rule should activate things? No need to keep this rule because all cubes are being set on already.
			if ($this_rule->{"mode"}) {
				$this_rule = undef;
				last;
			}
			else {
				$this_rule->{"mode"} = 2;
				my @rules;
				foreach my $fr (@final_rules) {
					if ($fr eq $final_rule) {
						push(@rules, $this_rule);
					}
					push(@rules, $fr);
				}
				my $new_rule = ({ %$this_rule });
				$new_rule->{remove} = $this_rule;
				unshift(@raw_rules, @rules, $new_rule);
				@final_rules = ();
				$this_rule = undef;
				last;
			}
			last;
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
			elsif ($this_rule->{"max$axe"} > $final_rule->{"max$axe"} && $this_rule->{"min$axe"} < $final_rule->{"max$axe"}) {
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

say "Number of cubes on in total: " . $cubes_on_in_total;