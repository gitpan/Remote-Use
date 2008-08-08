package Remote::Use;
use strict;
use warnings;

use File::Path;
use File::Spec;
use File::Basename;

use Scalar::Util qw{reftype};

our $VERSION = '0.02';

sub filename2modname {
  my $config = shift;

  my $confid = $config;
  $confid =~ s{/}{::}g;
  $confid =~ s{\.pm$}{};
  return $confid;
}

sub setinstallation {
  my $self = shift;
  
  $self->{cache} = {};
  if (-e $self->{ppmdf}) {
    if (open(my $f, $self->{ppmdf})) {
      local $/ = undef;
      my $s = <$f>;
      my @s = eval $s;
      die "Error evaluating cache file: $@" if $@;
      $self->{cache} = { @s };
    }
  }
}

sub import {
  my $module = shift;
  my %arg = @_;

  my $config = $arg{config};

  my $self = __PACKAGE__->new();
  push @INC, $self;
  if (defined($config) && -r $config) {
    eval {
      require $config;
    };
    die "Error in $config: $@" if $@;
    my $confid = filename2modname($config);

    $self->{confid} = $confid;
    %arg = $confid->getarg($self);
  }

  # host is the machine where to look for
  my $host = $arg{host};
  die "Provide a host" unless defined $host;
  delete $arg{host};
  $self->{host} = $host;

  my $perl5lib = "$ENV{HOME}/perl5lib" if $ENV{HOME};
  $perl5lib    = "$ENV{USERPROFILE}/perl5lib" if !$perl5lib && $ENV{USERPROFILE};

  my $prefix = $self->{prefix} = ($arg{prefix} || $perl5lib || File::Spec->tmpdir);
  die "Provide a prefix directory" unless defined $prefix;
  delete $arg{prefix};

  mkpath($prefix) unless -d $prefix;
  unshift @INC, $prefix;

  my $ppmdf = $arg{ppmdf};
  die "Provide a .installed.modules filename (ppmdf argument)" unless defined $ppmdf;
  delete $arg{ppmdf};
  $self->{ppmdf} = $ppmdf;

  $self->setinstallation;

  my $command = $arg{command};
  die "Provide a command" unless defined $command;
  $self->{command} = $command;
  delete $arg{command};

  # TODO: If 'method' (wget, lwpmirror) isn't defined find a suitable method ...
  $self->{$_} = $arg{$_} for keys(%arg); 
}

sub Remote::Use::INC {
  my ($self, $filename) = @_;

  if ($filename =~ m{^[\w/\\]+\.pm$}) {
    my $prefix = $self->{prefix};
    my $host = $self->{host};

    my $command = $self->{command};
    # Use open3 here
    my $commandoptions = $self->{commandoptions} || '';

    my %files;
    my $entry = $self->{cache}{$filename};
    %files = %{$entry} if $entry && (reftype($entry) eq 'HASH');

    return unless %files;

    my $remoteprefix = quotemeta($files{dir});
    delete $files{dir};

    my $f = $files{files};
    delete $files{files};
    my @files;
    @files= @$f if $f && (reftype($f) eq 'ARRAY');
    for (@files) {
       #my $url = $self->{findurl}->($self, $_, $remoteprefix); #"$host:$_";
       my $url = "$host$_";
       my $file = $_;
       $file =~ s{^$remoteprefix}{$prefix};

       my $path =  dirname($file);
       mkpath($path) unless -d $path;

       system("$command $url $commandoptions $file");
    }

    my $conf = $self->{confid}; # configuration package name

    # Find if there are alternative families of files (bin, man, etc.)
    my @families = keys %files;
    for (@families) {
      my $f = $files{$_}; # [ '/usr/local/bin/eyapp', '/usr/local/bin/treereg' ]
      my @files;          # ( '/usr/local/bin/eyapp', '/usr/local/bin/treereg' )
      @files = @$f if $f && (reftype($f) eq 'ARRAY');

      for my $b (@files) {
         my $url = "$host$b"; # 'orion:/usr/local/bin/eyapp'
         my $file = $b;                 # name in the client:
         $file =~ s{^.*/}{$prefix/$_/}; #   /tmp/perl5lib/bin/eyapp

         my $pre = "pre$_";
         $file = $conf->$pre($url, $file, $self) if ($conf->can($pre));

         my $path =  dirname($file);
         mkpath($path) unless -d $path;

         system("$command $url $commandoptions $file");
         my $post = "post$_";
         $conf->$post($file, $self) if ($conf->can($post));
      }
    }

     open my $fh, '<', "$prefix/$filename";
     return $fh;
  }

  return undef;
}

sub new {
  my $this = shift;
  my $class = ref($this) || $this;

  return bless { @_ }, $class;
}

1;
__END__
