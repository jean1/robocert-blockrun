#!/usr/bin/env perl

use Dancer;

use Block::Run;

use strict;
use warnings;
use utf8;

# Variables

my $dir = "/tmp";
my $cloginrc = "/local/etc/block_cloginrc";
my $cmddir = "/home/acl/bin";
my $run_as_user = "acl";

# Routeurs

our @routers = ("espla-rc1", "histo-rc1");

# Fonctions de filtrage/defiltrage

sub block {
    my ($ip, $comment) = @_ ;

    foreach my $router (@routers) {
	system("sudo -u $run_as_user $cmddir/block '$router' '$ip' '$comment' >/tmp/block.out");
    }
}

sub unblock {
    my ($ip) = @_ ;

    foreach my $router (@routers) {
	system("sudo -u $run_as_user $cmddir/unblock '$router' '$ip' >/tmp/unblock.out");
    }
}

# Map des URL
get '/filter/:hash' => sub {
    
    my $ip;
    my $ticket;
    my $hash = param('hash');

    open(FILE, "$dir/$hash") || die("ERREUR : hash inconnu");
    while(<FILE>) {
	chomp;
	($ip, $ticket) = split(/ /,$_);
    }
    close(FILE);

    # Mettre en place le bloage sur le routeur/firewall
    block($ip, "Ticket $ticket");

    # Mettre a jour le ticket

    return "l'adresse $ip a ete filtree";
};

get '/unfilter/:hash' => sub {

    my $hash = param('hash');
    my $ip;
    my $ticket;

    open(FILE, "$dir/$hash") || die("ERREUR : hash inconnu");
    while(<FILE>) {
	chomp;
	($ip, $ticket) = split(/ /,$_);
    }
    close(FILE);

    # Supprimer le blocage sur le routeur/firewall
    unblock($ip);

    # FIXME: Mettre a jour le ticket
    # mail a rt-comment
    	# commentaire + envoyer un message au corresp.

    return "l'adresse $ip a ete defiltree";
};

dance;
