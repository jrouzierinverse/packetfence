package pf::Base::RoseDB::Switch;

use strict;

use base qw(pf::Base::RoseDB::Object);

__PACKAGE__->meta->setup(
    table   => 'switches',

    columns => [
        id                       => { type => 'varchar', length => 255, not_null => 1 },
        description              => { type => 'varchar', length => 255, not_null => 1 },
        type                     => { type => 'varchar', length => 255, not_null => 1 },
        macSearchesMaxNb         => { type => 'varchar', length => 255, not_null => 1 },
        macSearchesSleepInterval => { type => 'varchar', length => 255, not_null => 1 },
        mode                     => { type => 'varchar', length => 255, not_null => 1 },
        SNMPAuthPasswordRead     => { type => 'varchar', length => 255, not_null => 1 },
        SNMPAuthPasswordTrap     => { type => 'varchar', length => 255, not_null => 1 },
        SNMPAuthPasswordWrite    => { type => 'varchar', length => 255, not_null => 1 },
        SNMPAuthProtocolRead     => { type => 'varchar', length => 255, not_null => 1 },
        SNMPAuthProtocolTrap     => { type => 'varchar', length => 255, not_null => 1 },
        SNMPAuthProtocolWrite    => { type => 'varchar', length => 255, not_null => 1 },
        SNMPCommunityRead        => { type => 'varchar', length => 255, not_null => 1 },
        SNMPCommunityTrap        => { type => 'varchar', length => 255, not_null => 1 },
        SNMPCommunityWrite       => { type => 'varchar', length => 255, not_null => 1 },
        SNMPEngineID             => { type => 'varchar', length => 255, not_null => 1 },
        SNMPPrivPasswordRead     => { type => 'varchar', length => 255, not_null => 1 },
        SNMPPrivPasswordTrap     => { type => 'varchar', length => 255, not_null => 1 },
        SNMPPrivPasswordWrite    => { type => 'varchar', length => 255, not_null => 1 },
        SNMPPrivProtocolRead     => { type => 'varchar', length => 255, not_null => 1 },
        SNMPPrivProtocolTrap     => { type => 'varchar', length => 255, not_null => 1 },
        SNMPPrivProtocolWrite    => { type => 'varchar', length => 255, not_null => 1 },
        SNMPUserNameRead         => { type => 'varchar', length => 255, not_null => 1 },
        SNMPUserNameTrap         => { type => 'varchar', length => 255, not_null => 1 },
        SNMPUserNameWrite        => { type => 'varchar', length => 255, not_null => 1 },
        SNMPVersion              => { type => 'varchar', length => 255, not_null => 1 },
        SNMPVersionTrap          => { type => 'varchar', length => 255, not_null => 1 },
        cliEnablePwd             => { type => 'varchar', length => 255, not_null => 1 },
        cliPwd                   => { type => 'varchar', length => 255, not_null => 1 },
        cliUser                  => { type => 'varchar', length => 255, not_null => 1 },
        cliTransport             => { type => 'varchar', length => 255, not_null => 1 },
        wsPwd                    => { type => 'varchar', length => 255, not_null => 1 },
        wsUser                   => { type => 'varchar', length => 255, not_null => 1 },
        wsTransport              => { type => 'varchar', length => 255, not_null => 1 },
        radiusSecret             => { type => 'varchar', length => 255, not_null => 1 },
        controllerIp             => { type => 'varchar', length => 255, not_null => 1 },
        controllerPort           => { type => 'varchar', length => 255, not_null => 1 },
        uplink                   => { type => 'varchar', length => 255, not_null => 1 },
        vlans                    => { type => 'varchar', length => 255, not_null => 1 },
        access_lists             => { type => 'varchar', length => 255, not_null => 1 },
        VoIPEnabled              => { type => 'varchar', length => 255, not_null => 1 },
        roles                    => { type => 'varchar', length => 255, not_null => 1 },
        inlineTrigger            => { type => 'varchar', length => 255, not_null => 1 },
        deauthMethod             => { type => 'varchar', length => 255, not_null => 1 },
        switchIp                 => { type => 'varchar', length => 255, not_null => 1 },
        ip                       => { type => 'varchar', length => 255, not_null => 1 },
        portalURL                => { type => 'varchar', length => 255, not_null => 1 },
        RoleMap                  => { type => 'varchar', length => 255, not_null => 1 },
        VlanMap                  => { type => 'varchar', length => 255, not_null => 1 },
        AccessListMap            => { type => 'varchar', length => 255, not_null => 1 },
        uplink_dynamic           => { type => 'varchar', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

1;

