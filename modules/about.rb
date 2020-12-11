module AttendanceBot
  module Commands
    module About
      extend Discordrb::Commands::CommandContainer
      command(:about, description: "Details on the Discord bot") do |event|
        event.channel.send_embed do |embed|
          embed.colour = 0x563055
          embed.add_field name: 'Creator', value: 'John Cordero (<@233144823706681345>).', inline: true
          embed.add_field name: 'Library', value: 'discordrb', inline: true
          embed.add_field name: 'Language', value: 'Ruby', inline: true
          embed.add_field name: 'Bot Version', value: "v#{VERSION}", inline: true
          embed.add_field name: 'Servers', value: server_count, inline: true
          embed.add_field name: 'Prefix', value: BOT.prefix, inline: true
          embed.add_field name: 'About', value: 'Fast and simple to use discord bot, created in ruby using discordrb.', inline: false
          embed.add_field name: 'Website', value: 'https://kurozero.xyz/hitagi', inline: true
          embed.add_field name: 'Support Server', value: 'https://discord.gg/Vf4ne5b', inline: true
      end
    end
  end
end
