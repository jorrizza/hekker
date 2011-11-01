require 'gdbm'

class Hekker
  class Responder
    def initialize(hek, nick)
      @hek, @nick = hek, nick
    end

    def say(txt)
      @hek.muc.say "#{@nick}: #{txt}"
    end

    def commands
      [:echo, :jemoeder, :karma, :schedule]
    end

    def echo(txt)
      say txt
    end

    def jemoeder(txt)
      say txt + ' JE MOEDER!'
    end

    def karma(txt)
      db = GDBM.open "#{ENV['HOME']}/.hekker_karma.db"
      mode = txt[-2..-1]
      topic = txt[0..-3].downcase

      if txt.empty?
        say "gebruik: karma topic++ of karma topic--; zonder ++ of -- geeft huidige score weer"
        db.close
        return
      elsif %w{++ --}.include? mode
        if mode == '++'
          db[topic] = (db[topic].to_i + 1).to_s
        else
          db[topic] = (db[topic].to_i - 1).to_s
        end
      else
        topic = txt
      end
      say "karma voor #{topic}: #{db[topic].to_i}"

      db.close
    end

    def schedule(txt)
      if txt.empty?
        say "gebruik: schedule tomorrow: pillen kopen!;" +
          " kijk voor alternatieven voor 'tomorrow' op https://github.com/mojombo/chronic"
        return
      end

      if @hek.scheduler.schedule @nick, txt
        say "succesvol ingepland"
      else
        say "dat snap ik niet hoor"
      end
    end
  end
end
