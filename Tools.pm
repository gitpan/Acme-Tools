package Acme::Tools;

our $VERSION = '0.11';

use 5.008;
use strict;
#use warnings;
use Carp;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(
 min
 max
 sum
 avg
 geomavg
 stddev
 median
 percentile
 random
 nvl
 replace
 decode
 decode_num
 between
 distinct
 in
 in_num
 uniq
 union
 minus
 intersect
 not_intersect
 mix
 zip
 subhash
 hashtrans
 zipb64
 zipbin
 unzipb64
 unzipbin
 gzip
 gunzip
 bzip2
 bunzip2
 ipaddr
 ipnum
 webparams
 urlenc
 urldec
 ht2t
 chall
 makedir
 qrlist
 ansicolor
 ccn_ok
 KID_ok
 writefile
 readfile
 readdirectory
 range
 permutations
 trigram
 cart
 reduce
 int2roman
 num2code
 code2num
 gcd
 lcm
 pivot
 tablestring
 upper
 lower
 dserialize
 serialize
 easter
 time_fp
 sleep_fp
);

=head1 NAME

Acme::Tools - Lots of more or less useful subs lumped together and exported into your namespace

=head1 SYNOPSIS

 use Acme::Tools;

 print sum(1,2,3);                   # 6
 print avg(2,3,4,6);                 # 3.75

 my @list = minus(\@listA, \@listB); # set operations
 my @list = union(\@listA, \@listB); # set operations

 print length(gzip("abc" x 1000));   # far less than 3000

 writefile("/dir/filename",$string); # convenient
 my $s=readfile("/dir/filename");    # also conventient

 print "yes!" if between($pi,3,4);

 print percentile(0.05, @numbers);

 my @even = range(1000,2000,2);      # even numbers between 1000 and 2000
 my @odd  = range(1001,2001,2);

 my $dice = random(1,6);
 my $color = random(['red','green','blue','yellow','orange']);

 ...and so on.

=head1 ABSTRACT

Useful subroutines for perl exported into the using namespace.

=head1 DESCRIPTION

A set of more or less useful subs collected for some time...

=head1 EXPORT

Almost every sub, about 60 of them.

Beware of name space pollution. But what did you expect from an acme module?

=head1 NUMBER, SETS, STATISTICS

=head2 min

Returns the smallest in a list of numbers. Undef is ignored.

 @lengths=(2,3,5,2,10,5);
 $shortest = min(@lengths);   # 2

=cut

sub min
{
  my $min;
  for(@_){ $min=$_ if defined($_) and !defined($min) || $_<$min }
  $min;
}

=head2 max

Returns the largest in a list of numbers. Undef is ignored.

 @heights=(123,90,134,132);
 $highest = max(@heights);   # 134

=cut

sub max
{
  my $max;
  for(@_){ $max=$_ if defined($_) and !defined($max) || $_>$max }
  $max;
}

=head2 sum

Returns the sum of a list of numbers.

 print sum(1,3,undef,8);   # 12

=cut

sub sum
{
  my $sum; no warnings;
  $sum+=$_ for @_;
  $sum;
}

=head2 avg

Returns the I<average> number of a list of numbers. That is C<sum / count>

 print avg(2, 4, 9);   # 5              (2+4+9) / 3 = 5

Also known as I<arithmetic mean>.

=cut

sub avg
{
  my $sum=0;
  no warnings;
  $sum+=$_ for @_;
  return $sum/@_ if @_>0;
  return undef;
}

=head2 geomavg

Returns the I<geometric average> (a.k.a I<geometric mean>) of a list of numbers.

 print geomavg(10,100,1000,10000,100000);               # 1000
 print 0+ (10*100*1000*10000*100000) ** (1/5);          # 1000 same thing
 print exp(avg(map log($_),10,100,1000,10000,100000));  # 1000 same thing, this is how geomavg() works internally


=cut

sub geomavg { exp(avg(map log($_),@_)) }

=head2 stddev

C<< Standard_Deviation = sqrt(varians) >>

C<< Varians = ( sum (x[i]-Avgerage)**2)/(n-1) >>

Standard deviation (stddev) is a measurement of the width of a normal
distribution where one stddev on each side of the mean covers 68% and
two stddevs 95%.  Normal distributions are sometimes called Gauss curves
or Bell shapes.

=cut

sub stddev
{
  my $sumx2; $sumx2+=$_*$_ for @_;
  my $sumx; $sumx+=$_ for @_;
  sqrt( (@_*$sumx2-$sumx*$sumx)/(@_*(@_-1)) );
}

=head2 median

Returns the median value of a list of numbers. The list don't have to
be sorted.

Example 1, list having an odd number of numbers:

 print median(1, 100, 101);   # 100

100 is the middlemost number after sorting.

Example 2, an even number of numbers:

 print median(1005, 100, 101, 99);   # 100.5

100.5 is the average of the two middlemost numbers.

=cut

sub median
{
  no warnings;
  my @list = sort {$a<=>$b} @_;
  my $n=@list;
  $n%2
    ? $list[($n-1)/2]
    : ($list[$n/2-1] + $list[$n/2])/2;
}

=head2 percentile

Returns one or more percentiles of a list of numbers.

Percentile 50 is the same as the I<median>, percentile 25 is the first
quartile, 75 is the third quartile.

B<Input:>

First argument states the wanted percentile, or a list of percentiles you want from the dataset.

If the first argument to percentile() is a scalar, this percentile is returned.

If the first argument is a reference to an array, then all those percentiles are returned as an array.

Second, third, fourth and so on argument to percentile() are the data
of which you want to find the percentile(s).

B<Examples:>

This finds the 50-percentile (the median) to the four numbers 1, 2, 3 and 4:

 print "Median = " . percentile(50, 1,2,3,4);   # 2.5

This:

 @data=(11, 5, 3, 5, 7, 3, 1, 17, 4, 2, 6, 4, 12, 9, 0, 5);
 @p = map percentile($_,@data), (25, 50, 75);

Is the same as this:

 @p = percentile([25, 50, 75], @data);

But the latter is faster, especially if @data is large since it sorts
the numbers only once internally.

B<Example:>

Data: 1, 4, 6, 7, 8, 9, 22, 24, 39, 49, 555, 992

Average (or mean) is 143

Median is 15.5 (which is the average of 9 and 22 who both equally lays in the middle)

The 25-percentile is 6.25 which are between 6 and 7, but closer to 6.

The 75-percentile is 46.5, which are between 39 and 49 but close to 49.

Linear interpolation is used to find the 25- and 75-percentile and any
other x-percentile which doesn't fall exactly on one of the numbers in
the set.

B<Interpolation:>

As you saw, 6.25 are closer to 6 than to 7 because 25% along the set of
the twelve numbers is closer to the third number (6) than to he fourth
(7). The median (50-percentile) is also really interpolated, but it is
always in the middle of the two center numbers if there are an even count
of numbers.

However, there is two methods of interpolation:

Example, we have only three numbers: 5, 6 and 7.

Method 1: The most common is to say that 5 and 7 lays on the 25- and
75-percentile. This method is used in Acme::Tools.

Method 2: In Oracle databases the least and greatest numbers
always lay on the 0- and 100-percentile.

As an argument on why Oracles (and others?) definition is wrong is to
look at your data as for instance temperature measurements.  If you
place the highest temperature on the 100-percentile you are sort of
saying that there can never be a higher temperatures in future measurements.

A quick non-exhaustive Google survey suggests that method one is most
commonly used.

The larger the data sets, the less difference there is between the two methods.

B<Extrapolation:>

In method one, when you want a percentile outside of any possible
interpolation, you use the smallest and second smallest to extrapolate
from. For instance in the data set C<5, 6, 7>, if you want an
x-percentile of x < 25, this is below 5.

If you feel tempted to go below 0 or above 100, C<percentile()> will
I<die> (or I<croak> to be more precise)

Another method could be to use "soft curves" instead of "straight
lines" in interpolation. Maybe B-splines or Bezier curves. This is not
used here.

For large sets of data Hoares algorithm would be faster than the
simple straightforward implementation used in C<percentile()>
here. Hoares don't sort all the numbers fully.

B<Differences between the two main methods described above:>

 Data: 1, 4, 6, 7, 8, 9, 22, 24, 39, 49, 555, 992

 Percentile  Method 1                    Method 2
             (Acme::Tools::percentile  (Oracle)
             and others)
 ----------- --------------------------- ---------
 0           -2                          1
 1           -1.61                       1.33
 25          6.25                        6.75
 50 (median) 15.5                        15.5
 75          46.5                        41.5
 99          1372.19                     943.93
 100         1429                        992

Found like this:

 perl -MAcme::Tools -le 'print for percentile([0,1,25,50,75,99,100], 1,4,6,7,8,9,22,24,39,49,555,992)'

And like this in Oracle:

 create table tmp (n number);
 insert into tmp values (1); insert into tmp values (4); insert into tmp values (6);
 insert into tmp values (7); insert into tmp values (8); insert into tmp values (9);
 insert into tmp values (22); insert into tmp values (24); insert into tmp values (39);
 insert into tmp values (49); insert into tmp values (555); insert into tmp values (992);
 select
   percentile_cont(0.00) within group(order by n) per0,
   percentile_cont(0.01) within group(order by n) per1,
   percentile_cont(0.25) within group(order by n) per25,
   percentile_cont(0.50) within group(order by n) per50,
   percentile_cont(0.75) within group(order by n) per75,
   percentile_cont(0.99) within group(order by n) per99,
   percentile_cont(1.00) within group(order by n) per100
 from tmp;

Oracle also provides a similar function: percentile_disc where I<disc>
is short for I<discrete>, meaning no interpolation is taking
place. Instead the closest number from the data set is picked.

=cut

sub percentile
{
  my(@p,@t,@ret);
  if(ref($_[0]) eq 'ARRAY'){ @p=@{shift()} }
  elsif(not ref($_[0]))    { @p=(shift())  }
  else{croak()}
  @t=@_;
  return if not @p;
  croak if not @t;
  @t=sort{$a<=>$b}@t;
  push@t,$t[0] if @t==1;
  for(@p){
    die if $_<0 or $_>100;
    my $i=(@t+1)*$_/100-1;
    push@ret,
      $i<0       ? $t[0]+($t[1]-$t[0])*$i:
      $i>$#t     ? $t[-1]+($t[-1]-$t[-2])*($i-$#t):
      $i==int($i)? $t[$i]:
                   $t[$i]*(int($i+1)-$i) + $t[$i+1]*($i-int($i));
  }
  return @p==1 ? $ret[0] : @ret;
}

#=head1 SQL INSPIRED FUNCTIONS
#Inspired from Oracles SQL.

=head2 nvl

The no value function (or null value function)

C<nvl()> takes two or more arguments. (Oracles take just two)

Returns the value of the first input argument with length > 0.

Return undef if no such input argument.

In perl 5.10 and perl 6 this will most often be easier with the C< //
> operator, although C<nvl()> and C<< // >> treats empty strings C<"">
differently. Sub nvl here considers empty strings and undef the same.

=cut

