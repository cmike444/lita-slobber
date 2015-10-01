require 'securerandom'

module Lita
  module Handlers
    class Slobber < Handler

      route(/^start taking notes/, :start_taking_notes, help: {
        "start taking notes" => "Starts recording conversation until the `stop taking notes` command is given."
        })

      def start_taking_notes(response)
        start_marker = Time.now
        response.reply "Alright, it's #{start_marker.strftime('%l:%M %P')} and I'm ready to take notes."
      end

      route(/^stop taking notes/, :stop_taking_notes, help: {
        "stop taking notes" => "Stops recording conversation after the `start taking notes` command is given."
        })

      def stop_taking_notes(response)
        stop_marker = Time.now
        response.reply  "Ok, it's #{stop_marker.strftime('%l:%M %P')} and I'm done taking notes."
      end

    end

    Lita.register_handler(Slobber)
  end
end
