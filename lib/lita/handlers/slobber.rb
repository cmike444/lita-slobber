require 'securerandom'
require 'fileutils'
require 'lita'

module Lita
  module Handlers
    class Slobber < Handler

      route(/.*/, :take_notes)

      route(/start taking notes|start notes|take notes|listen up/, :start_taking_notes, command: true, help: {
        "start taking notes" => "Starts taking notes. *Aliases:* `start notes` `take notes`",
        })
      route(/stop taking notes|stop notes|end notes|finish notes/, :stop_taking_notes, command: true, help: {
        "stop taking notes" => "Stops taking only after `start taking notes` command has been given. *Aliases:* `stop notes` `finish notes`",
        })

      def start_taking_notes(response)
        channel = get_channel(response)
        username = get_reply_to_name(response)

        if is_taking_notes(channel)
          response.reply already_taking_notes_response(username)
        else
          redis.set(channel.id, Time.now.to_i)
          response.reply started_taking_notes_response(username)
        end
      end

      def stop_taking_notes(response)
        stop = Time.now.to_i
        channel = get_channel(response)
        
        if is_taking_notes(channel)
          start = redis.get(channel.id)
          redis.del(channel.id)

          stopped_taking_notes = [
            "Ok, cool. I've compiled your notes and sent them out!",
            "Right on, I'll send out the notes in a jiffy!",
            "Alright, I'll get your notes put together and sent out right away!",
            "Awesome, you'll see the notes in your email shortly."
          ].sample

          response.reply  stopped_taking_notes
        else

          not_taking_notes = [
            "You haven't told me to `start taking notes` yet...",
            "You already asked me to take notes...",
            "Yeah, I've been doing that...",
            "Uh huh, that's what I'm doing right now..."
          ].sample

          response.reply not_taking_notes
        end
      end

      def take_notes(response)
        channel = get_channel(response)
        
        FileUtils.mkdir_p("tmp/#{channel.id}") unless Dir.exists?("tmp/#{channel.id}")
        
        if is_taking_notes(channel)         
          File.open("tmp/#{channel.id}/notes_session.log", 'a') do |f|
            f.puts "[#{Time.now.to_i}] [#{response.user.name}] #{response.message.body}"
          end
        else
          File.open("tmp/#{channel.id}/notes_session.log", 'w')
          return
        end
      end

      def started_taking_notes_response(username)
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
          ].sample
          started_taking_notes
      end

      def already_taking_notes_response(username)
        already_taking_notes = [
            "I've been taking notes, #{username}...",
            "You already asked me to take notes #{username}...",
            "Yeah #{username}, I've been doing that...",
            "Uh huh, that's what I'm doing #{username}..."
          ].sample
          already_taking_notes
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

    end

    Lita.register_handler(Slobber)
  end
end
