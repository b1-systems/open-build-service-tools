#
# Copyright (c) 2014 Christian Schneemann, B1 Systems GmbH
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program (see the file COPYING); if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
################################################################
#
# Module send emails
#

package notify_email;

#use BSConfig;
use Mail::Sendmail;
use lib "/usr/lib/obs/server/plugins/";
use notify_email_config;
use XML::Simple;

use strict;
use warnings;

sub new {
  my $self = {};
  bless $self, shift;
  return $self;
}

sub notify {
  my ($self, $type, $paramRef ) = @_;

  $type = "UNKNOWN" unless $type;

  # make srcserver happy during start, paramRef is not set here..
  my $project = $paramRef->{'project'} || "";


  my ($to_mail, $cc_mail);

  if ($type eq "BUILD_FAIL" && $self->notify_setting($project))
  {
    $to_mail = "";
    $cc_mail = "";
    my @maintainers = $self->get_obs_maintainer($paramRef->{'project'}, $paramRef->{'package'});
    my @maintainers_mail = map{ $self->get_obs_email($_)  } @maintainers;

    my @unique_mail = ();

    LOOP1: while ( scalar @maintainers_mail ) {
      my $addr = pop(@maintainers_mail);
      next LOOP1 if ( $to_mail eq $addr );
      foreach $a (@maintainers_mail) {
        next LOOP1 if ( $a eq $addr );
      }
      push @unique_mail, $addr;
    }

    $to_mail = join(", ", @unique_mail) || "";

    my %mail = ( To => $to_mail,
                 From => $notify_email_config::from_mail,
                 CC => $cc_mail,
                 Subject => "BUILD_FAILED $paramRef->{'project'} $paramRef->{'repository'} $paramRef->{'arch'} $paramRef->{'package'}",
                 'X-OBS-PROJECT' =>$paramRef->{'project'},
                 'X-OBS-REPOSITORY' => $paramRef->{'repository'},
                 'X-OBS-ARCH' => $paramRef->{'arch'},
                 'X-OBS-PACKAGE' => $paramRef->{'package'},
               );
    $mail{'message'} = "Your build has failed, please fix\n";
    $mail{'message'} .="\n###\n";
    $mail{'message'} .= "\n";
    $mail{'message'} .= "Project:         $paramRef->{'project'}\n";
    $mail{'message'} .= "Package:         $paramRef->{'package'}\n";
    $mail{'message'} .= "Repository:      $paramRef->{'repository'}\n";
    $mail{'message'} .= "Arch:            $paramRef->{'arch'}\n";
    $mail{'message'} .= "Version:         $paramRef->{'versrel'}\n";
    $mail{'message'} .= "Reason:          $paramRef->{'reason'}\n";
    $mail{'message'} .= "OBS maintainers: @maintainers\n";

    $mail{'message'} .= "Buildlog:        $notify_email_config::api_url/build/$paramRef->{'project'}/$paramRef->{'repository'}/$paramRef->{'arch'}/$paramRef->{'package'}/_log\n";
    $mail{'message'} .= "\n";

    if (!sendmail %mail) {
      print STDERR "mail to $to_mail could not be sent using notify_email plugin: $Mail::Sendmail::error\n";
    }
  }
}

sub notify_setting {
  my ($self, $project) = @_;
  my ($xml, $attributes);

  $xml = $self->call_obs_api("/source/$project/_attribute/$notify_email_config::notify_attr");

  if ($xml) {
    $attributes = XMLin($xml, KeyAttr => { }, ForceArray =>0);
  }

  return $attributes->{attribute}->{'value'} || 0;
}

sub unique {
  my ($self, @a) = @_;
  return keys %{{ map { $_ => 1 } @a }};
}

sub get_obs_maintainer {
  my ($self, $project, $package) = @_;
  my ($request, @persons, $xml, $meta);
  if ($package) {
    $request = "/source/$project/$package/_meta";
    $xml = $self->call_obs_api($request);
    $meta = XMLin($xml, KeyAttr => {}, ForceArray => [ 'person'] );

    @persons = grep { $_->{'role'} =~ /$notify_email_config::notified_roles/i  } @{$meta->{person}};
  }
  $request = "/source/$project/_meta";

  $xml = $self->call_obs_api($request);
  $meta = XMLin($xml, KeyAttr => {}, ForceArray => ['person'] );

  push @persons, grep { $_->{'role'} =~ /$notify_email_config::notified_roles/i  } @{$meta->{person}};

  @persons = $self->unique(map{ $_->{'userid'} } @persons);

  return @persons;
}

sub get_obs_email {
  my ($self, $user) = @_;

  my $xml = $self->call_obs_api("/person/$user");

  $xml = XMLin($xml, KeyAttr => {}, ForceArray => 0); 

  return $xml->{'email'};
}


sub call_obs_api {
    my ($self, $api_call) = @_;
    return `$notify_email_config::curl_binary -k -s -u $notify_email_config::api_user:$notify_email_config::api_pass $notify_email_config::api_url/$api_call`;
}


1;
