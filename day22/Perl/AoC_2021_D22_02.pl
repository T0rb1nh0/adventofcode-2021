use strict;
use warnings FATAL => 'all';
use feature "say";
use bigint;

use File::Slurp;
use Data::Dumper;
use List::Util;

$Data::Dumper::Sortkeys = 1;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D22.txt');

my @original_rules;
my @rules_to_be_processed;
my @processed_rules;

foreach my $line (@puzzle) {
	$line =~ s/^\s+|\s+$//g;
	next unless $line;
	next unless $line =~ m/^(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)/;
	# Load original rules of the input file
	push(@original_rules, { "mode" => $1 eq 'on' ? 1 : 0, "minX" => $2, "maxX" => $3, "minY" => $4, "maxY" => $5, "minZ" => $6, "maxZ" => $7 });
}

# Just take original rules one by one to be able to print some progress information
while (@original_rules) {

    push(@rules_to_be_processed, shift(@original_rules));

    # As long as not all rules have been processed move on with the current rules before taking another one
    while (@rules_to_be_processed) {

        print "Processing next rule... (Rules left to be processed: " . scalar(@original_rules) . "; Rules created/processed successfully: " . scalar(@processed_rules) . ")\r";

        # Process next rule
        my $this_rule = shift(@rules_to_be_processed);

        if ($this_rule->{remove}) {
            @processed_rules = grep {$_ ne $this_rule->{remove}} @processed_rules;
            next;
        };

        # Check rule against all so far verified rules
        foreach my $processed_rule (@processed_rules) {

            # Check if processed rule overlaps this rule completely
            my $fr_overlaps_completely = 1;
            foreach my $axe (qw(X Y Z)) {
                if ($this_rule->{"min$axe"} < $processed_rule->{"min$axe"} || $this_rule->{"max$axe"} > $processed_rule->{"max$axe"}) {
                    $fr_overlaps_completely = 0;
                    last
                }
            }

            # Processed rule overlaps this rule completely?
            if ($fr_overlaps_completely) {
                # This rule should activate things and is some part of processed rule? No need to keep this rule because processed rule does the job.
                if ($this_rule->{"mode"}) {
                    $this_rule = undef;
                    last;
                }
                # This rule should remove things? Lets put this rule before related processed rule took place to block it accordingly
                else {
                    $this_rule->{"mode"} = 2;

                    my @new_rules_to_be_processed;
                    my @still_processed_rules;
                    my $redo = 0;
                    foreach my $fr (@processed_rules) {
                        if ($fr eq $processed_rule) {
                            $redo = 1;
                        }
                        if ($redo) {
                            push(@new_rules_to_be_processed, $fr);
                        }
                        else {
                            push(@still_processed_rules, $fr);
                        }
                    }
                    @processed_rules = @still_processed_rules;

                    my $new_rule = ({ %$this_rule });
                    $new_rule->{remove} = $this_rule;

                    unshift(@rules_to_be_processed, $this_rule, @new_rules_to_be_processed, $new_rule);

                    $this_rule = undef;
                    last;
                }
            }

            # Check if this rule overlaps processed rule completely
            if ($processed_rule->{"mode"} != 2) {
                my $tr_overlaps_completely = 1;
                foreach my $axe (qw(X Y Z)) {
                    if ($processed_rule->{"min$axe"} < $this_rule->{"min$axe"} || $processed_rule->{"max$axe"} > $this_rule->{"max$axe"}) {
                        $tr_overlaps_completely = 0;
                        last
                    }
                }

                # this rule overlaps processed rule completely?
                if ($tr_overlaps_completely) {
                    # This rule should just set things? Related rule could just get ignored because this one will do the job.
                    if ($this_rule->{"mode"}) {
                        @processed_rules = grep {$_ ne $processed_rule} @processed_rules;
                        next;
                    }
                    # Related processed rule could just get removed because this one would swipe it away anyway.
                    else {
                        @processed_rules = grep {$_ ne $processed_rule} @processed_rules;
                        next;
                    }
                }
            }

            # Check if this rule does intersect with some rule gathered before
            my $no_intersection = 0;
            foreach my $axe (qw(X Y Z)) {
                if
                ($this_rule->{"max$axe"} < $processed_rule->{"min$axe"} || $this_rule->{"min$axe"} > $processed_rule->{"max$axe"}) {
                    $no_intersection = 1;
                    last;
                }
            }

            # No intersection? Lets keep both
            next if $no_intersection;

            # Both rules do intersect? Lets create new rules for each sub block
            foreach my $axe (qw(X Y Z)) {
                if ($this_rule->{"min$axe"} < $processed_rule->{"min$axe"} && $this_rule->{"max$axe"} >= $processed_rule->{"min$axe"}) {
                    my ($new_rule1, $new_rule2) = ({ %$this_rule }, { %$this_rule });
                    $new_rule1->{"max$axe"} = $processed_rule->{"min$axe"} - 1;
                    $new_rule2->{"min$axe"} = $processed_rule->{"min$axe"};

                    unshift(@rules_to_be_processed, $new_rule1, $new_rule2);

                    $this_rule = undef;

                    last;
                }
                elsif ($this_rule->{"max$axe"} > $processed_rule->{"max$axe"} && $this_rule->{"min$axe"} <= $processed_rule->{"max$axe"}) {
                    my ($new_rule1, $new_rule2) = ({ %$this_rule }, { %$this_rule });
                    $new_rule1->{"min$axe"} = $processed_rule->{"max$axe"} + 1;
                    $new_rule2->{"max$axe"} = $processed_rule->{"max$axe"};

                    unshift(@rules_to_be_processed, $new_rule1, $new_rule2);

                    $this_rule = undef;

                    last;
                }
            }

            last;
        }
        push(@processed_rules, $this_rule) if $this_rule && $this_rule->{"mode"};
    }
}

my $cubes_on_in_total = 0;
foreach my $rule (@processed_rules) {
	my $val = 1;
	foreach my $axe (qw(X Y Z)) {
		$val *= ($rule->{"max$axe"} - $rule->{"min$axe"} + 1);
	}
	$cubes_on_in_total += $val;
}

say "\nNumber of cubes on in total: " . $cubes_on_in_total;