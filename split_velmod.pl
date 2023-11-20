#!/usr/bin/env perl
use strict;
use warnings;

@ARGV == 2 or die "splite vel mode into sta.vel list Usage: \n";
# import layer_mod here to fix lower depth
# 3dmod in format: lon, lat, depth, vp, vs
my ($dmod,$layer_mod) = @ARGV;

stream_sta_loc($dmod, $layer_mod);

sub stream_sta_loc {
    # read staloc from STDIN and out put
    # only read vel in grid
    my ($dmod,$layer_mod) = @_;
    $dmod=prepare($dmod);
    my $grid = 0.5;
    # $grid/=2;
    my ($velo, $vela,$bot, $dep, $vp, $vs);
    `mkdir -p ./vel` if(! -d "./vel");

    # after start code like perl split.....pl 3dmod layer_mod;
    # tapping sta_name stlo stla\n and output file
    while (<STDIN>) {
        chomp;my ($sta, $stlo, $stla) = split(/\s+/,$_);
        open(my $DMOD,"<$dmod");
        open(my $OUT, ">>./vel/$sta.vel");
while(<$DMOD>){
    chomp;($velo, $vela, $dep, $vp, $vs) = split(/\s+/,$_);
    next if($stlo - $velo < 0 ||$stlo - $velo > $grid );
    next if($stla - $vela < 0 ||$stla - $vela > $grid );
    #next if(abs($stlo - $velo) > $grid );
    #next if(abs($stla - $vela) > $grid) );
    $bot = $dep;
    print $OUT "$_\n";
}
    add_layer($layer_mod,$OUT,$bot);
    close $DMOD;
    close $OUT;
    }
}


sub add_layer{
    #add layer from layered_model
    my ($layer_mod, $OUT, $depth_st) = @_;
    my ($depth, $vp, $vs);
    open(my $IN, "<$layer_mod");
    while(<$IN>){
        chomp;
        ($depth, $vp, $vs) = split(/\s+/, $_);
        next if($depth<$depth_st);
        print $OUT "$depth\t$vp\t$vs\n";
    }
    close $IN;
}

sub prepare {
    my ($dmod) = @_;
    `sort -nk1 -nk2 -nk3 $dmod > tmp.vel`;
    return "tmp.vel";
}
