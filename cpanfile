requires 'Moo'            => '1.003001';
requires 'URI'            => '1.60';
requires 'Carp'           => '1.26';
requires 'Const::Fast'    => '0.013';
requires 'LWP::UserAgent' => '6.05';

on 'configure' => sub {
    requires 'ExtUtils::MakeMaker' => '6.30';
};

on 'test'    => sub { };
on 'develop' => sub { };
