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
        # unique_id = request.slack_channel
        # redis.set(unique_id, start_marker)
        response.reply "Alright, it's #{start_marker.strftime('%l:%M %P')} and I'm ready to take notes."
      end

      def stop_taking_notes(response)
        stop_marker = Time.now
        # unique_id = request.slack_channel
        # redis.get(unique_id, stop_marker)
        response.reply  "Ok, it's #{stop_marker.strftime('%l:%M %P')} and I'm done taking notes. I'll have them compiled and sent out in a jiffy!"
      end

      def get_channel(response)
        response.reply "#{response.message.source.room_object.inspect}"
      end

    end

    Lita.register_handler(Slobber)
  end
end
