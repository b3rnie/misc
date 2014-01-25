#!/usr/bin/perl -w
# Helper class for parsing and generating metrics from state transitions.
#
# use:
# my $l=FSMS->new(sub{
#                   my $line = shift;
#                   if($line=~/(date)(key)(from)(to)/){
#                     ($1,$2,$3,$4);
#                   }else{
#                     undef;
#                   }
#                 }, glob("/logs/*"));
#
# drop entries not matching 'meh' or 'blah'
# $l->filter_keys([qr/meh/, qr/blah/]);
#
# drop transitions (and possibly entries) not matching either date
# $l->filter_dates(["20130101","20130102"]);
#
# drop entries that lacks either transition
# $l->filter_transitions([["begin","end"],["foo","bar"]]);
#
# filter returns a new blessed object/array so filters can be chained together:
# my $x=$l->filter_keys(..)->filter_dates(...);
# my $length = scalar @{$x};
#
# Written by Bjorn Jensen-Urstad 2014

package FSMS;
use strict;

# files: files indexed
# sub: clojure is fed each line and needs to return
# (date, key, from, to) | undef
#
# reads transitions and index in a list with format:
# {'key' => xx,
#  'transitions' => ([date, from, to], [date, from, to])
# }
sub new{
  my($class, $sub, @files) = @_;
  my %hash;
  foreach my $file(@files){
    open my $fh, "<", $file or die "cant open $file: $!";
    while(my $line=<$fh>){
      my ($date, $key, $from, $to) = $sub->($line);
      if($date && $key && $from && $to){
        if(exists $hash{$key}){
          push $hash{$key}->{'transitions'}, [$date, $from, $to];
        }else{
	  my @t = ($date, $from, $to);
          $hash{$key} = {'key'         => $key,
                         'transitions' => ([[$date, $from, $to]])};
        }
      }
    }
    close $fh or die "cant close $file: $!";
  }
  my @l = values %hash;
  return bless \@l, $class;
}

sub do_filter{
  my($self, $sub) = @_;
  my @l;
  foreach my $h(@$self){
    if($sub->($h)){
      push @l, $h;
    }
  }
  return bless \@l, ref $self;
}

# remove transitions not matching supplied dates
# fsms with no resulting transitions are not returned
sub filter_dates{
  my($self, $dates) = @_;
  my @l;
  foreach my $h(@$self){
    my @t;
    foreach my $trans(@{$h->{'transitions'}}){
      if(grep{@$trans[0] eq $_ } @$dates ){
        push @t, $trans;
      }
    }
    if(scalar @t > 0){
      my %h2 = ('key'         => $h->{'key'},
                'transitions' => \@t);
      push @l, \%h2;
    }
  }
  return bless \@l, ref $self;
}

# remove fsms not containing atleast one of supplied patterns
sub filter_keys{
  my($self, $patterns) = @_;
  do_filter($self, sub{
              my $h=shift;
               foreach my $pat(@$patterns){
                if($h->{'key'} =~ $pat){
                  return 1;
                }
              }
              return undef;
            });
}

# remove fsms not containing atleast one of supplied transitions
sub filter_transitions{
  my($self, $transitions) = @_;
  do_filter($self, sub{
              my $h = shift;
              foreach my $trans(@{$h->{'transitions'}}){
                if(grep{@$trans[1] eq @$_[0] &&
                        @$trans[2] eq @$_[1]} @$transitions){
                  return 1;
                }
              }
              return undef;
            })
}

1;
