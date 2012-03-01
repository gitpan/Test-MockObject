
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Perl extension for emulating troublesome interfaces",
  "AUTHOR" => "chromatic",
  "BUILD_REQUIRES" => {
    "Test::Exception" => 0,
    "Test::More" => "0.98",
    "Test::Warn" => "0.23",
    "base" => 0,
    "overload" => 0,
    "vars" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Test-MockObject",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Test::MockObject",
  "PREREQ_PM" => {
    "CGI" => 0,
    "Carp" => 0,
    "Devel::Peek" => 0,
    "Scalar::Util" => 0,
    "Test::Builder" => 0,
    "Test::Exception" => "0.31",
    "Test::More" => "0.98",
    "Test::Warn" => "0.23",
    "UNIVERSAL::can" => "1.20110617",
    "UNIVERSAL::isa" => "1.20110614",
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "1.20120301",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



