require 'xmpp4r'
require 'xmpp4r/muc'
require 'hekker/responder'
require 'hekker/scheduler'

class Hekker
  STATUS = 'Hekkers Huisbot'

  attr_reader :muc
  attr_reader :scheduler
  
  def initialize(jid, pass, room)
    @scheduler = Scheduler.new self
    client = Jabber::Client.new(Jabber::JID.new jid)
    client.connect
    client.auth pass
    client.send(Jabber::Presence.new.set_show(:xa).set_status(STATUS))
    client.on_exception do |*a|
      puts a[0]
      puts a[0].backtrace
      exit!
    end
    @muc = Jabber::MUC::SimpleMUCClient.new client
    @nick, server = jid.split '@'
    @muc.join(room + '@conference.' + server + '/' + @nick)
  end

  def worker
    @muc.on_message do |time, nick, msg|
      if time.nil? # If time is set, it is an old message
        if msg =~ /^#{@nick}:(.*)$/
          cmd, msg = $~.to_a[1].strip.split(' ', 2)
          cmd = cmd.to_sym
          msg = msg.to_s
          
          responder = Responder.new self, nick

          if responder.commands.include? cmd
            responder.send cmd, msg.strip
          else
            commands = responder.commands.sort.map { |c| c.to_s }.join(', ')
            @muc.say "#{nick}: #{cmd} wordt niet begrepen :(\n" +
              "dit wel: #{commands}"
          end
        end
      end
    end
    
    loop do
      @scheduler.run

      sleep 1
    end
  end
end

