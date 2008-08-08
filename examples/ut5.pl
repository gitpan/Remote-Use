#!/usr/bin/perl -w -I../lib/
use strict;
use Remote::Use
  command => 'wget -o /tmp/wget.log',
  commandoptions => '-O',
  host => 'http://orion.pcg.ull.es/~casiano/cpan', 
  prefix => '/tmp/perl5lib/',
  cachefile => '/tmp/perl5lib/.orionhttp.installed.modules',
;
use Tintin::Trivial;
use Trivial;

Trivial::hello();
Tintin::Trivial::hello();

