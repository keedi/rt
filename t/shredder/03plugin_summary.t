#!/usr/bin/perl -w

use strict;
use warnings;

use RT::Test strict => 1; use Test::More;
use Test::Deep;
use File::Spec;
use RT::Test::Shredder;

plan tests => 4;

use_ok('RT::Shredder::Plugin');
my $plugin_obj = RT::Shredder::Plugin->new;
isa_ok($plugin_obj, 'RT::Shredder::Plugin');
my ($status, $msg) = $plugin_obj->load_by_name('Summary');
ok($status, 'loaded summary plugin') or diag "error: $msg";
isa_ok($plugin_obj, 'RT::Shredder::Plugin::Summary');

