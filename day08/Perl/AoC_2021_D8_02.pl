use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D8.txt');

my %default_signal_patterns = (
    "abcefg" => 0,
    "cf" => 1,
    "acdeg" => 2,
    "acdfg" => 3,
    "bcdf" => 4,
    "abdfg" => 5,
    "abdefg" => 6,
    "acf" => 7,
    "abcdefg" => 8,
    "abcdfg" => 9 ,
);

my $overall_result = 0;
foreach my $line (@puzzle) {
    my %this_line_decoding = ();
    my %map_segments_to_chars = ();
    my ($signal_patterns, $output_values) = split(/\|/, $line);
    foreach my $signal_pattern (split(/\s/, $signal_patterns)) {
        if (length($signal_pattern) == 2) {
            $this_line_decoding{1} = join "", sort split //, $signal_pattern;
        }
        elsif (length($signal_pattern) == 3) {
            $this_line_decoding{7} = join "", sort split //, $signal_pattern;
        }
        elsif (length($signal_pattern) == 4) {
            $this_line_decoding{4} = join "", sort split //, $signal_pattern;
        }
        elsif (length($signal_pattern) == 7) {
            $this_line_decoding{8} = join "", sort split //, $signal_pattern;
        }
    }
    # Detect original character a
    foreach my $char (split(//,$this_line_decoding{7})) {
        next if index($this_line_decoding{1},$char) != -1;
        $map_segments_to_chars{$char} = "A";
    }

    # Detect pattern of number 9 and original character g
    foreach my $signal_pattern (split(/\s/, $signal_patterns)) {
        if (length($signal_pattern) == 6) {
            my $valid = 1;
            foreach my $char (split(//,$this_line_decoding{4})) {
                next if index($signal_pattern,$char) != -1;
                $valid = 0;
            }

            if ($valid) {
                $this_line_decoding{9} = join "", sort split //, $signal_pattern;
                foreach my $char (split(//,$this_line_decoding{9})) {
                    $map_segments_to_chars{$char} = "G" if index($this_line_decoding{4},$char) == -1 &&  !$map_segments_to_chars{$char};
                }
            }
        }
    }

    # Detect pattern of number 6 and 0 and original character d, e, f and c
    foreach my $signal_pattern (split(/\s/, $signal_patterns)) {
        $signal_pattern = join "", sort split //, $signal_pattern;
        if (length($signal_pattern) == 6 && $signal_pattern ne $this_line_decoding{9}) {
            my $is_six = 0;
            foreach my $char (split(//,$this_line_decoding{1})) {
                next if index($signal_pattern,$char) != -1;
                $is_six = 1;
            }
            $this_line_decoding{$is_six ? 6 : 0} = $signal_pattern;

            foreach my $char (split(//,$this_line_decoding{9})) {
                $map_segments_to_chars{$char} = $is_six ? "C" : "D"  if index($this_line_decoding{$is_six ? 6 : 0},$char) == -1 &&  !$map_segments_to_chars{$char};
            }

            foreach my $char (split(//,$this_line_decoding{$is_six ? 6 : 0})) {
                $map_segments_to_chars{$char} = "E"  if index($this_line_decoding{9},$char) == -1 &&  !$map_segments_to_chars{$char};
            }

            if ($is_six) {
                foreach my $char (split(//,$this_line_decoding{1})) {
                    $map_segments_to_chars{$char} = "F"  if index($this_line_decoding{6},$char) != -1 &&  !$map_segments_to_chars{$char};
                }
            }
        }
    }


    # Detect pattern of number 2, 3, 5 and original character b
    foreach my $signal_pattern (split(/\s/, $signal_patterns)) {
        $signal_pattern = join "", sort split //, $signal_pattern;
        if (length($signal_pattern) == 5) {
            my $is_two = 0;
            foreach my $char (split(//,$this_line_decoding{1})) {
                if ($map_segments_to_chars{$char} eq "F" && index($signal_pattern,$char) == -1) {
                    $is_two = 1;
                    last;
                }
            }

            if($is_two) {
                $this_line_decoding{2} = $signal_pattern;
            }
            else {
                my $is_three = 0;
                foreach my $char (split(//,$this_line_decoding{1})) {
                    if ($map_segments_to_chars{$char} eq "C" && index($signal_pattern,$char) != -1) {
                        $is_three = 1;
                        last;
                        }
                }
                $this_line_decoding{$is_three ? 3 : 5} = $signal_pattern;
                if ($is_three) {
                    foreach my $char (split(//,$this_line_decoding{4})) {
                        $map_segments_to_chars{$char} = "B"  if index($this_line_decoding{3},$char) == -1 &&  !$map_segments_to_chars{$char};
                    }
                }
            }
        }
    }

    my $multiplier = 1000;
    my $result = 0;
    foreach my $output_value (split(/\s/, $output_values)) {
        next unless $output_value;
        $output_value = join "", sort split //, $output_value;
        foreach my $key (keys %map_segments_to_chars) {
            $output_value =~ s/$key/$map_segments_to_chars{$key}/;
        }
        $output_value = join "", sort split //, lc($output_value);
        $result += $multiplier * $default_signal_patterns{$output_value};
        $multiplier /= 10;
    }

    $overall_result += $result;
}

print "Overall result:\t".$overall_result;