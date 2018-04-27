package pf::constants::switch_options;

=head1 NAME

pf::constants::switch_options - pf::constants::switch_options

=cut

=head1 DESCRIPTION

pf::constants::switch_options



=cut

use strict;
use warnings;

our @SWITCH_OPTIONS = (
    {
        'group' => '',
        'options' => [
            {
                'value' => '',
                'label' => ''
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Accton',
        'options' => [
            {
                'value' => 'Accton::ES3526XA',
                'label' => 'Accton ES3526XA'
            },
            {
                'value' => 'Accton::ES3528M',
                'label' => 'Accton ES3528M'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'AeroHIVE',
        'options' => [
            {
                'value' => 'AeroHIVE::AP',
                'label' => 'AeroHIVE AP'
            },
            {
                'value' => 'AeroHIVE::BR100',
                'label' => 'AeroHive BR100'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Alcatel',
        'options' => [
            {
                'value' => 'Alcatel',
                'label' => 'Alcatel switch'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'AlliedTelesis',
        'options' => [
            {
                'value' => 'AlliedTelesis::AT8000GS',
                'label' => 'AlliedTelesis AT8000GS'
            },
            {
                'value' => 'AlliedTelesis::GS950',
                'label' => 'Allied Telesis GS950'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Amer',
        'options' => [
            {
                'value' => 'Amer::SS2R24i',
                'label' => 'Amer SS2R24i'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Anyfi',
        'options' => [
            {
                'value' => 'Anyfi',
                'label' => 'Anyfi Gateway'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Aruba',
        'options' => [
            {
                'value' => 'Aruba',
                'label' => 'Aruba Networks'
            },
            {
                'value' => 'Aruba::2930M',
                'label' => 'Aruba 2930M Series'
            },
            {
                'value' => 'Aruba::5400',
                'label' => 'Aruba 5400 Switch'
            },
            {
                'value' => 'Aruba::Controller_200',
                'label' => 'Aruba 200 Controller'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'ArubaSwitch',
        'options' => [
            {
                'value' => 'ArubaSwitch',
                'label' => 'Aruba Switches'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Avaya',
        'options' => [
            {
                'value' => 'Avaya',
                'label' => 'Avaya Switch Module'
            },
            {
                'value' => 'Avaya::ERS2500',
                'label' => 'Avaya ERS 2500 Series'
            },
            {
                'value' => 'Avaya::ERS3500',
                'label' => 'Avaya ERS 3500 Series'
            },
            {
                'value' => 'Avaya::ERS4000',
                'label' => 'Avaya ERS 4000 Series'
            },
            {
                'value' => 'Avaya::ERS5000',
                'label' => 'Avaya ERS 5000 Series'
            },
            {
                'value' => 'Avaya::ERS5000_6x',
                'label' => 'Avaya ERS 5000 Series w/ firmware 6.x'
            },
            {
                'value' => 'Avaya::WC',
                'label' => 'Avaya Wireless Controller'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Belair',
        'options' => [
            {
                'value' => 'Belair',
                'label' => 'Belair Networks AP'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Brocade',
        'options' => [
            {
                'value' => 'Brocade',
                'label' => 'Brocade Switches'
            },
            {
                'value' => 'Brocade::RFS',
                'label' => 'Brocade RF Switches'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Cisco',
        'options' => [
            {
                'value' => 'Cisco::Aironet_1130',
                'label' => 'Cisco Aironet 1130'
            },
            {
                'value' => 'Cisco::Aironet_1242',
                'label' => 'Cisco Aironet 1242'
            },
            {
                'value' => 'Cisco::Aironet_1250',
                'label' => 'Cisco Aironet 1250'
            },
            {
                'value' => 'Cisco::Aironet_1600',
                'label' => 'Cisco Aironet 1600'
            },
            {
                'value' => 'Cisco::Aironet_WDS',
                'label' => 'Cisco Aironet (WDS)'
            },
            {
                'value' => 'Cisco::Catalyst_2900XL',
                'label' => 'Cisco Catalyst 2900XL Series'
            },
            {
                'value' => 'Cisco::Catalyst_2950',
                'label' => 'Cisco Catalyst 2950'
            },
            {
                'value' => 'Cisco::Catalyst_2960',
                'label' => 'Cisco Catalyst 2960'
            },
            {
                'value' => 'Cisco::Catalyst_2960G',
                'label' => 'Cisco Catalyst 2960G'
            },
            {
                'value' => 'Cisco::Catalyst_2970',
                'label' => 'Cisco Catalyst 2970'
            },
            {
                'value' => 'Cisco::Catalyst_3500XL',
                'label' => 'Cisco Catalyst 3500XL Series'
            },
            {
                'value' => 'Cisco::Catalyst_3550',
                'label' => 'Cisco Catalyst 3550'
            },
            {
                'value' => 'Cisco::Catalyst_3560',
                'label' => 'Cisco Catalyst 3560'
            },
            {
                'value' => 'Cisco::Catalyst_3560G',
                'label' => 'Cisco Catalyst 3560G'
            },
            {
                'value' => 'Cisco::Catalyst_3750',
                'label' => 'Cisco Catalyst 3750'
            },
            {
                'value' => 'Cisco::Catalyst_3750G',
                'label' => 'Cisco Catalyst 3750G'
            },
            {
                'value' => 'Cisco::Catalyst_4500',
                'label' => 'Cisco Catalyst 4500 Series'
            },
            {
                'value' => 'Cisco::Catalyst_6500',
                'label' => 'Cisco Catalyst 6500 Series'
            },
            {
                'value' => 'Cisco::ISR_1800',
                'label' => 'Cisco ISR 1800 Series'
            },
            {
                'value' => 'Cisco::SG300',
                'label' => 'Cisco SG300'
            },
            {
                'value' => 'Cisco::WLC',
                'label' => 'Cisco Wireless Controller (WLC)'
            },
            {
                'value' => 'Cisco::WLC_2100',
                'label' => 'Cisco Wireless (WLC) 2100 Series'
            },
            {
                'value' => 'Cisco::WLC_2106',
                'label' => 'Cisco Wireless (WLC) 2100 Series'
            },
            {
                'value' => 'Cisco::WLC_2500',
                'label' => 'Cisco Wireless (WLC) 2500 Series'
            },
            {
                'value' => 'Cisco::WLC_4400',
                'label' => 'Cisco Wireless (WLC) 4400 Series'
            },
            {
                'value' => 'Cisco::WLC_5500',
                'label' => 'Cisco Wireless (WLC) 5500 Series'
            },
            {
                'value' => 'Cisco::WiSM',
                'label' => 'Cisco WiSM'
            },
            {
                'value' => 'Cisco::WiSM2',
                'label' => 'Cisco WiSM2'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'CoovaChilli',
        'options' => [
            {
                'value' => 'CoovaChilli',
                'label' => 'CoovaChilli'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Dell',
        'options' => [
            {
                'value' => 'Dell::Force10',
                'label' => 'Dell Force 10'
            },
            {
                'value' => 'Dell::N1500',
                'label' => 'N1500 Series'
            },
            {
                'value' => 'Dell::PowerConnect3424',
                'label' => 'Dell PowerConnect 3424'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Dlink',
        'options' => [
            {
                'value' => 'Dlink::DES_3028',
                'label' => 'D-Link DES 3028'
            },
            {
                'value' => 'Dlink::DES_3526',
                'label' => 'D-Link DES 3526'
            },
            {
                'value' => 'Dlink::DES_3550',
                'label' => 'D-Link DES 3550'
            },
            {
                'value' => 'Dlink::DGS_3100',
                'label' => 'D-Link DGS 3100'
            },
            {
                'value' => 'Dlink::DGS_3200',
                'label' => 'D-Link DGS 3200'
            },
            {
                'value' => 'Dlink::DWL',
                'label' => 'D-Link DWL Access-Point'
            },
            {
                'value' => 'Dlink::DWS_3026',
                'label' => 'D-Link DWS 3026'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'EdgeCore',
        'options' => [
            {
                'value' => 'EdgeCore',
                'label' => 'EdgeCore'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Enterasys',
        'options' => [
            {
                'value' => 'Enterasys::D2',
                'label' => 'Enterasys Standalone D2'
            },
            {
                'value' => 'Enterasys::Matrix_N3',
                'label' => 'Enterasys Matrix N3'
            },
            {
                'value' => 'Enterasys::SecureStack_C2',
                'label' => 'Enterasys SecureStack C2'
            },
            {
                'value' => 'Enterasys::SecureStack_C3',
                'label' => 'Enterasys SecureStack C3'
            },
            {
                'value' => 'Enterasys::V2110',
                'label' => 'Enterasys V2110'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Extreme',
        'options' => [
            {
                'value' => 'Extreme::Summit',
                'label' => 'ExtremeNet Summit series'
            },
            {
                'value' => 'Extreme::Summit_X250e',
                'label' => 'ExtremeNet Summit series'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Extricom',
        'options' => [
            {
                'value' => 'Extricom::EXSW',
                'label' => 'Extricom EXSW Controllers'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Fortinet',
        'options' => [
            {
                'value' => 'Fortinet::FortiGate',
                'label' => 'FortiGate Firewall with web auth + 802.1X'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Foundry',
        'options' => [
            {
                'value' => 'Foundry::FastIron_4802',
                'label' => 'Foundry FastIron 4802'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Generic',
        'options' => [
            {
                'value' => 'Generic',
                'label' => 'Generic'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'H3C',
        'options' => [
            {
                'value' => 'H3C::S5120',
                'label' => 'H3C S5120 (HP/3Com)'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'HP',
        'options' => [
            {
                'value' => 'HP::Controller_MSM710',
                'label' => 'HP ProCurve MSM710 Mobility Controller'
            },
            {
                'value' => 'HP::E4800G',
                'label' => 'HP E4800G (3Com)'
            },
            {
                'value' => 'HP::E5500G',
                'label' => 'HP E5500G (3Com)'
            },
            {
                'value' => 'HP::MSM',
                'label' => 'HP ProCurve MSM Access Point'
            },
            {
                'value' => 'HP::Procurve_2500',
                'label' => 'HP ProCurve 2500 Series'
            },
            {
                'value' => 'HP::Procurve_2600',
                'label' => 'HP ProCurve 2600 Series'
            },
            {
                'value' => 'HP::Procurve_2920',
                'label' => 'HP ProCurve 2920 Series'
            },
            {
                'value' => 'HP::Procurve_3400cl',
                'label' => 'HP ProCurve 3400cl Series'
            },
            {
                'value' => 'HP::Procurve_4100',
                'label' => 'HP ProCurve 4100 Series'
            },
            {
                'value' => 'HP::Procurve_5300',
                'label' => 'HP ProCurve 5300 Series'
            },
            {
                'value' => 'HP::Procurve_5400',
                'label' => 'HP ProCurve 5400 Series'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Hostapd',
        'options' => [
            {
                'value' => 'Hostapd',
                'label' => 'Hostapd'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Huawei',
        'options' => [
            {
                'value' => 'Huawei',
                'label' => 'Huawei AC6605'
            },
            {
                'value' => 'Huawei::S5710',
                'label' => 'Huawei S5710'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'IBM',
        'options' => [
            {
                'value' => 'IBM::IBM_RackSwitch_G8052',
                'label' => 'IBM RackSwitch G8052'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Intel',
        'options' => [
            {
                'value' => 'Intel::Express_460',
                'label' => 'Intel Express 460'
            },
            {
                'value' => 'Intel::Express_530',
                'label' => 'Intel Express 530'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Juniper',
        'options' => [
            {
                'value' => 'Juniper::EX',
                'label' => 'Juniper EX Series'
            },
            {
                'value' => 'Juniper::EX2200',
                'label' => 'Juniper EX 2200 Series'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'LG',
        'options' => [
            {
                'value' => 'LG::ES4500G',
                'label' => 'LG-Ericsson iPECS ES-4500G'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Linksys',
        'options' => [
            {
                'value' => 'Linksys::SRW224G4',
                'label' => 'Linksys SRW224G4'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Meraki',
        'options' => [
            {
                'value' => 'Meraki::MR',
                'label' => 'Meraki cloud controller'
            },
            {
                'value' => 'Meraki::MR_v2',
                'label' => 'Meraki cloud controller V2'
            },
            {
                'value' => 'Meraki::MS220_8',
                'label' => 'Meraki switch MS220_8'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Meru',
        'options' => [
            {
                'value' => 'Meru::MC',
                'label' => 'Meru MC'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Mikrotik',
        'options' => [
            {
                'value' => 'Mikrotik',
                'label' => 'Mikrotik'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Mojo',
        'options' => [
            {
                'value' => 'Mojo',
                'label' => 'Mojo Networks AP'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Motorola',
        'options' => [
            {
                'value' => 'Motorola::RFS',
                'label' => 'Motorola RF Switches'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Netgear',
        'options' => [
            {
                'value' => 'Netgear::FSM726v1',
                'label' => 'Netgear FSM726v1'
            },
            {
                'value' => 'Netgear::FSM7328S',
                'label' => 'Netgear FSM7328S'
            },
            {
                'value' => 'Netgear::GS110',
                'label' => 'Netgear GS110'
            },
            {
                'value' => 'Netgear::MSeries',
                'label' => 'Netgear M series'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Nortel',
        'options' => [
            {
                'value' => 'Nortel::BPS2000',
                'label' => 'Nortel BPS 2000'
            },
            {
                'value' => 'Nortel::BayStack4550',
                'label' => 'Nortel BayStack 4550'
            },
            {
                'value' => 'Nortel::BayStack470',
                'label' => 'Nortel BayStack 470'
            },
            {
                'value' => 'Nortel::BayStack5500',
                'label' => 'Nortel BayStack 5500 Series'
            },
            {
                'value' => 'Nortel::BayStack5500_6x',
                'label' => 'Nortel BayStack 5500 w/ firmware 6.x'
            },
            {
                'value' => 'Nortel::ERS2500',
                'label' => 'Nortel ERS 2500 Series'
            },
            {
                'value' => 'Nortel::ERS4000',
                'label' => 'Nortel ERS 4000 Series'
            },
            {
                'value' => 'Nortel::ERS5000',
                'label' => 'Nortel ERS 5000 Series'
            },
            {
                'value' => 'Nortel::ERS5000_6x',
                'label' => 'Nortel ERS 5000 Series w/ firmware 6.x'
            },
            {
                'value' => 'Nortel::ES325',
                'label' => 'Nortel ES325'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'PacketFence',
        'options' => [
            {
                'value' => 'PacketFence',
                'label' => 'PacketFence'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Ruckus',
        'options' => [
            {
                'value' => 'Ruckus',
                'label' => 'Ruckus Wireless Controllers'
            },
            {
                'value' => 'Ruckus::Legacy',
                'label' => 'Ruckus Wireless Controllers - Legacy'
            },
            {
                'value' => 'Ruckus::SmartZone',
                'label' => 'Ruckus SmartZone Wireless Controllers'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'SMC',
        'options' => [
            {
                'value' => 'SMC::TS6128L2',
                'label' => 'SMC TigerStack 6128L2'
            },
            {
                'value' => 'SMC::TS6224M',
                'label' => 'SMC TigerStack 6224M'
            },
            {
                'value' => 'SMC::TS8800M',
                'label' => 'SMC TigerStack 8800 Series'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'ThreeCom',
        'options' => [
            {
                'value' => 'ThreeCom::E4800G',
                'label' => '3COM E4800G'
            },
            {
                'value' => 'ThreeCom::E5500G',
                'label' => '3COM E5500G'
            },
            {
                'value' => 'ThreeCom::NJ220',
                'label' => '3COM NJ220'
            },
            {
                'value' => 'ThreeCom::SS4200',
                'label' => '3COM SS4200'
            },
            {
                'value' => 'ThreeCom::SS4500',
                'label' => '3COM SS4500'
            },
            {
                'value' => 'ThreeCom::Switch_4200G',
                'label' => '3COM 4200G'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Trapeze',
        'options' => [
            {
                'value' => 'Trapeze',
                'label' => 'Trapeze Wireless Controller'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Ubiquiti',
        'options' => [
            {
                'value' => 'Ubiquiti::EdgeSwitch',
                'label' => 'EdgeSwitch'
            },
            {
                'value' => 'Ubiquiti::Unifi',
                'label' => 'Unifi Controller'
            }
        ],
        'value' => ''
    },
    {
        'group' => 'Xirrus',
        'options' => [
            {
                'value' => 'Xirrus',
                'label' => 'Xirrus WiFi Arrays'
            }
        ],
        'value' => ''
    }
);

 
=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005- Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;
