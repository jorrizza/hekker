require 'chronic'

class Hekker
  class Scheduler
    def initialize(hek)
      @hek = hek
      @sched = []
    end

    def schedule(nick, command)
      time, what = command.split(':', 2)

      return false unless what # the fuck?

      what.strip!
      time = Chronic.parse time.strip

      return false unless time
      return false if time <= Time.now

      @sched << {
        time: time,
        what: what,
        nick: nick
      }

      true
    end

    def run
      @sched.map! do |sched|
        if sched[:time] <= Time.now
          @hek.muc.say "#{sched[:nick]}: #{sched[:what]}"
          nil
        else
          sched
        end
      end

      @sched.compact!
    end
  end
end
