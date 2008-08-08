#!/usr/bin/perl -w -I../lib/
use strict;
use Remote::Use
  host => 'http://orion.pcg.ull.es/~casiano/cpan',
  command => 'wget -v -o /tmp/wget.log',
  commandoptions => '-O',
  prefix => '/tmp/perl5lib/',
  cachefile => '/tmp/perl5lib/.orionhttp.installed.modules',
;
use Tintin::Trivial;

Tintin::Trivial::hello();
