# BEGIN BPS TAGGED BLOCK {{{
#
# COPYRIGHT:
#
# This software is Copyright (c) 1996-2013 Best Practical Solutions, LLC
#                                          <sales@bestpractical.com>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:
#
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
#
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
#
#
# CONTRIBUTION SUBMISSION POLICY:
#
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to Best Practical Solutions, LLC.)
#
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# Request Tracker, to Best Practical Solutions, LLC, you confirm that
# you are the copyright holder for those contributions and you grant
# Best Practical Solutions,  LLC a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# END BPS TAGGED BLOCK }}}

use strict;
use warnings;

package RT::Pod::HTML;
use base 'Pod::Simple::XHTML';

use HTML::Entities qw//;

sub new {
    my $self = shift->SUPER::new(@_);
    $self->index(1);
    $self->anchor_items(1);
    return $self;
}

sub decode_entities {
    my $self = shift;
    return HTML::Entities::decode_entities($_[0]);
}

sub perldoc_url_prefix { "http://metacpan.org/module/" }

sub html_header { '' }
sub html_footer {
    my $self = shift;
    my $toc  = "../" x ($self->batch_mode_current_level - 1);
    return '<a href="./' . $toc . '">&larr; Back to index</a>';
}

sub start_F {
    $_[0]{'scratch_F'} = $_[0]{'scratch'};
    $_[0]{'scratch'}   = "";
}
sub end_F   {
    my $self = shift;
    my $text = $self->{scratch};
    my $file = $self->decode_entities($text);

    if (my $local = $self->resolve_local_link($file)) {
        $text = qq[<a href="$local">$text</a>];
    }

    $self->{'scratch'} = delete $self->{scratch_F};
    $self->{'scratch'} .= "<i>$text</i>";
}

sub _end_head {
    my $self = shift;
    $self->{scratch} = '<a href="#___top">' . $self->{scratch} . '</a>';
    return $self->SUPER::_end_head(@_);
}

sub resolve_pod_page_link {
    my $self = shift;
    my ($name, $section) = @_;

    # Only try to resolve local links if we're in batch mode and are linking
    # outside the current document.
    return $self->SUPER::resolve_pod_page_link(@_)
        unless $self->batch_mode and $name;

    my $local = $self->resolve_local_link($name, $section);

    return $local
        ? $local
        : $self->SUPER::resolve_pod_page_link(@_);
}

sub resolve_local_link {
    my $self = shift;
    my ($name, $section) = @_;

    $section = defined $section
        ? '#' . $self->idify($section, 1)
        : '';

    my $local;
    if ($name =~ /^RT::/) {
        $local = join "/",
                  map { $self->encode_entities($_) }
                split /::/, $name;
    }
    elsif ($name =~ /^rt[-_]/) {
        $local = $self->encode_entities($name);
    }
    elsif ($name eq "RT_Config" or $name eq "RT_Config.pm") {
        $local = "RT_Config";
    }
    # These matches handle links that look like filenames, such as those we
    # parse out of F<> tags.
    elsif (   $name =~ m{^(?:lib/)(RT/[\w/]+?)\.pm$}
           or $name =~ m{^(?:docs/)(.+?)\.pod$})
    {
        $local = join "/",
                  map { $self->encode_entities($_) }
                split /\//, $1;
    }

    if ($local) {
        # Resolve links correctly by going up
        my $depth = $self->batch_mode_current_level - 1;
        return ($depth ? "../" x $depth : "") . "$local.html$section";
    } else {
        return;
    }
}

1;
