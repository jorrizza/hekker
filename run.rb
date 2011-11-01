#!/usr/bin/env ruby

$: << File.join(File.dirname(__FILE__), 'lib')

require 'psych'
require 'daemons'
require 'hekker'

config = Psych.load_file File.join(File.dirname(__FILE__), 'config.yml')

Daemons.run_proc 'hekker' do
  Hekker.new(config['jid'], config['password'], config['room']).worker
end
