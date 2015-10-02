require 'securerandom'

module Lita
  module Handlers
    class Slobber < Handler

      route(/^start taking notes/, :start_taking_notes, command: true, help: {
        "start taking notes" => "Starts recording conversation until the `stop taking notes` command is given."
        })
      route(/^stop taking notes/, :stop_taking_notes, command: true, help: {
        "stop taking notes" => "Stops recording conversation after the `start taking notes` command is given."
        })
      route(/^chat/, :chat_service, command: true, help: {
        "chat" => "Shows chat service api"
        })

      def start_taking_notes(response)
        start = Time.now
        channel = get_channel(response)
        redis.set(channel.id, start)
        response.reply "Alright, it's #{start.strftime('%l:%M %P')} and I'm ready to take notes."
      end

      def stop_taking_notes(response)
        stop = Time.now
        channel = get_channel(response)
        start = redis.get(channel.id)
        response.reply  "Ok, cool. I'll have the notes compiled and sent out in a jiffy!"
      end

      def get_channel(response)
        response.message.source.room_object
      end

      def chat_service(request, response)
        p robot.chat_service.api
      end

    end

    Lita.register_handler(Slobber)
  end
end
