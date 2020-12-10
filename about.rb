module AttendanceBot
  module Commands
    module About
      extend Discordrb::Commands::CommandContainer
      command(:about, description: "About the Discord Bot") do |event|
        event << ""
        event << "Author: John Cordero (<@233144823706681345>)."
        event << "Made with 💖 & built with Ruby."
        event << "Source Code: #{}"
        event << "Version: #{}."
      end
    end
  end
end
