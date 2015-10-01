require 'securerandom'

module Lita
  module Handlers
    class Slobber < Handler

      route(/^start taking notes/, :start_taking_notes, help: {
        "start taking notes" => "Starts recording conversation until the `stop taking notes` command is given."
        })
      route(/^stop taking notes/, :stop_taking_notes, help: {
        "stop taking notes" => "Stops recording conversation after the `start taking notes` command is given."
        })
      route(/^get channel/, :get_channel, command: true, help: {
        "get channel" => "Replies with CHANNEL"
        })

      def start_taking_notes(response)
        start_marker = Time.now
        channel = get_channel(response)
        redis.set(channel.id, start_marker)
        response.reply "Alright, it's #{start_marker.strftime('%l:%M %P')} and I'm ready to take notes."
      end

      def stop_taking_notes(response)
        stop_marker = Time.now
        channel = get_channel(response)
        start_marker = redis.get(channel.id)
        response.reply  "Ok, it's #{stop_marker.strftime('%l:%M %P')} and I'm done taking notes. I'll have the notes from the last #{time_ago_in_words(start, stop)} compiled and sent out in a jiffy!"
      end

      def time_ago_in_words(t1, t2)
        s = t1.to_i - t2.to_i # distance between t1 and t2 in seconds

        resolution = if s > 29030400 # seconds in a year
          [(s/29030400), 'years'] 
        elsif s > 2419200
          [(s/2419200), 'months']
        elsif s > 604800
          [(s/604800), 'weeks']
        elsif s > 86400
          [(s/86400), 'days']
        elsif s > 3600 # seconds in an hour
          [(s/3600), 'hours'] 
        elsif s > 60
          [(s/60), 'minutes']
        else
          [s, 'seconds']
        end

        # singular v. plural resolution
        if resolution[0] == 1
          resolution.join(' ')[0...-1]
        else
          resolution.join(' ')
        end
      end

      private

      def get_channel(response)
        response.message.source.room_object
      end

    end

    Lita.register_handler(Slobber)
  end
end
