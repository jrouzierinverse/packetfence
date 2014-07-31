package captiveportal::Controller::WirelessProfile;
use Moose;

BEGIN { extends 'captiveportal::PacketFence::Controller::WirelessProfile'; }

=head1 NAME

captiveportal::Controller::Root - Root Controller for captiveportal

=head1 DESCRIPTION

[enter your description here]

=cut

sub profile_xml : Path('/profile.xml') : Args(0) {
    my ($self, $c) = @_;
    $c->stash->{filename} = "profile.xml";
    $c->forward('index');
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
