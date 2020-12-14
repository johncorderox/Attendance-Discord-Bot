require "discordrb"
require "sqlite3"
require "active_record"
require "dotenv"

Dotenv.load

@bot = Discordrb::Commands::CommandBot.new(token: ENV["TOKEN"], prefix: "+")

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "attendance.db",
)

class Roster < ActiveRecord::Base
end

class CreateRosterTable < ActiveRecord::Migration[5.2]
  def change
    create_table :rosters do |t|
      t.string :discord_id
      t.string :username
      t.string :status, default: "not_set"
    end
  end
end

CreateRosterTable.migrate(:up)

@bot.command(:roster,
             description: "#",
             usage: "+roster") do |event|
  members = Roster.all
  member = ""

  event.channel.send_embed do |embed|
    embed.colour = "#0275d8"
    embed.title = "Attendance Sheet - #{members.count}"

    members.each do |m|
      if m.status == "yes"
        m.status = "💚"
      elsif m.status == "maybe"
        m.status = "🧡"
      elsif m.status == "no"
        m.status = "💔"
      else
        m.status = "🤍"
      end
      member += "#{m.status} #{m.username} \n"
    end
    embed.description = "#{member}"
  end
end

@bot.command(:add,
             description: "#",
             usage: "+add @me") do |event, user|
  disc_id = user.gsub!(/[<@>]/, "")
  found_member = event.server.members.find { |member| member == disc_id }

  if !user
    return event.respond "No user given to add!"
  else
    if found_member
      if Roster.where(discord_id: disc_id).exists?
        return event.respond "User already on roster!"
      else
        Roster.create(discord_id: disc_id, username: found_member.username)
        event.channel.send_embed do |embed|
          embed.colour = "#0275d8"
          embed.add_field name: "Attendance Update!", value: "#{found_member.username}, you are added to the roster!"
        end
      end
    else
      return event.respond "User was not found! Are they on this server?..."
    end
  end
end

@bot.command(:yes,
             description: "Update your attendance with the Yes status",
             usage: "+yes") do |event, user|
  if !user
    if Roster.where(discord_id: event.user.id).exists?
      Roster.where(discord_id: event.user.id).update(status: "yes")

      event.channel.send_embed do |embed|
        embed.colour = "#5cb85c"
        embed.add_field name: "Attendance Update! \n", value: "#{event.user.username}, you are now set as attending!"
        embed.thumbnail = { url: event.user.avatar_url }
      end
    else
      event.respond "You are not on the roster! Add yourself using +add @username"
    end
  else
    disc_id = user.gsub!(/[<@>]/, "")
    found_member = event.server.members.find { |member| member == disc_id }

    Roster.where(discord_id: disc_id).update(status: "yes")

    event.channel.send_embed do |embed|
      embed.colour = "#5cb85c"
      embed.add_field name: "Attendance Update!", value: "#{found_member.username}, you are now set as attending!"
      embed.thumbnail = { url: found_member.avatar_url }
    end
  end
end

@bot.command(:no,
             description: "Update your attendance with the No status",
             usage: "+no") do |event, user|
  if !user
    if Roster.where(discord_id: event.user.id).exists?
      Roster.where(discord_id: event.user.id).update(status: "no")

      event.channel.send_embed do |embed|
        embed.colour = "#d9534f"
        embed.add_field name: "Attendance Update! \n", value: "#{event.user.username}, you are now set as NOT attending!"
        embed.thumbnail = { url: event.user.avatar_url }
      end
    else
      event.respond "you are not on the roster! Add yourself using +add @username"
    end
  else
    disc_id = user.gsub!(/[<@>]/, "")
    found_member = event.server.members.find { |member| member == disc_id }

    Roster.where(discord_id: disc_id).update(status: "no")

    event.channel.send_embed do |embed|
      embed.colour = "#d9534f"
      embed.add_field name: "Attendance Update! \n", value: "#{found_member.username}, you are now set as NOT attending!"
      embed.thumbnail = { url: found_member.avatar_url }
    end
  end
end

@bot.command(:maybe,
             description: "Update your attendance with the Maybe status",
             usage: "+no") do |event, user|
  if !user
    if Roster.where(discord_id: event.user.id).exists?
      Roster.where(discord_id: event.user.id).update(status: "maybe")

      event.channel.send_embed do |embed|
        embed.colour = "#f0ad4e"
        embed.add_field name: "Attendance Update! \n", value: "#{event.user.username}, you are now set as MAYBE attending!"
        embed.thumbnail = { url: event.user.avatar_url }
      end
    else
      event.respond "You are not on the roster! Add yourself using +add @username"
    end
  else
    disc_id = user.gsub!(/[<@>]/, "")
    found_member = event.server.members.find { |member| member == disc_id }

    Roster.where(discord_id: disc_id).update(status: "maybe")

    event.channel.send_embed do |embed|
      embed.colour = "#f0ad4e"
      embed.add_field name: "Attendance Update! \n", value: "#{found_member.username}, you are now set as MAYBE attending!"
      embed.thumbnail = { url: found_member.avatar_url }
    end
  end
end

@bot.command(:remove,
             description: "Removes yourself to the roster",
             usage: "+remove @me") do |event, user|
  if !user
    return event.respond "A user was not given!"
  else
    disc_id = user.gsub!(/[<@>]/, "")
    found_member = event.server.members.find { |member| member == disc_id }
    if Roster.where(discord_id: disc_id).exists?
      Roster.where(discord_id: disc_id).destroy_all
      event.channel.send_embed do |embed|
        embed.colour = "#0275d8"
        embed.add_field name: "Attendance Update! \n", value: "#{found_member.username} has been removed from the roster!"
      end
    else
      return event.respond "User is not on the roster!"
    end
  end
end

@bot.command(:reset,
             description: "Resets every member's status to not_set to reapply the attendance",
             usage: "+reset") do |event|
  Roster.all.update(status: "not_set")
  event.channel.send_embed do |embed|
    embed.colour = "#0275d8"
    embed.title = "Attendance Update!"
    embed.description = "The roster has been reset!"
  end
end

@bot.command(:help,
             description: "Displays the help menu",
             usage: "+help") do |event|
               event.channel.send_embed do |embed|
                 embed.colour = "#ffc0cb"
                 embed.title = "Attendance Bot Help Menu"
                 embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.icon_url)
                 embed.add_field name: "General Commands",
                  value: "`+roster` - Displays the current Roster.
                  `+add <@discord_user>` - Add a Discord User to the Roster.
                  `+remove <@discord_user>` - Removes member from the Roster.
                  `+reset` - Resets every member's status on the roster to Not Set.
                  `+yes` - Sets your/discord_user status to Yes
                  `+no` - Sets your/discord_user status to No
                  `+maybe` - Sets your/discord_user status to Maybe"
               end
end


@bot.run
