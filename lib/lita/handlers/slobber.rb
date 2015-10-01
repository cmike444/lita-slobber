require 'securerandom'

module Lita
  module Handlers
    class Slobber < Handler

      route(/^start taking notes/, :start_taking_notes, help: {
        "bob: start taking notes" => "Starts recording conversation until the `stop taking notes` command is given."
        })

      def start_taking_notes(request, response)
        start_marker = Time.now
        # unique_id = request.slack_channel
        # redis.set(unique_id, start_marker)
        response.reply "Alright, it's #{start_marker.strftime('%l:%M %P')} and I'm ready to take notes."
      end

      route(/^stop taking notes/, :stop_taking_notes, help: {
        "bob: stop taking notes" => "Stops recording conversation after the `start taking notes` command is given."
        })

      def stop_taking_notes(request, response)
        stop_marker = Time.now
        # unique_id = request.slack_channel
        # redis.get(unique_id, stop_marker)
        response.reply  "Ok, it's #{stop_marker.strftime('%l:%M %P')} and I'm done taking notes. I'll have them compiled and sent out in a jiffy!"
      end

      route(/^get channel info/, :get_channel, command: true, help: {
        "bob: get channel" => "Replies with CHANNEL"
        })

      def get_channel(request, response)
        response.reply "#{request.inspect}"
      end

    end

    Lita.register_handler(Slobber)
  end
end
