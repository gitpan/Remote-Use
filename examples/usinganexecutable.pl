#!/usr/bin/perl -I../lib -w
use strict;
use Remote::Use config => 'wgetwithbinconfig';
use Parse::Eyapp;
use Parse::Eyapp::Treeregexp;

system('eyapp -h');