sub nvl
{
  return $_[0] if defined $_[0] and length($_[0]) or @_==1;
  return $_[1] if @_==2;
  return nvl(@_[1..$#_]) if @_>2;
  return undef;
}

=head2 replace

Return the string in the first input argument, but where pairs of search-replace strings (or rather regexes) has been run.

Works as C<replace()> in Oracle, or rather regexp_replace() in Oracle 10. Except C<replace()> here can take more than three arguments.

Examples:

 print replace("water","ater","ine");  # Turns water into wine
 print replace("water","ater");        # w
 print replace("water","at","eath");   # weather
 print replace("water","wa","ju",
                       "te","ic",
                       "x","y",        # No x is found, no y is returned
                       'r$',"e");      # Turns water into juice. 'r$' says that the r it wants
                                       # to change should be the last letters. This reveals that
                                       # second, fourth, sixth and so on argument is really regexs,
                                       # not normal strings. So use \ (or \\ inside "") to protect
                                       # special characters of regexes.

 print replace('JACK and JUE','J','BL'); # prints BLACK and BLUE
 print replace('JACK and JUE','J');      # prints ACK and UE
 print replace("abc","a","b","b","c");   # prints ccc           (not bcc)

If the first argument is a reference to a scalar variable, that variable is changed "in place".

Example:

 my $str="test";
 replace(\$str,'e','ee','s','S');
 print $str;                         # prints teeSt

=cut

sub replace
{
  my $str=shift;
  return $$str=replace($$str,@_) if ref($str) eq 'SCALAR';
  while(@_){
    my($fra,$til)=(shift,shift);
    defined $til ? $str=~s/$fra/$til/g : $str=~s/$fra//g;
  }
  return $str;
}

=head2 decode_num

See L</decode>.

=head2 decode

C<decode()> and C<decode_num()> works just as Oracles C<decode()>.

C<decode()> and C<decode_num()> accordingly uses perl operators C<eq> and C<==> for comparison.

Examples:

 $a=123;
 print decode($a, 123,3, 214,4, $a);     # prints 3

Explanation:

The first argument is tested against the second, fourth, sixth and so
on argument, and then the third, fifth, seventh and so on argument is
returned if decode() finds an equal string or number.

In the above example: 123 maps to 3, 124 maps to 4 and the last argument ($a) is returned if C<decode> as the last resort if every other fails.

Since the operator C<< => >> is synonymous to the comma operator, the above example is probably more readable rewritten like this:

 my $a=123;
 print decode($a, 123=>3, 214=>4, $a);   # 3

More examples:

 my $a=123;
 print decode($a, 123=>3, 214=>7, $a);              # also 3,  note that => is synonym for C<,> (comma) in perl
 print decode($a, 122=>3, 214=>7, $a);              # prints 123
 print decode($a,  123.0 =>3, 214=>7);              # prints 3
 print decode($a, '123.0'=>3, 214=>7);              # prints nothing (undef), no last argument default value here
 print decode_num($a, 121=>3, 221=>7, '123.0','b'); # prints b


Sort of:

 decode($string, @pairs, $defalt);

The last argument is returned as a default if none of the keys in the keys/value-pairs matched.

=cut

sub decode
{
  croak "Must have a mimimum of two arguments" if @_<2;
  my $uttrykk=shift;
  if(defined$uttrykk){ shift eq $uttrykk and return shift or shift for 1..@_/2 }
  else               { not defined shift and return shift or shift for 1..@_/2 }
  return shift;
}

sub decode_num
{
  croak "Must have a mimimum of two arguments" if @_<2;
  my $uttrykk=shift;
  if(defined$uttrykk){ shift == $uttrykk and return shift or shift for 1..@_/2 }
  else               { not defined shift and return shift or shift for 1..@_/2 }
  return shift;
}

=head2 between

Input: Three arguments.

Returns: Something I<true> if the first argument is numerically between the two next.

=cut

sub between
{
  my($test,$fom,$tom)=@_;
  no warnings;
  return $fom<$tom ? $test>=$fom&&$test<=$tom
                   : $test>=$tom&&$test<=$fom;
}

=head1 ARRAYS, HASHES

=head2 distinct

Returns the values of the input list, sorted alfanumerically, but only
one of each value. This is the same as L</uniq> except uniq does not
sort the returned list.

Example:

 print join(", ", distinct(4,9,3,4,"abc",3,"abc"));    # 3, 4, 9, abc
 print join(", ", distinct(4,9,30,4,"abc",30,"abc"));  # 30, 4, 9, abc       note: alphanumeric sort

=cut

sub distinct { return sort keys %{{map {($_,1)} @_}} }

=head2 in

Returns I<1> (true) if first argument is in the list of the remaining arguments. Uses the perl-operator C<< eq >>.

Otherwise it returns I<0> (false).

 print in(  5,   1,2,3,4,6);         # 0
 print in(  4,   1,2,3,4,6);         # 1
 print in( 'a',  'A','B','C','aa');  # 0
 print in( 'a',  'A','B','C','a');   # 1

I guess in perl 5.10 or perl 6 you would use the C<< ~~ >> operator instead.

=head2 in_num

Just as sub L</in>, but uses perl operator C<< == >> instead. For numbers.

Example:

 print in(5000,  '5e3',);     # 0
 print in_num(5000, '5e3');   # 1

=cut

sub in
{
  no warnings 'uninitialized';
  my $val=shift;
  for(@_){ return 1 if $_ eq $val }
  return 0;
}

sub in_num
{
  no warnings 'uninitialized';
  my $val=shift;
  for(@_){ return 1 if $_ == $val }
  return 0;
}

=head2 union

Input: Two arrayrefs. (Two lists, that is)

Output: An array containing all elements from both input lists, but no element more than once even if it occurs twice or more in the input.

Example, prints 1,2,3,4:

 perl -MAcme::Tools -le 'print join ",", union([1,2,3],[2,3,3,4,4])'

=cut

sub union
{
  my %seen;
  return grep{!$seen{$_}++}(@{shift()},@{shift()});
}

=head2 minus

Input: Two arrayrefs.

Output: An array containing all elements in the first input array but not in the second.

Example:

 perl -MAcme::Tools -le ' print join " ", minus( ["five", "FIVE", 1, 2, 3.0, 4], [4, 3, "FIVE"] )'

Output is C<< five 1 2 >>.

=cut

sub minus
{
  my %seen;
  my %notme=map{($_=>1)}@{$_[1]};
  return grep{!$notme{$_}&&!$seen{$_}++}@{$_[0]};
}

=head2 intersect

Input: Two arrayrefs

Output: An array containing all elements which exists in both input arrays.

Example:

 perl -MAcme::Tools -le ' print join" ", intersect( ["five", 1, 2, 3.0, 4], [4, 2+1, "five"] )'

The output being C<< 4 3 five >>.

=cut

sub intersect
{
  my %first=map{($_=>1)}@{$_[0]};
  my %seen;
  return grep{$first{$_}&&!$seen{$_}++}@{$_[1]};
}

=head2 not_intersect

Input: Two arrayrefs

Output: An array containing all elements member of just one of the input arrays (not both).

Example:

 perl -MAcme::Tools -le ' print join " ", not_intersect( ["five", 1, 2, 3.0, 4], [4, 2+1, "five"] )'

The output is C<< 1 2 >>.

=cut

sub not_intersect
{
  my %code;
  my %seen;
  for(@{$_[0]}){$code{$_}|=1}
  for(@{$_[1]}){$code{$_}|=2}
  return grep{$code{$_}!=3&&!$seen{$_}++}(@{$_[0]},@{$_[1]});
}

=head2 uniq

Input:    An array of strings (or numbers)

Output:   The same array in the same order, except elements which exists earlier in the list.

Same as L</distinct>, but distinct sorts the returned list.

Example:

 my @t=(7,2,3,3,4,2,1,4,5,3,"x","xx","x",02,"07");
 print join " ", uniq @t;  # skriver  7 2 3 4 1 5 x xx 07

=cut

sub uniq(@)
{
  my %seen;
  return grep{!$seen{$_}++}@_;
}

=head2 zip

B<Input:> Two arrayrefs.

That is: two arrays containing numbers, strings or anything really.

B<Output:> An array of the two arrays zipped (interlocked, merged) into each other.

Example:

 print join " ", zip( [1,3,5], [2,4,6] );

Prints C<< 1 2 3 4 5 6 >>

zip() is sometimes be useful in creating hashes where keys are found in the first array and values in the secord, in the same order:

 my @media = qw/CD DVD VHS LP/;
 my @count = qw/20 4 2 7/;
 my %count = zip(\@media,\@count);
 print "I got $count{DVD} DVDs\n"; # I got 4 DVDs

TODO: Merging any number of arrayref in input.

=cut

sub zip  #?(\@\@)
{
  my($t1,$t2)=@_;
  if(ref($t1) ne 'ARRAY' or ref($t2) ne 'ARRAY' or 0+@$t1 != 0+@$t2){
    my $brb=serialize($t1,'t1')."\n".serialize($t2,'t2');
    croak("ERROR: wrong arguments to zip\n$brb");
  }
  my @res;
  my $i=$[;
  for(@$t1){push@res,$_,$$t2[$i++]}
  return @res;
}


=head2 subhash

Copies a subset of keys/values from one hash to another.

Input:

First argument is a reference to a hash.

The rest of the arguments are a list of keys you want copied:

Output:

The hash consisting of the keys and values you specified.

Example:

 %population = ( Norway=>4800000, Sweeden=>8900000, Finland=>5000000,
                 Denmark=>5100000, Iceland=>260000, India => 1e9 );

 %scandinavia = subhash(\%population,qw/Norway Sweeden Denmark/);    # this

 print "$_ har population $skandinavia{$_}" for keys %skandinavia;

 %skandinavia = (Norge=>4500000,Sverige=>8900000,Danmark=>5100000);  # is the same as this

...prints the populations of the three scandinavian countries.

Note: The values are NOT deep copied when they are references.

=cut

sub subhash
{
  my $hr=shift;
  my @r;
  for(@_){ push@r,($_=>$$hr{$_}) }
  return @r;
}

=head2 hashtrans

B<Input:> a reference to a hash of hashes

B<Output:> a hash like the input-hash, but transposed (sort of). Think of it as if X and Y has swapped place.

 %h = ( 1 => {a=>33,b=>55},
        2 => {a=>11,b=>22},
        3 => {a=>88,b=>99} );
 print serialize({hashtrans(\%h)},'v');

Gives:

 %v=('a'=>{'1'=>'33','2'=>'11','3'=>'88'},'b'=>{'1'=>'55','2'=>'22','3'=>'99'});

=cut

#Hashtrans brukes automatisk n�r f�rste argument er -1 i sub hashtabell()

sub hashtrans
{
    my $h=shift;
    my %new;
    for my $k (keys%$h){
	my $r=$$h{$k};
	for(keys%$r){
	    $new{$_}{$k}=$$r{$_};
	}
    }
    return %new;
}

=head1 RANDOM

=head2 random

B<Input:> One or two arguments.

B<Output:>

If the first argument is an arrayref: returns a random member of that array.

Else: returns a random integer between the integers in argument one and two.

Note: This is different from C<< int($from+rand($to-$from)) >> because that never returns C<$to>, but C<random()> will.

If there is no second argument and the first is an integer, a random integer between 0 and that number is returned.

B<Examples:>

 $dice=random(1,6);                                # 1, 2, 3, 4, 5 or 6
 $dice=random([1..6]);                             # same as previous
 print random(['head','tail','standing on edge']); # prints one of those three strings
 print random(2);                                  # prints 0, 1 or 2
 print 2**random(7);                               # prints 1, 2, 4, 8, 16, 32, 64 or 128

B<TODO:>

Draw numbers from a normal deviation (bell curve) or other statistical deviations (Although there are probably other modules that do that).
I.e.:

 print random({-deviation=>'Normal', -average=>178, -stddev=>15});

Another possible TODO: weighted dices, for cheating:

 print random([[1,0],[2,1],[3,1],[4,1],[5,2],[6,2]]); # never 1 and twice as likely to return  5 and 6 as opposed to 2, 3 and 4
 print random([[1,0],2,3,4,[5,2],[6,2]]);             # same, default weight 1 on 2, 3 and 4

=cut

sub random
{
  my($from,$to)=@_;
  if(ref($from) eq 'ARRAY'){
      return $$from[random($#$from)];
  }
  ($from,$to)=(0,$from) if @_==1;
  ($from,$to)=($to,$from) if $from>$to;
  return int($from+rand(1+$to-$from));
}

=head2 mix

C<mix()> could also have been named C<shuffle()>, as in shuffleing a deck of cards.

C<List::Util::shuffle()> exists, and is approximately four times faster. Both respects C<srand()>.

Example:

Mixes an array in random order. This:

 print mix("a".."z"),"\n" for 1..3;

...could write something like:

 trgoykzfqsduphlbcmxejivnwa
 qycatilmpgxbhrdezfwsovujkn
 ytogrjialbewcpvndhkxfzqsmu

B<Input:>

=over 4

=item 1.
Either a reference to an array as the only input. This array will then be mixed I<in-place>. The array will be changed:

This: C<< @a=mix(@a) >> is the same as:  C<< mix(\@a) >>.

=item 2.
Or an array of zero, one or more elements.

=back

Note that an input-array which COINCIDENTLY SOME TIMES has one element
(but more other times), and that element is an array-ref, you will
probably not get the expected result.

To check distribution:

 perl -MAcme::Tools -le 'print mix("a".."z") for 1..26000'|cut -c1|sort|uniq -c|sort -n

The letters a-z should occur around 1000 times each.

Shuffles a deck of cards: (s=spaces, h=hearts, c=clubs, d=diamonds)

 perl -MAcme::Tools -le '@cards=map join("",@$_),cart([qw/s h c d/],[2..10,qw/J Q K A/]); print join " ",mix(@cards)'

(Uses L</cart>, which is not a typo, see further down here)

=cut

sub mix
{
  if(@_==1 and ref($_[0]) eq 'ARRAY'){ #kun ett arg, og det er ref array
    my $r=$_[0];
    push@$r,splice(@$r,rand(@$r-$_),1) for 0..(@$r-1);
    return $r;
  }
  else{
    my@e=@_;
    push@e,splice(@e,rand(@e-$_),1) for 0..$#e;
    return @e;
  }
}

=head1 COMPRESSION

L</zipb64>, L</unzipb64>, L</zipbin>, L</unzipbin>, L</gzip>, og L</gunzip>
compresses and uncompresses strings to save space in disk, memory,
database or network transfer. Trades speed for space.

=head2 zipb64

Compresses the input (text or binary) and returns a base64-encoded string of the compressed binary data.
No known limit on input length, several MB has been tested, as long as you've got the RAM...

B<Input:> One or two strings.

First argument: The string to be compressed.

Second argument is optional: A I<dictionary> string.

B<Output:> a base64-kodet string of the compressed input.

The use of an optional I<dictionary> string will result in an even
further compressed output in the dictionary string is somewhat similar
to the string that is compressed (the data in the first argument).

If x relatively similar string are to be compressed, i.e. x number
automatic of email responses to some action by a user, it will pay of
to choose one of those x as a dictionary string and store it as
such. (You will also use the same dictionary string when decompressing
using L</unzipb64>.

The returned string is base64 encoded. That is, the output is 33%
larger than it has to be.  The advantage is that this string more
easily can be stored in a database (without the hassles of CLOB/BLOB)
or perhaps easier transfer in http POST requests (it still needs some
url-encoding, normally). See L</zipbin> and L</unzipbin> for the
same without base 64 encoding.

Example 1, normal compression without dictionary:

  $txt = "Test av komprimering, hva skjer? " x 10;  # ten copies of this norwegian string, $txt is now 330 bytes (or chars rather...)
  print length($txt)," bytes input!\n";             # prints 330
  $zip = zipb64($txt);                              # compresses
  print length($zip)," bytes output!\n";            # prints 65
  print $zip;                                       # prints the base64 string ("noise")

  $output=unzipb64($zip);                              # decompresses
  print "Hurra\n" if $output eq $txt;               # prints Hurra if everything went well
  print length($output),"\n";                       # prints 330

Example 2, same compression, now with dictionary:

  $txt = "Test av komprimering, hva skjer? " x 10;  # Same original string as above
  $dict = "Testing av kompresjon, hva vil skje?";   # dictionary with certain similarities
                                                    # of the text to be compressed
  $zip2 = zipb64($txt,$dict);                          # compressing with $dict as dictionary
  print length($zip2)," bytes output!\n";           # prints 49, which is less than 65 in ex. 1 above
  $output=unzipb64($zip2,$dict);                       # uses $dict in the decompressions too
  print "Hurra\n" if $output eq $txt;               # prints Hurra if everything went well


Example 3, dictionary = string to be compressed: (out of curiosity)

  $txt = "Test av komprimering, hva skjer? " x 10;  # Same original string as above
  $zip3 = zipb64($txt,$txt);                           # hmm
  print length($zip3)," bytes output!\n";           # prints 25
  print "Hurra\n" if unzipb64($zip3,$txt) eq $txt;     # hipp hipp ...

zipb64() og zipbin() is really just wrappers around L<Compress::Zlib> and C<inflate()> & co there.

=cut

sub zipb64
{
  require MIME::Base64;
  return MIME::Base64::encode_base64(zipbin(@_));
}


=head2 zipbin

C<zipbin()> does the same as C<zipb64()> except that zipbin()
does not base64 encode the result. Returns binary data.

See L</zip> for documentation.

=cut

sub zipbin
{
  require Compress::Zlib;
  my($data,$dict)=@_;
  my $x=Compress::Zlib::deflateInit(-Dictionary=>$dict,-Level=>Compress::Zlib::Z_BEST_COMPRESSION()) or croak();
  my($output,$status)=$x->deflate($data); croak() if $status!=Compress::Zlib::Z_OK();
  my($out,$status2)=$x->flush(); croak() if $status2!=Compress::Zlib::Z_OK();
  return $output.$out;
}

=head2 unzipb64

Opposite of L</zipb64>.

Input: 

First argument: A string made by L</zipb64>

Second argument: (optional) a dictionary string which where used in L</zipb64>.

Output: The original string (be it text or binary).

See L</zipb64>.

=cut

sub unzipb64
{
  my($data,$dict)=@_;
  require MIME::Base64;
  unzipbin(MIME::Base64::decode_base64($data),$dict);
}

=head2 unzipbin

C<unzipbin()> does the same as L</unzip> except that C<unzipbin()>
wants a pure binary compressed string as input, not base64.

See L</unzipb64> for documentation.

=cut

sub unzipbin
{
  require Compress::Zlib;
  require Carp;
  my($data,$dict)=@_;
  my $x=Compress::Zlib::inflateInit(-Dictionary=>$dict) or croak();
  my($output,$status)=$x->inflate($data);
  croak() if $status!=Compress::Zlib::Z_STREAM_END();
  return $output;
}

=head2 gzip

B<Input:> A string you want to compress. Text or binary.

B<Output:> The binary compressed representation of that input string.

C<gzip()> is really the same as C< Compress:Zlib::memGzip() > except
that C<gzip()> just returns the input-string if for some reason L<Compress::Zlib>
could not be C<required>. Not installed or not found.  (L<Compress::Zlib> is a built in module in newer perl versions).

C<gzip()> uses the same compression algorithm as the well known GNU program gzip found in most unix/linux/cygwin distros. Except C<gzip()> does this in-memory. (Both using the C-library C<zlib>).

=cut

sub gzip
{
  my $s=shift();
  eval{     # tries gzip, if it works it works, else returns the input
    require Compress::Zlib;
    $s=Compress::Zlib::memGzip(\$s);
  };undef$@;
  return $s;
}

=head2 gunzip

B<Input:> A binary compressed string. I.e. something returned from 
C<gzip()> earlier or read from a C<< .gz >> file.

B<Output:> The original larger non-compressed string. Text or binary. 

=cut

sub gunzip
{
  my $s=shift();
  eval {
    require Compress::Zlib;
    $s=Compress::Zlib::memGunzip(\$s);
  };undef$@;
  return $s;
}

=head2 bzip2

See L</gzip> and L</gunzip>.

C<bzip2()> and C<bunzip2()> works just as  C<gzip()> and C<gunzip()>,
but use another compression algorithm. This is usually better but slower
than the C<gzip>-algorithm. Especially in the compression, decompression speed is less different.

See also C<man bzip2>, C<man bunzip2> and L<Compress::Bzip2>

=cut

sub bzip2
{
  my $s=shift();
  eval{
    require Compress::Bzip2;
    $s=Compress::Bzip2::memBzip($s);
  };
  undef$@;
  return $s;
}

=head2 bunzip2

Decompressed something compressed by bzip2() or the data from a C<.bz2> file. See L</bzip2>.

=cut

sub bunzip2
{
  my $s=shift();
  eval{
    require Compress::Bzip2;
    $s=Compress::Bzip2::memBunzip($s);
  };undef$@;
  return $s;
}


=head1 NET, WEB, CGI-STUFF

=head2 ipaddr

B<Input:> an IP-number

B<Output:> either an IP-address I<machine.sld.tld> or an empty string
if the DNS lookup didn't find anything.

Example:

 perl -MAcme::Tools -le 'print ipaddr("129.240.13.152")'  # prints www.uio.no

Uses perls C<gethostbyaddr> internally.

C<ipaddr()> memoizes the results internally (using the
C<%Acme::Tools::IPADDR_memo> hash) so only the first loopup on a
particular IP number might take some time.

Some few DNS loopups can take several seconds.
Most is done in a fraction of a second. Due to this slowness, medium to high traffic web servers should
probably turn off hostname lookups in their logs and just log IP numbers.
That is  C<HostnameLookups Off> in Apache C<httpd.conf>.

=cut

our %IPADDR_memo;
sub ipaddr
{
  my $ipnr=shift;
  return $IPADDR_memo{$ipnr} if exists $IPADDR_memo{$ipnr};

  #NB, 2-tallet p� neste kodelinje er ikke det samme p� alle os,
  #men ser ut til � funke i linux og hpux. Den Riktige M�ten(tm)
  #er konstanten AF_INET i Socket eller IO::Socket-pakken.

  my $ipaddr=gethostbyaddr(pack("C4",split("\\.",$ipnr)),2);
  $IPADDR_memo{$ipnr} = length($ipaddr)==0?undef:$ipaddr;
  return $IPADDR_memo{$ipnr};
}

=head2 ipnum

C<ipnum()> does the opposite of C<ipaddr()>

Does an attempt of converting an IP address (hostname) to an IP number.
Uses DNS name servers by using perls internal C<gethostbyname()>.
Return an empty string (undef) if unsuccessful.

 print ipnum("www.uio.no");   # prints 129.240.13.152

Does internal memoization via the hash C<%Acme::Tools::IPNUM_memo>.

=cut

our %IPNUM_memo;
sub ipnum
{
  my $ipaddr=shift;
  return $IPNUM_memo{$ipaddr} if exists $IPNUM_memo{$ipaddr};
  my $ipnum = join(".",unpack("C4",gethostbyname($ipaddr)));
  $IPNUM_memo{$ipaddr} = $ipnum=~/^(\d+\.){3}\d+$/ ? $ipnum : undef;
  return $IPNUM_memo{$ipaddr};
}

=head2 webparams

B<Input:> (optional)

Zero or one input argument: A string of the same type often found behind the first question char (C<< ? >>) in URLs.

This string can have two or more parts separated with C<&> chars.

And each part consists of C<key=value> pairs (with the first C<=> char being the separation char).

Both C<key> and C<value> can be url-encoded.

If there is no input argument, C<webparams> uses C<< $ENV{QUERY_STRING} >> instead.

If also  C<< $ENV{QUERY_STRING} >> is lacking, C<webparams()> sees if C<< $ENV{REQUEST_METHOD} eq 'POST' >>.

In that case C<< $ENV{CONTENT_LENGTH} >> is taken as the number of bytes to be read from C<STDIN>
and those bytes are use as the missing input argument.

The environment variables QUERY_STRING, REQUEST_METHOD and CONTENT_LENGTH is
typically set by a web server following the CGI standard (which apache and
most of them can do I guess) or in mod_perl by Apache. Although you are
probably better off using L<CGI>. Or C<< $R->args() >> or C<< $R->content() >> in mod_perl.

B<Output:>

C<webparams()> returns a hash of the key/value pairs in the input argument. Url-decoded.

If an input string contains more than one occurrence of the same key, that keys value in the returned hash will become concatenated each value separated by a C<,> char. (A comma char)

Examples:

 use Acme::Tools;
 print "Content-Type: text/plain\n\n";                          # or \cM\cJ\cM\cJ
 my %R=webparams();
 print "My name is $R{name}";

Storing this little script in the directory designated for CGI-scripts
on your web server (or naming the file .cgi perhaps), and C<chmod +x
/.../cgi-bin/script> and the URL
L<http://some.server.somewhere/cgi-bin/script?name=HAL> will print
C<My name is HAL> to the web page.

L<http://some.server.somewhere/cgi-bin/script?name=Bond&name=James+Bond> will print C<My name is Bond, James Bond>.

=cut

sub webparams
{
  my $query=shift()||$ENV{QUERY_STRING};
  if(! $query && $ENV{REQUEST_METHOD} eq "POST"){
    read(STDIN,$query , $ENV{CONTENT_LENGTH});
    $ENV{QUERY_STRING}=$query;
  }
  my %R;
  for(split("&",$query)){
    next if !length($_);
    my($nkl,$verdi)=map urldec($_),split("=",$_,2);
    $R{$nkl}=exists$R{$nkl}?"$R{$nkl},$verdi":$verdi;
  }
  return %R;
}

=head2 urlenc

Input: a string

Output: the same string URL encoded so it can be sent in URLs or POST requests.

In URLs (web addresses) certain characters are illegal. For instance I<space> and I<newline>.
And certain other chars have special meaning, such as C<+>, C<%>, C<=>, C<?>, C<&>.

These illegal and special chars needs to be encoded to be sent in
URLs.  This is done by sending them as C<%> and two hex-digits. All
chars can be URL encodes this way, but it's necessary just on some.

Example:

 $search="�stdal, �ge";
 use LWP::Simple;
 my $url="http://machine.somewhere.com/cgi-bin/script?s=".urlenc($search);
 print $url;
 my $html = get($url);

Prints C<< http://soda.uio.no/cgi/DB/person?id=%D8stdal%2C+%C5ge >>

=cut

sub urlenc
{
  my $str=shift;
  $str=~s/([^\w\-\.\/\,\[\]])/sprintf("%%%02x",ord($1))/eg; #more chars is probably legal...
  return $str;
}

=head2 urldec

Opposite of L</urlenc>.

Example, this returns 'C< �>'. That is space and C<< � >>.

 urldec('+%C3')

=cut

sub urldec{
  my $str=shift;
#  $str=~y/+/ /;
  $str=~s/\+/ /gs;
  $str=~s/%([a-f\d]{2})/pack("C", hex($1))/egi;
  return $str;
}

=head2 ht2t

C<ht2t> is short for I<html-table to table>.

This sub extracts an html-C<< <table> >>s and returns its C<< <tr>s >>
and C<< <td>s >> as an array of arrayrefs. And strips away any html
inside the C<< <td>s >> as well.

 my @table = ht2t($html,'some string occuring before the <table> you want');

Input: One or two arguments.

First argument: the html where a C<< <table> >> is to be found and converted.

Second argument: (optional) If the html contains more than one C<<
<table> >>, and you do not want the first one, applying a second
argument is a way of telling C<ht2t> which to capture: the one with this word
or string occurring before it.

Output: An array of arrayrefs.

C<ht2t()> is a quick and dirty way of scraping (or harvesting as it is
also called) data from a web page. Look too L<HTML::Parse> to do this
more accurate.

Example:

 use Acme::Tools;
 use LWP::Simple;
 for(
   ht2t(
     get("http://www.norges-bank.no/templates/article____200.aspx"),
     "Effektiv kronekurs"
   )
 ){
  my($country, $countrycode, $currency) = @$_;
  print "$country ($countrycode) uses $currency\n";
 }

Output:

 Australia (AUD) uses Dollar
 Belgia (BEF) uses Franc (Euro)
 Brasil (BRL) uses Real
 Bulgaria (BGN) uses Lev
 Canada (CAD) uses Dollar
 Danmark (DKK) uses Krone

...and so on.

=cut

sub ht2t {
  my($f,$s)=@_;
  $f=~s,.*?($s).*?(<table.*?)</table.*,$2,si;
  my $e=0;$e++ while index($f,$s=chr($e))>=$[;
  $f=~s/<t(d|r|h).*?>/\l$1$s/gsi;
  $f=~s/\s*<.*?>\s*/ /gsi;
  my @t=split("r$s",$f);shift @t;
  for(@t){my @r=split(/[dh]$s/,$_);shift @r;$_=[@r]}
  @t;
}

=head1 FILES, DIRECTORIES

=head2 chall

Does chmod + utime + chown on one or more filer.

Returns the number of files of which those operations was successful.

Mode, uid, gid, atime and mtime are set from the array ref in the first argument.

The first argument references an array which is exactly like an array returned from perls internal C<stat($filename)> -function.

Example:

 my @stat=stat($filenameA);
 chall( \@stat, $filenameB, $filenameC, ... );

Copies the chmod, owner, group, access time and modify time from file A to file B and C.

See C<perldoc -f stat>, C<perldoc -f chmod>, C<perldoc -f chown>, C<perldoc -f utime>

=cut



sub chall
{
  my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks ) = @{shift()};
  my $successful=0;
  for(@_){ chmod($mode,$_) && utime($atime,$mtime,$_) && chown($uid,$gid,$_) && $successful++ }
  return $successful;
}

=head2 makedir

Input: One or two arguments.

Works like perls C<mkdir()> except that C<makedir()> will create nesessary parent directories if they dont exists.

First input argument: A directory name (absolute, starting with C< / > or relative).

Second input argument: (optional) permission bits. Using the normal C<< 0777^umask() >> as the default if no second input argument is provided.

Example:

 makedir("dirB/dirC")

...will create directory C<dirB> if it does not already exists, to be able to create C<dirC> inside C<dirB>.

Returns true on success, otherwise false.

C<makedir()> memoizes directories it has checked for existance before (trading memory for speed).

See also C<< perldoc -f mkdir >>, C<< man umask >>

=cut

our %MAKEDIR;

sub makedir
{
  my($d,$p,$dd)=@_;
  $p=0777^umask() if !defined$p;
  (
  $MAKEDIR{$d} or -d$d or mkdir($d,$p) #or croak("mkdir $d, $p")
  or ($dd)=($d=~m,^(.+)/+([^/]+)$,) and makedir($dd,$p) and mkdir($d,$p) #or die;
  ) and ++$MAKEDIR{$d};
}

=head1 OTHER

=head2 qrlist

Input: An array of values to be used to test againts for existence.

Output: A reference to a regular expression. That is a C<qr//>

The regex sets $1 if it match.

Example:

  my @list=qw/ABc XY DEF DEFG XYZ/;
  my $filter=qrlist("ABC","DEF","XY.");         # makes a regex of it qr/^(\QABC\E|\QDEF\E|\QXYZ\E)$/
  my @filtered= grep { $_ =~ $filter } @list;   # returns DEF og XYZ, but not XYZ

Note: hash lookups are WAY faster.

Source:

 sub qrlist (@) { my $str=join"|",map quotemeta, @_; qr/^($str)$/ }

=cut

sub qrlist (@)
{
  my $str=join"|",map quotemeta,@_;
  return qr/^($str)$/;
}

=head2 ansicolor

Perhaps easier to use than L<Term::ANSIColor> ?

B<Input:> One argument. A string where the char C<�> have special
meaning and is replaced by color codings depending on the letter
following the C<�>.

B<Output:> The same string, but with C<�letter> replaces by ANSI color codes respected by many types terminal windows. (xterm, telnet, ssh,
telnet, rlog, vt100, xterm, cygwin and such...).

B<Codes for ansicolor():>

 �r red
 �g green
 �b blue
 �y yellow
 �m magenta
 �B bold
 �u underline
 �c clear
 �� reset, quits and returns to default (black?) text color.

B<Example:>

 print ansicolor("This is maybe �ggreen��?");

Prints I<This is maybe green?> where the word I<green> is shown in green.

If L<Term::ANSIColor> is not installed or not found, returns the input
string with every C<�> including the following code letters
removed. (That is: ansicolor is safe to use even if Term::ANSIColor is
not installed, you just dont get the colors).

See also L<Term::ANSIColor>.

=cut

sub ansicolor
{
  my $txt=shift;
  eval{require Term::ANSIColor} or return replace($txt,qr/�./);
  my %h=qw/r red  g green  b blue  y yellow  m magenta  B bold  u underline  c clear  � reset/;
  my $re=join"|",keys%h;
  $txt=~s/�($re)/Term::ANSIColor::color($h{$1})/ge;
  return $txt;
}

=head2 ccn_ok

Checks if a Credit Card number (CCN) has correct control digits according to the LUHN-algorithm from 1960.
This method of control digits is used by MasterCard, Visa, American Express,
Discover, Diners Club / Carte Blanche, JCB and others.

B<Input:>

A credit card number. Can contain non-digits, but they are removed internally before checking.

B<Output:>

Something true or false.

Or more accurately:

Returns C<undef> (false) if the input argument is missing digits.

Returns 0 (zero, which is false) is the digits is not correct according to the LUHN algorithm.

Returns 1 or the name of a credit card company (true either way) if the last digit is an ok control digit for this ccn.

The name of the credit card company is returned like this (without the C<'> character)

 Returns (wo '')                Starts on                Number of digits
 ------------------------------ ------------------------ ----------------
 'MasterCard'                   51-55                    16
 'Visa'                         4                        13 eller 16
 'American Express'             34 eller 37              15
 'Discover'                     6011                     16
 'Diners Club / Carte Blanche'  300-305, 36 eller 38     14
 'JCB'                          3                        16
 'JCB'                          2131 eller 1800          15

And should perhaps have had:

 'enRoute'                      2014 eller 2149          15

...but that card uses either another control algorithm or no control
digits at all. So C<enRoute> is never returned here.

If the control digits is valid, but the input does not match anything in the column C<starts on>, 1 is returned.

(This is also the same control digit mechanism used in Norwegian KID numbers on payment bills)

The first digit in a credit card number is supposed to tell what "industry" the card is meant for:

 MII Digit Value             Issuer Category
 --------------------------- ----------------------------------------------------
 0                           ISO/TC 68 and other industry assignments
 1                           Airlines
 2                           Airlines and other industry assignments
 3                           Travel and entertainment
 4                           Banking and financial
 5                           Banking and financial
 6                           Merchandizing and banking
 7                           Petroleum
 8                           Telecommunications and other industry assignments
 9                           National assignment

...although this has no meaning to C<Acme::Tools::ccn_ok()>.

The first six digits is I<Issuer Identifier>, that is the bank
(probably). The rest in the "account number", except the last digits,
which is the control digit. Max length on credit card numbers are 19
digits.

=cut

sub ccn_ok
{
    my $ccn=shift(); #credit card number
    $ccn=~s/\D+//g;
    if(KID_ok($ccn)){
	return "MasterCard"                   if $ccn=~/^5[1-5]\d{14}$/;
	return "Visa"                         if $ccn=~/^4\d{12}(?:\d{3})?$/;
	return "American Express"             if $ccn=~/^3[47]\d{13}$/;
	return "Discover"                     if $ccn=~/^6011\d{12}$/;
	return "Diners Club / Carte Blanche"  if $ccn=~/^3(?:0[0-5]\d{11}|[68]\d{12})$/;
	return "JCB"                          if $ccn=~/^(?:3\d{15}|(?:2131|1800)\d{11})$/;
	return 1;
    }
    #return "enRoute"                        if $ccn=~/^(?:2014|2149)\d{11}$/; #ikke LUHN-krav?
    return 0;
}

=head2 KID_ok

Checks if a norwegian KID number has an ok control digit.

To check if a customer has typed the number correctly.

This uses the  LUHN algorithm (also known as mod-10) from 1960 which is also used
internationally in control digits for credit card numbers, and Canadian social security ID numbers as well.

The algorithm, as described in Phrack (47-8) (a long time hacker online publication):

 "For a card with an even number of digits, double every odd numbered
 digit and subtract 9 if the product is greater than 9. Add up all the
 even digits as well as the doubled-odd digits, and the result must be
 a multiple of 10 or it's not a valid card. If the card has an odd
 number of digits, perform the same addition doubling the even numbered
 digits instead."

B<Input:> A KID-nummer. Must consist of digits 0-9 only, otherwise a die (croak) happens.

B<Output:>

- Returns undef if the input argument is missing.

- Returns 0 if the control digit (the last digit) does not satify the LUHN/mod-10 algorithm.

- Returns 1 if ok

B<See also:> L</ccn_ok>

=cut

sub KID_ok
{
  die if $_[0]=~/\D/;
  my @k=split//,shift or return undef;
  my $s;$s+=pop(@k)+[qw/0 2 4 6 8 1 3 5 7 9/]->[pop@k] while @k;
  $s%10==0?1:0;
}


=head2 writefile

Justification:

Perl needs three or four operations to make a file out of a string:

 open my $FILE, '>', $filename  or die $!;
 print $FILE $text;
 close($FILE);

This is way simpler:

 writefile($filename,$text);

Sub writefile opens the file i binary mode (C<binmode()>) and has two usage modes:

B<Input:> Two arguments

B<First argument> is the filename. If the file exists, its overwritten.
If the file can not be opened for writing, a die (a carp really) happens.

B<Second input argument> is one of:

=over 4

=item * Either a scaler. That is a normal string to be written to the file.

=item * Or a reference to a scalar. That referred text is written to the file.

=item * Or a reference to an array of scalars. This array is the written to the
 file element by element and C<< \n >> is automatically appended to each element.

=back

Alternativelly, you can write several files at once.

Example, this:

 writefile('file1.txt','The text....tjo');
 writefile('file2.txt','The text....hip');
 writefile('file3.txt','The text....and hop');

...is the same as this:

 writefile([
   ['file1.txt','The text....tjo'],
   ['file2.txt','The text....hip'],
   ['file3.txt','The text....and hop'],
 ]);

B<Output:> Nothing (for the time being). C<die()>s (C<croak($!)> really) if something goes wrong.

=cut

sub writefile
{
    my($filename,$text)=@_;
    if(ref($filename) eq 'ARRAY'){
	writefile(@$_) for @$filename;
	return;
    }
    open(WRITEFILE,">",$filename) and binmode(WRITEFILE) or croak($!);
    if(not defined $text or not ref($text)){
	print WRITEFILE $text;
    }
    elsif(ref($text) eq 'SCALAR'){
	print WRITEFILE $$text;
    }
    elsif(ref($text) eq 'ARRAY'){
	print WRITEFILE "$_\n" for @$text;
    }
    else {
	croak;
    }
    close(WRITEFILE);
    return;
}

=head2 readfile

Just as with L</writefile> you can read in a whole file in one operation with C<readfile()>. Instead of:

 open my $FILE,'<', $filename or die $!;
 my $data = join"",<$FILE>;
 close($FILE);

This is simpler:

 my $data = readfile($filename);

B<More examples:>

Reading the content of the file to a scalar variable: (If C<$data> is non-empty, that will disappear)

 my $data;
 readfile('filename.txt',\$data);

Reading the lines of a file into an array:

 my @lines;
 readfile('filnavn.txt',\@lines);
 for(@lines){
   ...
 }

Note: Chomp is done on each line. That is, any newlines (C<< \n >>) will be removed.
If C<@lines> is non-empty, this will be lost.

Sub readfile is context aware. If an array is expected it returns an array of the lines without a trailing C<< \n >>.
The last example can be rewritten:

 for(readfile('filnavn.txt')){
   ...
 }

With two input arguments, nothing (undef) is returned from C<readfile()>.

=cut

sub readfile
{
  my($filename,$ref)=@_;
  if(not defined $ref){  #-- one argument
      if(wantarray){
	  my @data;
	  readfile($filename,\@data);
	  return @data;
      }
      else {
	  my $data;
	  readfile($filename,\$data);
	  return $data;
      }
  }
  else {                 #-- two arguments
      open(READFILE,'<',$filename) or croak($!);
      if(ref($ref) eq 'SCALAR'){
	  $$ref=join"",<READFILE>;
      }
      elsif(ref($ref) eq 'ARRAY'){
	  while(my $l=<READFILE>){
	      chomp($l);
	      push @$ref, $l;
	  }
      }
      else {
	  croak;
      }
      close(READFILE);
      return;
  }
}

=head2 readdirectory

B<Input:>

Name of a directory.

B<Output:>

A list of all files in it, except of  C<.> and C<..>

The names of all types of files are returned: normal files, sub directories, symbolic links,
pipes, semaphores. That is every thing shown by C<ls -la> except of C<.> and C<..>

C<readdirectory> does not recurce into sub directories.

B<Example:>

  my @files = readdirectory("/tmp");

B<Why?>

Sometimes calling the built ins C<opendir>, C<readdir> og C<closedir>
seems a bit tedious.

This:

 my $dir="/usr/bin";
 opendir(D,$dir);
 my @files=map "$dir/$_", grep {!/^\.\.?$/} readdir(D);
 closedir(D);

Is the same as this:

 my @files=readdirectory("/usr/bin");

See also: L<File::Find>

=cut

sub readdirectory
{
  my $dir=shift;
  opendir(my $D,$dir);
  my @filer=map "$dir/$_", grep {!/^\.\.?$/} readdir($D);
  closedir($D);
  return @filer;
}

=head2 range

B<Input:>

One, two or tre numeric arguments: C<x> og C<y> and C<jump>.

B<Output:>

If one argument: returns the array C<(0..x-1)>

If two arguments: returns the array C<(x..y-1)>

If three arguments: returns every I<jump>th number between C<x> and C<y>.

B<Examples:>

 print join ",", range(11);      # prints 0,1,2,3,4,5,6,7,8,9,10
 print join ",", range(2,11);    # prints 2,3,4,5,6,7,8,9,10
 print join ",", range(11,2,-1); # prints 11,10,9,8,7,6,5,4,3
 print join ",", range(2,11,3);  # prints 2,5,8
 print join ",", range(11,2,-3); # prints 11,8,5

In the Python language, C<range> is build in and works as an iterator instead of an array. This saves memory for big C<x> and C<y>s.

=cut

sub range
{
  my($x,$y,$jump)=@_;
  return (  0 .. $x-1 ) if @_==1;
  return ( $x .. $y-1 ) if @_==2;
  die                   if @_!=3 or $jump==0;

  my @r;
  if($jump>0){
    while($x<$y){
      push @r, $x;
      $x+=$jump;
    }
  }
  else{
    while($x>$y){
      push @r, $x;
      $x+=$jump;
    }
  }
  return @r;
}

=head2 permutations

What is permutations?

Six friends will be eating at a table with six chairs.

How many ways (permutations) can those six be places in when the number of chairs = the number of people?

 If one person:          one
 If who persons:         two     (they can swap places with each other)
 If three persons:       six
 If four persons:         24
 If five persons:        120
 If six  persons:        720

The formula is C<x!> where the postfix operator C<!>, also known as I<faculty> is defined like:
C<x! = x * (x-1) * (x-2) ... * 1>. Example: C<5! = 5 * 4 * 3 * 2 * 1 = 120>.

Run this to see the 100 first C<< n! >>

 perl -le 'use Math::BigInt lib=>'GMP';$i=Math::BigInt->new(1);print "$_! = ",$i*=$_ for 1..100'

  1!  = 1
  2!  = 2
  3!  = 6
  4!  = 24
  5!  = 120
  6!  = 720
  7!  = 5040
  8!  = 40320
  9!  = 362880
 10!  = 3628800
 .
 .

C<permutations()> takes a list a returns a list of arrayrefs for each
of the permutations of the input list:

 permutations('a','b');     #returns (['a','b'],['b','a'])

 permutations('a','b','c'); #returns (['a','b','c'],['a','c','b'],
                            #         ['b','a','c'],['b','c','a'],
                            #         ['c','a','b'],['c','b','a'])

For up to five input arguments C<permutations()> is as fast as it can be
in this pure perl implementation. For more than fire, it could perhaps
be faster. How fast is it now: Running with
different n, this many time took this many seconds:

 n   times    seconds
 -- ------- ---------
  2  100000      0.32
  3  10000       0.09
  4  10000       0.33
  5  1000        0.18
  6  100         0.27
  7  10          0.21
  8  1           0.17
  9  1           1.63
 10  1          17.00

If the first argument is a coderef, that sub will be called for each permutation and the return from those calls with be the real return from C<permutations()>. For example this:

 print for permutations(sub{join"",@_},1..3);

...will print the same as:

 print for map join("",@$_), permutations(1..3);

...but the first of those two uses less RAM if 3 has been say 9.
Changing 3 with 10, and many computers hasn't enough memory 
for the latter.

The examples prints:

 123
 132
 213
 231
 312
 321

If you just want to say calculate something on each permutation,
but is not interested in the list of them, you just don't
take the return. That is:

 my $ant;
 permutations(sub{$ant++ if $_[-1]>=$_[0]*2},1..9);

...is the same as:

 $$_[-1]>=$$_[0]*2 and $ant++ for permutations(1..9);

...but the first uses next to nothing of memory compared to the latter. They have about the same speed.
(The examples just counts the permutations where the last number is at least twice as large as the first)

C<permutations()> was created to find all combinations of a persons
name. This is useful in "fuzzy" name searches with
L<String::Similarity> if you can not be certain what is first, middle
and last names. In foreign or unfamiliar names it can be difficult to
know that.

=cut

sub permutations
{
  my $code=ref($_[0]) eq 'CODE' ? shift() : undef;
  $code and @_<6 and return map &$code(@$_),permutations(@_);

  return [@_] if @_<2;

  return ([@_[0,1]],[@_[1,0]]) if @_==2;

  return ([@_[0,1,2]],[@_[0,2,1]],[@_[1,0,2]],
	  [@_[1,2,0]],[@_[2,0,1]],[@_[2,1,0]]) if @_==3;

  return ([@_[0,1,2,3]],[@_[0,1,3,2]],[@_[0,2,1,3]],[@_[0,2,3,1]],
	  [@_[0,3,1,2]],[@_[0,3,2,1]],[@_[1,0,2,3]],[@_[1,0,3,2]],
	  [@_[1,2,0,3]],[@_[1,2,3,0]],[@_[1,3,0,2]],[@_[1,3,2,0]],
	  [@_[2,0,1,3]],[@_[2,0,3,1]],[@_[2,1,0,3]],[@_[2,1,3,0]],
	  [@_[2,3,0,1]],[@_[2,3,1,0]],[@_[3,0,1,2]],[@_[3,0,2,1]],
	  [@_[3,1,0,2]],[@_[3,1,2,0]],[@_[3,2,0,1]],[@_[3,2,1,0]]) if @_==4;

  return ([@_[0,1,2,3,4]],[@_[0,1,2,4,3]],[@_[0,1,3,2,4]],[@_[0,1,3,4,2]],[@_[0,1,4,2,3]],
	  [@_[0,1,4,3,2]],[@_[0,2,1,3,4]],[@_[0,2,1,4,3]],[@_[0,2,3,1,4]],[@_[0,2,3,4,1]],
	  [@_[0,2,4,1,3]],[@_[0,2,4,3,1]],[@_[0,3,1,2,4]],[@_[0,3,1,4,2]],[@_[0,3,2,1,4]],
	  [@_[0,3,2,4,1]],[@_[0,3,4,1,2]],[@_[0,3,4,2,1]],[@_[0,4,1,2,3]],[@_[0,4,1,3,2]],
	  [@_[0,4,2,1,3]],[@_[0,4,2,3,1]],[@_[0,4,3,1,2]],[@_[0,4,3,2,1]],[@_[1,0,2,3,4]],
	  [@_[1,0,2,4,3]],[@_[1,0,3,2,4]],[@_[1,0,3,4,2]],[@_[1,0,4,2,3]],[@_[1,0,4,3,2]],
	  [@_[1,2,0,3,4]],[@_[1,2,0,4,3]],[@_[1,2,3,0,4]],[@_[1,2,3,4,0]],[@_[1,2,4,0,3]],
	  [@_[1,2,4,3,0]],[@_[1,3,0,2,4]],[@_[1,3,0,4,2]],[@_[1,3,2,0,4]],[@_[1,3,2,4,0]],
	  [@_[1,3,4,0,2]],[@_[1,3,4,2,0]],[@_[1,4,0,2,3]],[@_[1,4,0,3,2]],[@_[1,4,2,0,3]],
	  [@_[1,4,2,3,0]],[@_[1,4,3,0,2]],[@_[1,4,3,2,0]],[@_[2,0,1,3,4]],[@_[2,0,1,4,3]],
	  [@_[2,0,3,1,4]],[@_[2,0,3,4,1]],[@_[2,0,4,1,3]],[@_[2,0,4,3,1]],[@_[2,1,0,3,4]],
	  [@_[2,1,0,4,3]],[@_[2,1,3,0,4]],[@_[2,1,3,4,0]],[@_[2,1,4,0,3]],[@_[2,1,4,3,0]],
	  [@_[2,3,0,1,4]],[@_[2,3,0,4,1]],[@_[2,3,1,0,4]],[@_[2,3,1,4,0]],[@_[2,3,4,0,1]],
	  [@_[2,3,4,1,0]],[@_[2,4,0,1,3]],[@_[2,4,0,3,1]],[@_[2,4,1,0,3]],[@_[2,4,1,3,0]],
	  [@_[2,4,3,0,1]],[@_[2,4,3,1,0]],[@_[3,0,1,2,4]],[@_[3,0,1,4,2]],[@_[3,0,2,1,4]],
	  [@_[3,0,2,4,1]],[@_[3,0,4,1,2]],[@_[3,0,4,2,1]],[@_[3,1,0,2,4]],[@_[3,1,0,4,2]],
	  [@_[3,1,2,0,4]],[@_[3,1,2,4,0]],[@_[3,1,4,0,2]],[@_[3,1,4,2,0]],[@_[3,2,0,1,4]],
	  [@_[3,2,0,4,1]],[@_[3,2,1,0,4]],[@_[3,2,1,4,0]],[@_[3,2,4,0,1]],[@_[3,2,4,1,0]],
	  [@_[3,4,0,1,2]],[@_[3,4,0,2,1]],[@_[3,4,1,0,2]],[@_[3,4,1,2,0]],[@_[3,4,2,0,1]],
	  [@_[3,4,2,1,0]],[@_[4,0,1,2,3]],[@_[4,0,1,3,2]],[@_[4,0,2,1,3]],[@_[4,0,2,3,1]],
	  [@_[4,0,3,1,2]],[@_[4,0,3,2,1]],[@_[4,1,0,2,3]],[@_[4,1,0,3,2]],[@_[4,1,2,0,3]],
	  [@_[4,1,2,3,0]],[@_[4,1,3,0,2]],[@_[4,1,3,2,0]],[@_[4,2,0,1,3]],[@_[4,2,0,3,1]],
	  [@_[4,2,1,0,3]],[@_[4,2,1,3,0]],[@_[4,2,3,0,1]],[@_[4,2,3,1,0]],[@_[4,3,0,1,2]],
	  [@_[4,3,0,2,1]],[@_[4,3,1,0,2]],[@_[4,3,1,2,0]],[@_[4,3,2,0,1]],[@_[4,3,2,1,0]]) if @_==5;

  my(@r,@p,@c,@i,@n); @i=(0,@_); @p=@c=1..@_; @n=1..@_-1;
  PERM:
  while(1){
    if($code){if(defined wantarray){push(@r,&$code(@i[@p]))}else{&$code(@i[@p])}}else{push@r,[@i[@p]]}
    for my$i(@n){splice@p,$i,0,shift@p;next PERM if --$c[$i];$c[$i]=$i+1}
    return@r
  }
}

=head2 trigram

B<Input:> A string (i.e. a name). And an optional x (see example 2)

B<Output:> A list of this strings trigrams (See examlpe)

B<Example 1:>

 print join ", ", trigram("Kjetil Skotheim");

Prints:

 Kje, jet, eti, til, il , l S,  Sk, Sko, kot, oth, the, hei, eim

B<Example 2:>

Default is 3, but here 4 is used instead in the second optional input argument:

 print join ", ", trigram("Kjetil Skotheim", 4);

And this prints:

 Kjet, jeti, etil, til , il S, l Sk,  Sko, Skot, koth, othe, thei, heim

C<trigram()> was created for "fuzzy" name searching. If you have a database of many names,
addresses, phone numbers, customer numbers etc. You can use trigram() to search
among all of those at the same time. If the search form only has one input field.
One general search box.

Store all of the trigrams of the trigram-indexed input fields coupled
with each person, and when you search, you take each trigram of you
query string and adds the list of people that has that trigram. The
search result should then be sorted so that the persons with most hits
are listed first. Both the query strings and the indexed database
fields should have a space added first and last before C<trigram()>-ing
them.

This search algorithm is not includes here yet...

C<trigram()> should perhaps have been named ngram for obvious reasons.

=cut

sub trigram
{
  my($s,$x)=@_;
  $x||=3;
  return $s if length($s)<=$x;
  return map substr($s,$_,$x), 0..length($s)-$x;
}

=head2 cart

Cartesian product

B<Easy usage:>

Input: two or more arrayrefs with accordingly x, y, z and so on number of elements.

Output: An array of x * y * z number of arrayrefs. The arrays being the cartesian product of the input arrays.

It can be useful to think of this as joins in SQL. In C<select> statements
with more tables behind C<from>, but without any C<where> condition to join
the tables.

B<Advanced usage, with condition(s):>

B<Input:>

- Either two or more arrayrefs with x, y, z and so on number of
elements.

- Or coderefs to subs containing condition checks. Somewhat like
C<where> conditions in SQL.

B<Output:> An array of x * y * z number of arrayrefs (the cartesian product)
minus the ones that did not fulfill the condition(s).

This of is as joins with one or more where conditions as coderefs.

The coderef input arguments can be placed last or among the array refs
to save both runtime and memory if the conditions depend on
arrays further back.

B<Examples, this:>

 for(cart(\@a1,\@a2,\@a3)){
   my($a1,$a2,$a3) = @$_;
   print "$a1,$a2,$a3\n";
 }

Give the same output as this:

 for my $a1 (@a1){
   for my $a2 (@a2){
     for my $a3 (@a3){
       print "$a1,$a2,$a3\n";
     }
   }
 }

B<And this:> (with a condition: the sum of the first two should be dividable with 3)

 for( cart( \@a1, \@a2, sub{sum(@$_)%3==0}, \@a3 ) ) {
   my($a1,$a2,$a3)=@$_;
   print "$a1,$a2,$a3\n";
 }

Gives the same output as this:

 for my $a1 (@a1){
   for my $a2 (@a2){
     next if 0==($a1+$a2)%3;
     for my $a3 (@a3){
       print "$a1,$a2,$a3\n";
     }
   }
 }

Examples, from the tests:

 my @a1 = (1,2);
 my @a2 = (10,20,30);
 my @a3 = (100,200,300,400);

 my $s = join"", map "*".join(",",@$_), cart(\@a1,\@a2,\@a3);
 ok( $s eq  "*1,10,100*1,10,200*1,10,300*1,10,400*1,20,100*1,20,200"
           ."*1,20,300*1,20,400*1,30,100*1,30,200*1,30,300*1,30,400"
           ."*2,10,100*2,10,200*2,10,300*2,10,400*2,20,100*2,20,200"
           ."*2,20,300*2,20,400*2,30,100*2,30,200*2,30,300*2,30,400");

 $s=join"",map "*".join(",",@$_), cart(\@a1,\@a2,\@a3,sub{sum(@$_)%3==0});
 ok( $s eq "*1,10,100*1,10,400*1,20,300*1,30,200*2,10,300*2,20,200*2,30,100*2,30,400");

=cut

sub cart
{
  my @ars=@_;
  my @res=map[$_],@{shift@ars};
  for my $ar (@ars){
    @res=grep{&$ar(@$_)}@res and next if ref($ar) eq 'CODE';
    @res=map{my$r=$_;map{[@$r,$_]}@$ar}@res;
  }
  return @res;
}


=head2 reduce

From: Why Functional Programming Matters: L<http://www.md.chalmers.se/~rjmh/Papers/whyfp.pdf>

L<http://www.md.chalmers.se/~rjmh/Papers/whyfp.html>

DON'T TRY THIS AT HOME, C PROGRAMMERS.

 sub reduce (&@) {
   my ($proc, $first, @rest) = @_;
   return $first if @rest == 0;
   local ($a, $b) = ($first, reduce($proc, @rest));
   return $proc->();
 }

Many functions can then be easily implemented by using reduce. Such as:

 sub mean { (reduce {$a + $b} @_) / @_ }

=cut

sub reduce (&@) {
  my ($proc, $first, @rest) = @_;
  return $first if @rest == 0;
  no warnings;
  local ($a, $b) = ($first, reduce($proc, @rest));
  return $proc->();
}

=head2 int2roman

Converts integers to roman numbers.

B<Examples:>

 print int2roman(1234);   # prints MCCXXXIV
 print int2roman(1971);   # prints MCMLXXI

Works for numbers up to 3999.

Subroutine from Peter J. Acklam (jacklam(&)math.uio.no)
at Mathematical institutt at University of Oslo:

 I = 1
 V = 5
 X = 10
 L = 50
 C = 100 I<centum>
 D = 500
 M = 1000 I<mille>

See L<http://en.wikipedia.org/wiki/Roman_numbers> for more.

=cut

sub int2roman{my@x=split//,sprintf'%04d',shift;my@r=('','I','V','X','L','C','D'
,'M');my@p=([],[1],[1,1],[1,1,1],[1,2],[2],[2,1],[2,1,1],[2,1,1,1],[1,3],[3])
;join'',@r[map($_+6,@{$p[$x[0]]}),map($_+4,@{$p[$x[1]]}),map($_+2,@{$p[$x[2
]]}),map($_+0,@{$p[$x[3]]})];}#print "@{[map{int2roman($_)}@ARGV]}\n";#JAPH!


=head2 num2code

See L</code2num>

=head2 code2num

C<num2code()> convert numbers (integers) from the normal decimal system to some arbitrary other number system.
That can be binary (2), oct (8), hex (16) or others.

Example:

 print num2code(255,2,"0123456789ABCDEF");  # prints FF
 print num2code(14,2,"0123456789ABCDEF");   # prints 0E

...because 255 are converted to hex (0-F) with a return of 2 digits: FF
...and 14 are converted to 0E, with leading 0 because of the second argument 2.

Example:

 print num2code(1234,16,"01")

Prints the 16 binary digits 0000010011010010 which is 1234 converted to binary 0s and 1s.

To convert back:

 print code2num("0000010011010010","01");  #prints 1234

C<num2code()> can be used to compress numeric IDs to something shorter:

 $chars='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_';
 $code=num2code("241274432",5,$chars);

=cut

sub num2code
{
  my($num,$sifre,$lovligetegn,$start)=@_;
  my $antlovligetegn=length($lovligetegn);
  my $key;
  no warnings;
  die if $num<$start;
  $num-=$start;
  for(1..$sifre){
    $key=substr($lovligetegn,$num%$antlovligetegn,1).$key;
    $num=int($num/$antlovligetegn);
  }
  die if $num>0;
  return $key;
}

sub code2num
{
  my($code,$lovligetegn,$start)=@_; $start=0 if not defined $start;
  my $antlovligetegn=length($lovligetegn);
  my $num=0;
  $num=$num*$antlovligetegn+index($lovligetegn,$_) for split//,$code;
  return $num+$start;
}


=head2 gcd

I< C<">The Euclidean algorithm (also called Euclid's algorithm) is an
algorithm to determine the greatest common divisor (gcd) of two
integers. It is one of the oldest algorithms known, since it appeared
in Euclid's Elements around 300 BC. The algorithm does not require
factoring.C<"> >

B<Input:> two or more positive numbers (integers, without decimals that is)

B<Output:> an integer

B<Example:>

  print gcd(12, 8);   # prints 4

Because (prime number) factoring of  12  is  2 * 2 * 3 and factoring 4 is 2 * 2
og the common ('overlapping') for both 12 and 4 is then 2 * 2. The result is 4.

B<Example two>:

  print gcd(90, 135, 315);               # prints 45
  print gcd(2*3*3*5, 3*3*3*5, 3*3*5*7);  # prints 45

...same tre numbers, 3*3*5 is common = 45.

 sub gcd { my($a,$b,@r)=@_; @r ? gcd($a,gcd($b,@r)) : $b==0 ? $a : gcd($b, $a % $b) }

=cut

sub gcd { my($a,$b,@r)=@_; @r ? gcd($a,gcd($b,@r)) : $b==0 ? $a : gcd($b, $a % $b) }

=head2 lcm

C<lcm()> finds the Least Common Multiple of two or more numbers (integers).

B<Input:> two or more positive numbers (integers)

B<Output:> an integer number

Example: C< 2/21 + 1/6 = 4/42 + 7/42 = 11/42>

Where 42 = lcm(21,6).

B<Example:>

  print lcm(45,120,75);   # prints 1800

Because the factors are:

  45 = 2^0 * 3^2 * 5^1
 120 = 2^3 * 3^1 * 5^1
  75 = 2^0 * 3^1 * 5^2

Take the bigest power of each primary number (2, 3 and 5 here).
Which is 2^3, 3^2 and 5^2. Multiplied this is 8 * 9 * 25 = 1800.

 sub lcm { my($a,$b,@r)=@_; @r ? lcm($a,lcm($b,@r)) : $a*$b/gcd($a,$b) }

=cut

sub lcm { my($a,$b,@r)=@_; @r ? lcm($a,lcm($b,@r)) : $a*$b/gcd($a,$b) }

=head2 pivot

Resembles the pivot table function in Excel.

C<pivot()> is used to spread out a slim and long table to a visually improved layout.

For instance spreading out the results of C<group by>-selects from SQL:

 pivot( arrayref, columnname1, columnname2, ...)

 pivot( ref_to_array_of_arrayrefs, @list_of_names_to_down_fields )

The first argument is a ref to a two dimensional table.

The rest of the arguments is a list which also signals the number of
columns from left in each row that is ending up to the left of the
data table, the rest ends up at the top and the last element of
each row ends up as data.

                   top1 top1 top1 top1
 left1 left2 left3 top2 top2 top2 top2
 ----- ----- ----- ---- ---- ---- ----
                   data data data data
                   data data data data
                   data data data data

Example:

 my @table=(
               ["1997","Gina", "Weight", "Summer",66],
               ["1997","Gina", "Height", "Summer",170],
               ["1997","Per",  "Weight", "Summer",75],
               ["1997","Per",  "Height", "Summer",182],
               ["1997","Hilde","Weight", "Summer",62],
               ["1997","Hilde","Height", "Summer",168],
               ["1997","Tone", "Weight", "Summer",70],
 
               ["1997","Gina", "Weight", "Winter",64],
               ["1997","Gina", "Height", "Winter",158],
               ["1997","Per",  "Weight", "Winter",73],
               ["1997","Per",  "Height", "Winter",180],
               ["1997","Hilde","Weight", "Winter",61],
               ["1997","Hilde","Height", "Winter",164],
               ["1997","Tone", "Weight", "Winter",69],
 
               ["1998","Gina", "Weight", "Summer",64],
               ["1998","Gina", "Height", "Summer",171],
               ["1998","Per",  "Weight", "Summer",76],
               ["1998","Per",  "Height", "Summer",182],
               ["1998","Hilde","Weight", "Summer",62],
               ["1998","Hilde","Height", "Summer",168],
               ["1998","Tone", "Weight", "Summer",70],
 
               ["1998","Gina", "Weight", "Winter",64],
               ["1998","Gina", "Height", "Winter",171],
               ["1998","Per",  "Weight", "Winter",74],
               ["1998","Per",  "Height", "Winter",183],
               ["1998","Hilde","Weight", "Winter",62],
               ["1998","Hilde","Height", "Winter",168],
               ["1998","Tone", "Weight", "Winter",71],
             );

.

 my @reportA=pivot(\@table,"Year","Name");
 print "\n\nReport A\n\n".tablestring(\@reportA);

Will print:

 Report A
 
 Year Name  Height Height Weight Weight
            Summer Winter Summer Winter
 ---- ----- ------ ------ ------ ------
 1997 Gina  170    158    66     64
 1997 Hilde 168    164    62     61
 1997 Per   182    180    75     73
 1997 Tone                70     69
 1998 Gina  171    171    64     64
 1998 Hilde 168    168    62     62
 1998 Per   182    183    76     74
 1998 Tone                70     71

.

 my @reportB=pivot([map{$_=[@$_[0,3,2,1,4]]}(@t=@table)],"Year","Season");
 print "\n\nReport B\n\n".tablestring(\@reportB);

Will print:

 Report B
 
 Year Season Height Height Height Weight Weight Weight Weight
             Gina   Hilde  Per    Gina   Hilde  Per    Tone
 ---- ------ ------ ------ -----  -----  ------ ------ ------
 1997 Summer 170    168    182    66     62     75     70
 1997 Winter 158    164    180    64     61     73     69
 1998 Summer 171    168    182    64     62     76     70
 1998 Winter 171    168    183    64     62     74     71

.

 my @reportC=pivot([map{$_=[@$_[1,2,0,3,4]]}(@t=@table)],"Name","Attributt");
 print "\n\nReport C\n\n".tablestring(\@reportC);

Will print:

 Report C
 
 Name  Attributt 1997   1997   1998   1998
                 Summer Winter Summer Winter
 ----- --------- ------ ------ ------ ------
 Gina  Height     170    158    171    171
 Gina  Weight      66     64     64     64
 Hilde Height     168    164    168    168
 Hilde Weight      62     61     62     62
 Per   Height     182    180    182    183
 Per   Weight      75     73     76     74
 Tone  Weight      70     69     70     71

.

 my @reportD=pivot([map{$_=[@$_[1,2,0,3,4]]}(@t=@table)],"Name");
 print "\n\nReport D\n\n".tablestring(\@reportD);

Will print:

 Report D
 
 Name  Height Height Height Height Weight Weight Weight Weight
       1997   1997   1998   1998   1997   1997   1998   1998
       Summer Winter Summer Winter Summer Winter Summer Winter
 ----- ------ ------ ------ ------ ------ ------ ------ ------
 Gina  170    158    171    171    66     64     64     64
 Hilde 168    164    168    168    62     61     62     62
 Per   182    180    182    183    75     73     76     74
 Tone                              70     69     70     71

Options:

Options to sort differently and show sums and percents are available. (...MORE DOC ON THAT LATER...)

See also L<Data::Pivot>

=cut

sub pivot
{
  my($tabref,@vertikalefelt)=@_;
  my %opt=ref($vertikalefelt[-1]) eq 'HASH' ? %{pop(@vertikalefelt)} : ();
  my $opt_sum=1 if $opt{sum};
  my $opt_pro=exists $opt{prosent}?$opt{prosent}||0:undef;
  my $sortsub          = $opt{'sortsub'}          || \&_sortsub;
  my $sortsub_bortover = $opt{'sortsub_bortover'} || $sortsub;
  my $sortsub_nedover  = $opt{'sortsub_nedover'}  || $sortsub;
  #print serialize(\%opt,'opt');
  #print serialize(\$opt_pro,'opt_pro');
  my $antned=0+@vertikalefelt;
  my $bakerst=-1+@{$$tabref[0]};
  my(%h,%feltfinnes,%sum);
  #print "Bakerst<$bakerst>\n";
  for(@$tabref){
    my $rad=join($;,@$_[0..($antned-1)]);
    my $felt=join($;,@$_[$antned..($bakerst-1)]);
    my $verdi=$$_[$bakerst];
    length($rad) or $rad=' ';
    length($felt) or $felt=' ';
    $h{$rad}{$felt}=$verdi;
    $h{$rad}{"%$felt"}=$verdi;
    if($opt_sum or defined $opt_pro){
      $h{$rad}{Sum}+=$verdi;
      $sum{$felt}+=$verdi;
      $sum{Sum}+=$verdi;
    }
    $feltfinnes{$felt}++;
    $feltfinnes{"%$felt"}++ if $opt_pro;
  }
  my @feltfinnes = sort $sortsub_bortover keys%feltfinnes;
  push @feltfinnes, "Sum" if $opt_sum;
  my @t=([@vertikalefelt,map{replace($_,$;,"\n")}@feltfinnes]);
  #print serialize(\@feltfinnes,'feltfinnes');
  #print serialize(\%h,'h');
  #print "H = ".join(", ",sort _sortsub keys%h)."\n";
  for my $rad (sort $sortsub_nedover keys(%h)){
    my @rad=(split($;,$rad),
	     map{
	       if(/^\%/ and defined $opt_pro){
		 my $sum=$h{$rad}{Sum};
		 my $verdi=$h{$rad}{$_};
		 if($sum!=0){
		   defined $verdi
                   ?sprintf("%*.*f",3+1+$opt_pro,$opt_pro,100*$verdi/$sum)
		   :$verdi;
		 }
		 else{
		   $verdi!=0?"div0":$verdi;
		 }
	       }
	       else{
		 $h{$rad}{$_};
	       }
	     }
	     @feltfinnes);
    push(@t,[@rad]);
  }
  push(@t,"-",["Sum",(map{""}(2..$antned)),map{print "<$_>\n";$sum{$_}}@feltfinnes]) if $opt_sum;
  return @t;
}

# default sortsub for pivot()

sub _sortsub {
  no warnings;
  #my $c=($a<=>$b)||($a cmp $b);
  #return $c if $c;
  #printf "%-30s %-30s  ",replace($a,$;,','),replace($b,$;,',');
  my @a=split $;,$a;
  my @b=split $;,$b;
  for(0..$#a){
    my $c=$a[$_]<=>$b[$_];
    return $c if $c and "$a[$_]$b[$_]"!~/[iI][nN][fF]|�/i; # inf(inity)
    $c=$a[$_]cmp$b[$_];
    return $c if $c;
  }
  return 0;
}

=head2 tablestring

B<Input:> a reference to an array of arrayrefs (a two dimensional table of values)

B<Output:> a string containing the table (a string of two or normally more lines)

The first arrayref in the list refers to a list of either column headings (scalar)
or ... (...more later...)

In this output table:

- the columns are not broader than necessary

- multi lined cell values are handled also

- and so are html-tags, if the output is to be used inside <pre>-tags on a web page.

- columns with just numbers are right justified

Example:

 perl -MAcme::Tools -le 'print tablestring([[qw/AA BB CCCC/],[123,23,"d"],[12,23,34],[77,88,99],["lin\nes",12,"asdff\nfdsa\naa"],[0,22,"adf"]])'

Prints this multi lined string:

 AA  BB CCCC
 --- -- -----
 123 23 d
 12  23 34
 77   8 99
 
 lin 12 asdff
 es     fdsa
        aa
 
 10  22 adf

Rows containing multi lined cells gets an empty line before and after the row, to separate it more clearly.

=cut

sub tablestring
{
  my $tab=shift;
  my %o=$_[0] ? %{shift()} : ();
  my $fjern_tom=$o{fjern_tomme_kolonner};
  my $ikke_space=$o{ikke_space};
  my $nodup=$o{nodup}||0;
  my $ikke_hodestrek=$o{ikke_hodestrek};
  my $pagesize=exists $o{pagesize} ? $o{pagesize}-3 : 9999999;
  my $venstretvang=$o{venstre};
  my(@bredde,@venstre,@hoeyde,@ikketom,@nodup);
  my $hode=1;
  my $i=0;
  my $j;
  for(@$tab){
    $j=0;
    $hoeyde[$i]=0;
    my $nodup_rad=$nodup;
    if(ref($_) eq 'ARRAY'){
      for(@$_){
	my $celle=$_;
	$bredde[$j]||=0;
	if($nodup_rad and $i>0 and $$tab[$i][$j] eq $$tab[$i-1][$j] || ($nodup_rad=0)){
	  $celle=$nodup==1?"":$nodup;
	  $nodup[$i][$j]=1;
	}
	else{
	  my $hoeyde=0;
	  my $bredere;
	  no warnings;
	  $ikketom[$j]=1 if !$hode && length($celle)>0;
	  for(split("\n",$celle)){
	    $bredere=/<input.+type=text.+size=(\d+)/i?$1:0;
	    s/<[^>]+>//g;
	    $hoeyde++;
	    s/&gt;/>/g;
	    s/&lt;/</g;
	    $bredde[$j]=length($_)+1+$bredere if length($_)+1+$bredere>$bredde[$j];
	    $venstre[$j]=1 if $_ && !/^\s*[\-\+]?(\d+|\d*\.\d+)\s*\%?$/ && !$hode;
	  }
	  if( $hoeyde>1 && !$ikke_space){
	    $hoeyde++ unless $hode;
	    $hoeyde[$i-1]++ if $i>1 && $hoeyde[$i-1]==1;
	  }
	  $hoeyde[$i]=$hoeyde if $hoeyde>$hoeyde[$i];
	}
	$j++;
      }
    }
    else{
      $hoeyde[$i]=1;
      $ikke_hodestrek=1;
    }
    $hode=0;
    $i++;
  }
  $i=$#hoeyde;
  $j=$#bredde;
  if($i==0 or $venstretvang) { @venstre=map{1}(0..$j)                         }
  else { for(0..$j){ $venstre[$_]=1 if !$ikketom[$_] }  }
  my @tabut;
  my $rad_startlinje=0;
  my @overskrift;
  my $overskrift_forrige;
  for my $x (0..$i){
    if($$tab[$x] eq '-'){
      my @tegn=map {$$tab[$x-1][$_]=~/\S/?"-":" "} (0..$j);
      $tabut[$rad_startlinje]=join(" ",map {$tegn[$_] x ($bredde[$_]-1)} (0..$j));
    }
    else{
      for my $y (0..$j){
	next if $fjern_tom && !$ikketom[$y];
	no warnings;
	
	my @celle=
            !$overskrift_forrige&&$nodup&&$nodup[$x][$y]
	    ?($nodup>0?():((" " x (($bredde[$y]-length($nodup))/2)).$nodup))
            :split("\n",$$tab[$x][$y]);
	for(0..($hoeyde[$x]-1)){
	  my $linje=$rad_startlinje+$_;
	  my $txt=shift @celle || '';
	  $txt=sprintf("%*s",$bredde[$y]-1,$txt) if length($txt)>0 && !$venstre[$y] && ($x>0 || $ikke_hodestrek);
	  $tabut[$linje].=$txt;
	  if($y==$j){
	    $tabut[$linje]=~s/\s+$//;
	  }
	  else{
	    my $bredere;
	       $bredere = $txt=~/<input.+type=text.+size=(\d+)/i?1+$1:0;
	    $txt=~s/<[^>]+>//g;
	    $txt=~s/&gt;/>/g;
	    $txt=~s/&lt;/</g;
	    $tabut[$linje].= ' ' x ($bredde[$y]-length($txt)-$bredere);
	  }
	}
      }
    }
    $rad_startlinje+=$hoeyde[$x];

    #--lage streker?
    if(not $ikke_hodestrek){
      if($x==0){
	for my $y (0..$j){
	  next if $fjern_tom && !$ikketom[$y];
	  $tabut[$rad_startlinje].=('-' x ($bredde[$y]-1))." ";
	}
	$rad_startlinje++;
	@overskrift=("",@tabut);
      }
      elsif(
	    $x%$pagesize==0 || $nodup>0&&!$nodup[$x+1][$nodup-1]
	    and $x+1<@$tab
	    and !$ikke_hodestrek
	    )
      {
	push(@tabut,@overskrift);
	$rad_startlinje+=@overskrift;
	$overskrift_forrige=1;
      }
      else{
	$overskrift_forrige=0;
      }
    }
  }#for x 
  return join("\n",@tabut)."\n";
}

=head2 upper

Returns input string as uppercase.

Used if perls build in C<uc()> for some reason does not convert ��� and other letters outsize a-z.

C<< ���������������������������� => ��������?������������������� >>

See also C<< perldoc -f uc >>

=head2 lower

Returns input string as lowercase.

Used if perls build in C<lc()> for some reason does not convert ��� and other letters outsize A-Z.

C<< ��������?������������������� => ��������?������������������� >>

See also C<< perldoc -f lc >>

=cut

#sub upper {my $str=shift;$str=~tr/a-z����������������������������/A-Z����������������������������/;$str}
#sub lower {my $str=shift;$str=~tr/A-Z����������������������������/a-z����������������������������/;$str}

sub upper {no warnings;my $str=@_?shift:$_;$str=~tr/a-z����������������������������/A-Z����������������������������/;$str}
sub lower {no warnings;my $str=@_?shift:$_;$str=~tr/A-Z����������������������������/a-z����������������������������/;$str}


=head2 serialize

Returns a data structure as a string. See also C<Data::Dumper>
(serialize was created long time ago before Data::Dumper appeared on
CPAN, before CPAN even...)

B<Input:> One to four arguments.

First argument: A reference to the structure you want.

Second argument: (optional) The name the structure will get in the output string.
If second argument is missing or is undef or '', it will get no name in the output.

Third argument: (optional) The string that is returned is also put
into a created file with the name given in this argument.  Putting a
C<< > >> char in from of the filename will append that file
instead. Use C<''> or C<undef> to not write to a file if you want to
use a fourth argument.

Fourth argument: (optional) A number signalling the depth on which newlines is used in the output.
The default is infinite (some big number) so no extra newlines are output.

B<Output:> A string containing the perl-code definition that makes that data structure.
The input reference (first input argument) can be to an array, hash or a string.
Those can contain other refs and strings in a deep data structure.

Limitations:

- Code refs are not handled (just returns C<sub{die()}>)

- Regex, class refs and circular recursive structures are also not handled.

B<Examples:>

  $a = 'test';
  @b = (1,2,3);
  %c = (1=>2, 2=>3, 3=>5, 4=>7, 5=>11);
  %d = (1=>2, 2=>3, 3=>\5, 4=>7, 5=>11, 6=>[13,17,19,{1,2,3,'asdf\'\\\''}],7=>'x');
  print serialize(\$a,'a');
  print serialize(\@b,'tab');
  print serialize(\%c,'c');
  print serialize(\%d,'d');
  print serialize(\("test'n roll",'brb "brb"'));
  print serialize(\%d,'d',undef,1);

Prints accordingly:

 $a='test';
 @tab=('1','2','3');
 %c=('1','2','2','3','3','5','4','7','5','11');
 %d=('1'=>'2','2'=>'3','3'=>\'5','4'=>'7','5'=>'11','6'=>['13','17','19',{'1'=>'2','3'=>'asdf\'\\\''}]);
 ('test\'n roll','brb "brb"');
 %d=('1'=>'2',
 '2'=>'3',
 '3'=>\'5',
 '4'=>'7',
 '5'=>'11',
 '6'=>['13','17','19',{'1'=>'2','3'=>'asdf\'\\\''}],
 '7'=>'x');

Areas of use:

- Debugging (first and foremost)

- Storing arrays and hashes and data structures of those on file, database or sending them over the net

- eval earlier stored string to get back the data structure

Be aware of the security implications of C<eval>ing a perl code string
stored somewhere that unauthorized users can change them! You are
probably better of using L<YAML::Syck> or L<Storable> without
enabling the CODE-options if you have such security issues.
See C<perldoc Storable> or C<perldoc B::Deparse> for how to decompile perl.

=head2 dserialize

Debug-serialize, dumping data structures for you to look at.

Same as C<serialize()> but the output is given a newline every 80th character.
(Every 80th or whatever C<$Acme::Tools::Dserialize_width> contains)

=cut

our $Dserialize_width=80;
sub dserialize{join "\n",serialize(@_)=~/(.{1,$Dserialize_width})/gs}
sub serialize
{
  no warnings;
  my($r,$navn,$filnavn,$nivaa)=@_;
  my @r=(undef,undef,($nivaa||0)-1);
  if($filnavn){
    open(FIL,">$filnavn")||die("FEIL: kunne ikke �pne $filnavn\n".kallstack());
    my $ret=serialize($r,$navn,undef,$nivaa);
    print FIL "$ret\n1;\n";
    close FIL;
    return $ret;
  }

  if(ref($r) eq 'SCALAR'){
    return "\$$navn=".serialize($r,@r).";\n" if $navn;
    return "undef" unless defined $$r;
    my $ret=$$r;
    $ret=~s/\\/\\\\/g;
    $ret=~s/\'/\\'/g;
    return "'$ret'";
  }
  elsif(ref($r) eq 'ARRAY'){
    return "\@$navn=".serialize($r,@r).";\n" if $navn;
    my $ret="(";
    for(@$r){
      $ret.=serialize(\$_,@r).",";
      $ret.="\n" if $nivaa>=0;
    }
    $ret=~s/,$//;
    $ret.=")";
    $ret.=";\n" if $navn;
    return $ret;
  }
  elsif(ref($r) eq 'HASH'){
    return "\%$navn=".serialize($r,@r).";\n" if $navn;
    my $ret="(";
    for(sort keys %$r){
      $ret.=serialize(\$_,@r)."=>".serialize(\$$r{$_},@r).",";
      $ret.="\n" if $nivaa>=0;
    }
    $ret=~s/,$//;
    $ret.=")";
    $ret.=";\n" if $navn;
    return $ret;
  }
  elsif(ref($$r) eq 'ARRAY'){
#    my $ret=serialize($$r,@r);
#    substr($ret,0,1)="[";
#    substr($ret,-1)="]\n";
#    return $ret;
    return "\@$navn=".serialize($r,@r).";\n" if $navn;
    my $ret="[";
    for(@$$r){
      $ret.=serialize(\$_,@r).",";
      $ret.="\n" if not defined $nivaa or $nivaa>=0;
    }
    $ret=~s/,$//;
    $ret.="]";
    $ret.=";\n" if $navn;
    return $ret;

  }
  elsif(ref($$r) eq 'HASH'){
#    my $ret=serialize($$r,@r);
#    substr($ret,0,1)="{";
#    substr($ret,-1,1)="}\n";
#    return $ret;
    return "\%$navn=".serialize($r,@r).";\n" if $navn;
    my $ret="{";
    for(sort keys %$$r){
      $ret.=serialize(\$_,@r)."=>".serialize(\$$$r{$_},@r).",";
      $ret.="\n" if $nivaa>=0;
    }
    $ret=~s/,$//;
    $ret.="}";
    $ret.=";\n" if $navn;
    return $ret;
  }
  elsif(ref($$r) eq 'SCALAR'){
    return "\\".serialize($$r,@r);
  }
  elsif(ref($r) eq 'LVALUE'){
    return serialize(\"$$r",@r);
  }
  elsif(ref($$r) eq 'CODE'){
    #warn "Fors�k p� � serialisere (serialize) CODE";
    return 'sub{die "Kan ikke serialisere CODE-referanser, se istedet B::Deparse og Storable"}'
  }
  elsif(ref($$r) eq 'GLOB'){
    warn "Fors�k p� � serialisere (serialize) en GLOB";
    return '\*STDERR'
  }
  else{
    my $tilbake;
    my($pakke,$fil,$linje,$sub,$hasargs,$wantarray);
      ($pakke,$fil,$linje,$sub,$hasargs,$wantarray)=caller($tilbake++) until $sub ne 'serialize' || $tilbake>20;
    die("FEIL:serialize: argument skal v�re referanse!\n".
        "\$r=$r\n".
        "ref(\$r)   = ".ref($r)."\n".
        "ref(\$\$r) = ".ref($$r)."\n".
        "kallstack:\n".kallstack());
  }
}

# =head2 convert
# 
# Converts between units of measurements.
# 
# Examples:
# 
#  print convert(70,"cm","in");  #prints 27.5590551181102
#
# See L<Math::Units>
# 
# =cut
# 
# sub convert
# {
#   my($num,$from,$to)=@_;
#   my %factors
#     =(
#       #length
#       m => 1,
# 
#       #time
#       s => 1,
# 
#       #volume
# 
#       #ampere
# 
#       #temperature
# 
#       #force
# 
#      )
# }


# =head2 timestr
# 
# Converts epoch or YYYYMMDD-HH24:MI:SS time string to other forms of time.
# 
# B<Input:> One, two or three arguments.
# 
# B<First argument:> A format string.
# 
# B<Second argument: (optional)> An epock C<time()> number or a time
# string of the form YYYYMMDD-HH24:MI:SS. I no second argument is gives,
# picks the current C<time()>.
# 
# B<Thirs argument: (optional> True eller false. If true and first argument is eight digits:
# Its interpreted as a YYYYMMDD time string, not an epoch time.
# If true and first argument is six digits its interpreted as a DDMMYY date.
# 
# B<Output:> a date or clock string on the wanted form.
# 
# B<Exsamples:>
# 
# Prints C<< 3. july 1997 >> if thats the dato today:
# 
#  perl -MAcme::Tools -le 'print timestr("D. month YYYY")'
# 
#  print timestr"HH24:MI");              # prints 23:55 if thats the time now
#  print timestr"HH24:MI",time());       # ...same,since time() is the default
#  print timestr"HH:MI",time()-5*60);    # prints 23:50 if that was the time 5 minutes ago
#  print timestr"HH:MI",time()-5*60*60); # print 18:55 if thats the time 5 hours ago
#  timestr"Day D. month YYYY HH:MI");    # Saturday  juli 2004 23:55       (stor L liten j)
#  timestr"dag D. M�ned ���� HH:MI");    # l�rdag 3. Juli 2004 23:55       (omvendt)
#  timestr"DG DD. MONTH YYYY HH24:MI");  # L�R 03. JULY 2004 23:55         (HH24 = HH, month=engelsk)
#  timestr"DD-MON-YYYY");                # 03-MAY-2004                     (mon engelsk)
#  timestr"DD-M�N-YYYY");                # 03-MAI-2004                     (m�n norsk)
# 
# B<Formatstrengen i argument to:>
# 
# Formatstrengen kan innholde en eller flere av f�lgende koder.
# 
# Formatstrengen kan inneholde tekst, som f.eks. C<< tid('Klokken er: HH:MI') >>.
# Teksten her vil ikke bli konvertert. Men det anbefales � holde tekst utenfor
# formatstrengen, siden framtidige koder kan erstatte noen tegn i teksten med tall.
# 
# Der det ikke st�r annet: bruk store bokstaver.
# 
#  YYYY    �rstallet med fire sifre
#  ����    Samme som YYYY (norsk)
#  YY      �rstallet med to sifre, f.eks. 04 for 2004 (anbefaler ikke � bruke tosifrede �r)
#  ��      Samme som YY (norsk)
#  yyyy    �rtallet med fire sifre, men skriver ingenting dersom �rstallet er �rets (plass-sparing, ala tidstrk() ).
#  ����    Samme som yyyy
#  MM      M�ned, to sifre. F.eks. 08 for august.
#  DD      Dato, alltid to sifer. F.eks 01 for f�rste dag i en m�ned.
#  D       Dato, ett eller to sifre. F.eks. 1 for f�rste dag i en m�ned.
#  HH      Time. Fra 00, 01, 02 osv opp til 23.
#  HH24    Samme som HH. Ingen forskjell. Tatt med for � fjerne tvil om det er 00-12-11 eller 00-23
#  HH12    NB: Kl 12 blir 12, kl 13 blir 01, kl 14 blir 02 osv .... 23 blir 11,
#          MEN 00 ETTER MIDNATT BLIR 12 ! Oracle er ogs� slik.
#  TT      Samme som HH. Ingen forskjell. Fra 00 til 23. TT24 og TT12 finnes ikke.
#  MI      Minutt. Fra 00 til 59.
#  SS      Sekund. Fra 00 til 59.
#  
#  M�ned   Skriver m�nedens fulle navn p� norsk. Med stor f�rstebokstav, resten sm�.
#          F.eks. Januar, Februar osv. NB: V�r oppmerksom p� at m�neder p� norsk normal
#          skrives med liten f�rstebokstav (om ikke i starten av setning). Alt for mange
#          gj�r dette feil. P� engelsk skrives de ofte med stor f�rstebokstav.
#  M�ne    Skriver m�nedens navn forkortet og uten punktum. P� norsk. De med tre eller
#          fire bokstaver forkortes ikke: Jan Feb Mars Apr Mai Juni Juli Aug Sep Okt Nov Des
#  M�ne.   Samme som M�ne, men bruker punktum der det forkortes. Bruker alltid fire tegn.
#          Jan. Feb. Mars Apr. Mai Juni Juli Aug. Sep. Okt. Nov. Des.
#  M�n     Tre bokstaver, norsk: Jan Feb Mar Apr Mai Jun Jul Aug Sep Okt Nov Des
#  
#  Month   Engelsk: January February May June July October December, ellers = norsk.
#  Mont    Engelsk: Jan Feb Mars Apr May June July Aug Sep Oct Nov Dec
#  Mont.   Engelsk: Jan. Feb. Mars Apr. May June July Aug. Sep. Oct. Nov. Dec.
#  Mon     Engelsk: Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
#  
#  m�ned m�ne m�ne. m�n       Samme, men med liten f�rstebokstav. P� norsk.
#  month mont mont. mon       Samme, men med liten f�rstebokstav. P� engelsk.
#  M�NED M�NE M�NE. M�N       Samme, men med alle bokstaver store. P� norsk.
#  MONTH MONT MONT. MON       Samme, men med alle bokstaver store. P� engelsk.
#  
#  Dag     Dagens navn p� norsk. Stor f�rstebokstav, resten sm�. Mandag Tirsdag Onsdag Torsdag
#          Fredag L�rdag S�ndag.
#  Dg      Dagens navn p� norsk forkortet. Stor f�rstebokstav, resten sm�.
#          Alltid tre bokstaver: Man Tir Ons Tor Fre L�r S�n
#  Day     Samme som Dag, men p� engelsk. Monday Tuesday Wednesday Thursday Friday Saturday Sunday
#  Dy      Samme som Dg, men p� engelsk. Alltid tre bokstaver: Mon Tue Wed Thu Fri Sat Sun
#  
#  dag dg day dy DAG DG DAY DY       ....du klarer sikkert � gjette...
#  
#  UKE     Ukenr ett eller to siffer. Bruker ISO-definisjonen som brukes stort sett i hele verden unntatt USA.
#  UKENR   Ukenr, alltid to siffer, 01 02 osv. Se uke() et annet sted i SO::Bibl for mer om dette.
# 
# 
#  Gjenst�r:  Dag- og m�nedsnavn p� nynorsk og samisk.
# 
#  Gjenst�r:  Dth => 1st eller 2nd hvis dato er den f�rste eller andre
#   
#  Gjenst�r:  M => M�ned ett eller to sifre, slik D er dato med ett eller to. Vanskelig/umulig(?)
#   
#  Gjenst�r:  J => "julian day"....
#   
#  Gjenst�r:  Sjekke om den takler tidspunkt for sv�rt lenge siden eller om sv�rt lenge...
#             Kontroll med kanskje die ved input
#   
#  Gjenst�r:  sub dit() (tid baklengs... eller et bedre navn) for � konvertere andre veien.
#             Som med to_date og to_char i Oracle. Se evt L<Date::Parse> isteden.
#   
#  Gjenst�r:  Hvis formatstrengen er DDMMYY (evt DDMM��), og det finnes en tredje argument,
#             s� vil den tredje argumenten sees p� som personnummer og DD vil bli DD+40
#             eller MM vil bli MM+50 hvis personnummeret medf�rer D- eller S-type f�dselsnr.
#             Hmm, kanskje ikke. Se heller  sub foedtdato  og  sub fnr  m.fl.
#  
#  Gjenst�r:  Testing p� tidspunkter p� mer enn hundre �r framover eller tilbake i tid.
# 
# Se ogs� L</tidstrk> og L</tidstr>
# 
# =cut
# 
# our %SObibl_tid_strenger;
# our $SObibl_tid_pattern;
# 
# sub tid
# {
#   return undef if @_>1 and not defined $_[1];
#   return 1900+(localtime())[5] if $_[0]=~/^(?:����|YYYY)$/ and @_==1; # kjappis for tid("����") og tid("YYYY")
# 
#   my($format,$time,$er_dato)=@_;
#   
# 
#   $time=time() if @_==1;
# 
#   ($time,$format)=($format,$time)
#     if $format=~/^[\d+\:\-]+$/; #swap hvis format =~ kun tall og : og -
# 
#   $format=~s,([Mm])aa,$1�,;
#   $format=~s,([Mm])AA,$1�,;
# 
#   $time = yyyymmddhh24miss_time("$1$2$3$4$5$6")
#     if $time=~/^((?:19|20|18)\d\d)          #yyyy
#                 (0[1-9]|1[012])             #mm
#                 (0[1-9]|[12]\d|3[01]) \-?   #dd
#                 ([01]\d|2[0-3])       \:?   #hh24
#                 ([0-5]\d)             \:?   #mi
#                 ([0-5]\d)             $/x;  #ss
# 
#   $time = yyyymmddhh24miss_time(dato_ok("$1$2$3")."000000")
#     if $time=~/^(\d\d)(\d\d)(\d\d)$/ and $er_dato;
# 
#   $time = yyyymmddhh24miss_time("$1$2${3}000000")
#     if $time=~/^((?:18|19|20)\d\d)(\d\d)(\d\d)$/ and $er_dato;
# 
#   my @lt=localtime($time);
#   if($format){
#     unless(defined %SObibl_tid_strenger){
#       %SObibl_tid_strenger=
# 	  ('M�NED' => [4, 'JANUAR','FEBRUAR','MARS','APRIL','MAI','JUNI','JULI',
# 		          'AUGUST','SEPTEMBER','OKTOBER','NOVEMBER','DESEMBER' ],
# 	   'M�ned' => [4, 'Januar','Februar','Mars','April','Mai','Juni','Juli',
# 		          'August','September','Oktober','November','Desember'],
# 	   'm�ned' => [4, 'januar','februar','mars','april','mai','juni','juli',
# 		          'august','september','oktober','november','desember'],
# 	   'M�NE.' => [4, 'JAN.','FEB.','MARS','APR.','MAI','JUNI','JULI','AUG.','SEP.','OKT.','NOV.','DES.'],
# 	   'M�ne.' => [4, 'Jan.','Feb.','Mars','Apr.','Mai','Juni','Juli','Aug.','Sep.','Okt.','Nov.','Des.'],
# 	   'm�ne.' => [4, 'jan.','feb.','mars','apr.','mai','juni','juli','aug.','sep.','okt.','nov.','des.'],
# 	   'M�NE'  => [4, 'JAN','FEB','MARS','APR','MAI','JUNI','JULI','AUG','SEP','OKT','NOV','DES'],
# 	   'M�ne'  => [4, 'Jan','Feb','Mars','Apr','Mai','Juni','Juli','Aug','Sep','Okt','Nov','Des'],
# 	   'm�ne'  => [4, 'jan','feb','mars','apr','mai','juni','juli','aug','sep','okt','nov','des'],
# 	   'M�N'   => [4, 'JAN','FEB','MAR','APR','MAI','JUN','JUL','AUG','SEP','OKT','NOV','DES'],
# 	   'M�n'   => [4, 'Jan','Feb','Mar','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Des'],
# 	   'm�n'   => [4, 'jan','feb','mar','apr','mai','jun','jul','aug','sep','okt','nov','des'],
# 
# 	   'MONTH' => [4, 'JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY',
# 		          'AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'],
# 	   'Month' => [4, 'January','February','March','April','May','June','July',
# 		          'August','September','October','November','December'],
# 	   'month' => [4, 'january','february','march','april','may','june','july',
# 		          'august','september','october','november','december'],
# 	   'MONT.' => [4, 'JAN.','FEB.','MAR.','APR.','MAY','JUNE','JULY','AUG.','SEP.','OCT.','NOV.','DEC.'],
# 	   'Mont.' => [4, 'Jan.','Feb.','Mar.','Apr.','May','June','July','Aug.','Sep.','Oct.','Nov.','Dec.'],
# 	   'mont.' => [4, 'jan.','feb.','mar.','apr.','may','june','july','aug.','sep.','oct.','nov.','dec.'],
# 	   'MONT'  => [4, 'JAN','FEB','MAR','APR','MAY','JUNE','JULY','AUG','SEP','OCT','NOV','DEC'],
# 	   'Mont'  => [4, 'Jan','Feb','Mar','Apr','May','June','July','Aug','Sep','Oct','Nov','Dec'],
# 	   'mont'  => [4, 'jan','feb','mar','apr','may','june','july','aug','sep','oct','nov','dec'],
# 	   'MON'   => [4, 'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'],
# 	   'Mon'   => [4, 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
# 	   'mon'   => [4, 'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'],
# 	   'DAY'   => [6, 'SUNDAY','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY'],
# 	   'Day'   => [6, 'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],
# 	   'day'   => [6, 'sunday','monday','tuesday','wednesday','thursday','friday','saturday'],
# 	   'DY'    => [6, 'SUN','MON','TUE','WED','THU','FRI','SAT'],
# 	   'Dy'    => [6, 'Sun','Mon','Tue','Wed','Thu','Fri','Sat'],
# 	   'dy'    => [6, 'sun','mon','tue','wed','thu','fri','sat'],
# 	   'DAG'   => [6, 'S�NDAG','MANDAG','TIRSDAG','ONSDAG','TORSDAG','FREDAG','L�RDAG'],
# 	   'Dag'   => [6, 'S�ndag','Mandag','Tirsdag','Onsdag','Torsdag','Fredag','L�rdag'],
# 	   'dag'   => [6, 's�ndag','mandag','tirsdag','onsdag','torsdag','fredag','l�rdag'],
# 	   'DG'    => [6, 'S�N','MAN','TIR','ONS','TOR','FRE','L�R'],
# 	   'Dg'    => [6, 'S�n','Man','Tir','Ons','Tor','Fre','L�r'],
# 	   'dg'    => [6, 's�n','man','tir','ons','tor','fre','l�r'],
# 	   );
#       for(qw(MAANED Maaned maaned MAAN Maan maan),'MAANE.','Maane.','maane.'){
# 	$SObibl_tid_strenger{$_}=$SObibl_tid_strenger{replace($_,"aa","�","AA","�")};
#       }
#       $SObibl_tid_pattern=join("|",map{quotemeta($_)}
#  	                           sort{length($b)<=>length($a)}
#                                    keys %SObibl_tid_strenger);
#       #uten sort kan "m�ned" bli "mared", fordi "m�n"=>"mar"
#     }
#     $format=~s/($SObibl_tid_pattern)/$SObibl_tid_strenger{$1}[1+$lt[$SObibl_tid_strenger{$1}[0]]]/g;
# 
#     $format=~s/TT|tt/HH/;
#     $format=~s/��/YY/g;$format=~s/��/yy/g;
#     $format=~s/YYYY             /1900+$lt[5]                  /gxe;
#     $format=~s/(\s?)yyyy        /$lt[5]==(localtime)[5]?"":$1.(1900+$lt[5])/gxe;
#     $format=~s/YY               /sprintf("%02d",$lt[5]%100)   /gxei;
#     $format=~s/MM               /sprintf("%02d",$lt[4]+1)     /gxe;
#     $format=~s/mm               /sprintf("%d",$lt[4]+1)       /gxe;
#     $format=~s/DD               /sprintf("%02d",$lt[3])       /gxe;
#     $format=~s/D(?![AaGgYyEeNn])/$lt[3]                       /gxe; #EN pga desember og wednesday
#     $format=~s/dd               /sprintf("%d",$lt[3])         /gxe;
#     $format=~s/hh12|HH12        /sprintf("%02d",$lt[2]<13?$lt[2]||12:$lt[2]-12)/gxe;
#     $format=~s/HH24|HH24|HH|hh  /sprintf("%02d",$lt[2])       /gxe;
#     $format=~s/MI               /sprintf("%02d",$lt[1])       /gxei;
#     $format=~s/SS               /sprintf("%02d",$lt[0])       /gxei;
#     $format=~s/UKENR            /sprintf("%02d",ukenr($time)) /gxei;
#     $format=~s/UKE              /ukenr($time)                 /gxei;
#     $format=~s/SS               /sprintf("%02d",$lt[0])       /gxei;
# 
#     return $format;
#   }
#   else{
#     return sprintf("%04d%02d%02d%02d%02d%02d",1900+$lt[5],1+$lt[4],@lt[3,2,1,0]);
#   }
# }

=head2 easter

Input: A year, four digits

Output: two numbers: month and date of Easter Sunday that year. Month 3 means March and 4 means April.

 sub easter { use integer;my$Y=shift;my$C=$Y/100;my$L=($C-$C/4-($C-($C-17)/25)/3+$Y%19*19+15)%30;
             (($L-=$L>28||($L>27?1-(21-$Y%19)/11:0))-=($Y+$Y/4+$L+2-$C+$C/4)%7)<4?($L+28,3):($L-3,4) }

...is a "golfed" version of Oudins algorithm (1940) L<http://astro.nmsu.edu/~lhuber/leaphist.html>
(see also http://www.smart.net/~mmontes/ec-cal.html )

Valid for any Gregorian year. Dates repeat themselves after
70499183 lunations = 2081882250 days = ca 5699845 year ...but within that time frame
earth will have different rotation time around the sun and spin time around itself.

=cut

sub easter { use integer;my$Y=shift;my$C=$Y/100;my$L=($C-$C/4-($C-($C-17)/25)/3+$Y%19*19+15)%30;
             (($L-=$L>28||($L>27?1-(21-$Y%19)/11:0))-=($Y+$Y/4+$L+2-$C+$C/4)%7)<4?($L+28,3):($L-3,4) }


=head2 time_fp

No input arguments.

Return the same number as perls C<time()> except with decimals (fractions of a second, _fp as in floating point number).

 print time_fp(),"\n";
 print time(),"\n";

Could write:

 1116776232.38632
 1116776232

...if that is the time now.

C<time_fp()> C<requires>  L<Time::HiRes> and if that module is not installed or not available, it returns the result of C<time()>.

=cut

sub time_fp    # {return 0+gettimeofday} is just as well?
{
    eval{ require Time::HiRes } or return time();
    my($sec,$mic)=Time::HiRes::gettimeofday();
    return $sec+$mic/1e6; #1e6 not portable?
}

=head2 sleep_fp

sleep_fp() works just as the built in C<< sleep() >>, but accepts fractional seconds. Example:

 sleep_fp(0.02);  # sleeps for 20 milliseconds

Sub sleep_fp requires L<Time::HiRes> internally, thus it might take
some extra time first time called. To avoid that, use C<< use Time::HiRes >> in your code.

=cut

sub sleep_fp{ eval{require Time::HiRes} or (sleep(shift()),return);Time::HiRes::sleep(shift()) }

1;
__END__

=head1 HISTORY

Release history

 0.11   Dec 2008     Improved doc
 0.10   Dec 2008

=head1 SEE ALSO

=head1 AUTHOR

Kjetil Skotheim, E<lt>kjetil.skotheim@gmail.com<gt>, E<lt>kjetil.skotheim@usit.uio.noE<gt>

=head1 COPYRIGHT AND LICENSE

1995-2008, Kjetil Skotheim

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
