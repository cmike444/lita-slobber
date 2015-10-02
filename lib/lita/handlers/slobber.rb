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

      def start_taking_notes(response)
        channel = get_channel(response)
        redis.set(channel.id, Time.now.to_i)

        username = get_reply_to_name(response)

        taking_notes = [
          "Alright #{username}, I'm ready to take notes.",
          "Ok, sounds good. Ready when you are, #{username}!",
          "I'm already on top of it, #{username}!",
          "Alright, well then start typing #{username}!",
          "For shizzle #{username}.",
          "Yeah. That's my job, #{username}.",
          "Alright, #{username}. I've got you covered!",
          "You bet, #{username}.",
          "That I can do, #{username}."
        ]

        response.reply taking_notes.sample
      end

      def stop_taking_notes(response)
        stop = Time.now.to_i
        channel = get_channel(response)
        start = redis.get(channel.id)
        response.reply  "Ok, cool. I'll have your notes compiled and sent out in a jiffy!"
      end

      def get_channel(response)
        response.message.source.room_object
      end

      def get_reply_to_name(response)
        response.user.metadata['mention_name'].nil? ? "#{response.user.name}" : "#{response.user.metadata['mention_name']}"
      end

      def is_private_message?(response)
        response.message.source.private_message
      end

    end

    Lita.register_handler(Slobber)
  end
end
