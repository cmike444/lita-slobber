require 'securerandom'
require 'fileutils'
require 'lita'

module Lita
  module Handlers
    class Slobber < Handler

      route(/^.*/, :take_notes)

      route(/^start taking notes/, :start_taking_notes, command: true, help: {
        "start taking notes" => "Starts recording conversation until the `stop taking notes` command is given."
        })
      route(/^stop taking notes/, :stop_taking_notes, command: true, help: {
        "stop taking notes" => "Stops recording conversation after the `start taking notes` command is given."
        })

      def start_taking_notes(response)
        channel = get_channel(response)
        
        if is_taking_notes(channel)
          response.reply "You already asked me to take notes."
        else
          redis.set(channel.id, Time.now.to_i)
          username = get_reply_to_name(response)

          started_taking_notes = [
            "Alright #{username}, I'm ready to take notes.",
            "Ok, sounds good. Ready when you are, #{username}!",
            "I'm already on top of it, #{username}!",
            "Alright, well then start typing #{username}!",
            "For shizzle #{username}.",
            "Uh.. Yeah. That's my job, #{username}.",
            "Alright, #{username}. I've got you covered!",
            "You bet, #{username}.",
            "That I can do, #{username}.",
            "If you say so, #{username}."
          ]

          response.reply started_taking_notes.sample
        end
      end

      def stop_taking_notes(response)
        stop = Time.now.to_i
        channel = get_channel(response)
        
        if is_taking_notes(channel)
          start = redis.get(channel.id)

          stopped_taking_notes = [
            "Ok, cool. I've compiled your notes and sent them out!",
            "Right on, I'll send out the notes in a jiffy!",
            "Alright, I'll get your notes put together and sent out right away!",
            "Awesome, you'll see the notes in your email shortly."
          ]

          response.reply  stopped_taking_notes.sample
        else
          response.reply "I was never taking notes in the first place..."
        end
      end

      def take_notes(response)
        channel = get_channel(response)
        if is_taking_notes(channel)
          FileUtils.mkdir_p("tmp/#{channel.id}") unless Dir.exists?("tmp/#{channel.id}")
          
          File.open("tmp/#{channel.id}/notes_session.log", 'w+') do |f|
            f.puts "[#{Time.now.to_i}] - [#{response.user.name}: #{response.message.body}"
          end
        end
      end

      def get_channel(response)
        response.message.source.room_object
      end

      def get_reply_to_name(response)
        response.user.metadata['mention_name'].nil? ? "#{response.user.name}" : "#{response.user.metadata['mention_name']}"
      end

      def is_taking_notes(channel)
        redis.get(channel.id) ? true : false
      end

      def is_private_message(response)
        response.message.source.private_message
      end

      on(:connected) do |payload|
        p payload.inspect
      end

    end

    Lita.register_handler(Slobber)
  end
end
