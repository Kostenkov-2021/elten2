# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2021 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>.

class Scene_Sounds
  def initialize(file = nil)
    @file = file
  end

  def main
    @theme = load_soundtheme(@file)
    @soundnames = {
      "cancel" => p_("Sounds", "Operation cancelled"),
      "dialog_background" => p_("Sounds", "Background of dialog windows"),
      "dialog_open" => p_("Sounds", "Dialog window opened"),
      "dialog_close" => p_("Sounds", "Dialog window closed"),
      "menu_background" => p_("Sounds", "Menu Background"),
      "menu_open" => p_("Sounds", "Menu opened"),
      "menu_close" => p_("Sounds", "Menu closed"),
      "form_marker" => p_("Sounds", "Marker of a form"),
      "listbox_marker" => p_("Sounds", "Marker of a listbox"),
      "listbox_multimarker" => p_("Sounds", "Marker of a multiselect listbox"),
      "listbox_focus" => p_("Sounds", "Focus move on a listbox"),
      "border" => p_("Sounds", "Border of a listbox"),
      "listbox_itemsubmenu" => p_("Sounds", "Expandable item on a listbox"),
      "listbox_treeexpand" => p_("Sounds", "Item expanded"),
      "listbox_treecollapse" => p_("Sounds", "Item collapsed"),
      "listbox_select" => p_("Sounds", "Item selected"),
      "listbox_statechecked" => p_("Sounds", "Checked item on a listbox"),
      "listbox_stateunchecked" => p_("Sounds", "Unchecked item on a listbox"),
      "listbox_itemnew" => p_("Sounds", "New or updated item on a listbox"),
      "listbox_itemattachment" => p_("Sounds", "Item with attachment on a listbox"),
      "listbox_itemclosed" => p_("Sounds", "Closed item on a listbox"),
      "listbox_itemfuture" => p_("Sounds", "Future item on a listbox"),
      "listbox_itempinned" => p_("Sounds", "Pinned item on a listbox"),
      "user_online" => p_("Sounds", "Online user"),
      "user_sponsor" => p_("Sounds", "User being a sponsor"),
      "file_archive" => p_("Sounds", "Compressed file on a files tree"),
      "file_audio" => p_("Sounds", "Audio file on a files tree"),
      "file_dir" => p_("Sounds", "Directory on a files tree"),
      "file_document" => p_("Sounds", "Document on a files tree"),
      "file_text" => p_("Sounds", "Text file on a files tree"),
      "editbox_marker" => p_("Sounds", "Marker of an editbox in a form"),
      "editbox_textselected" => p_("Sounds", "A piece of text in an editbox has beenselected"),
      "editbox_textunselected" => p_("Sounds", "A piece of text in an editbox has been unselected"),
      "editbox_bigletter" => p_("Sounds", "Capitalized letter in an editbox"),
      "editbox_delete" => p_("Sounds", "Delete of a text in an editbox"),
      "editbox_endofline" => p_("Sounds", "End of line in an editbox"),
      "editbox_passwordchar" => p_("Sounds", "Password character in an editbox"),
      "editbox_space" => p_("Sounds", "Space in an editbox"),
      "button_marker" => p_("Sounds", "Marker of a button in a form"),
      "checkbox_marker" => p_("Sounds", "Marker of a checkbox in a form"),
      "login" => p_("Sounds", "User signed in or Elten window focused"),
      "logout" => p_("Sounds", "User signed out or Elten closed"),
      "minimize" => p_("Sounds", "Elten minimized into tray"),
      "messages_update" => p_("Sounds", "Messages window updated"),
      "new" => p_("Sounds", "New event"),
      "notification_birthday" => p_("Sounds", "Notification: birthday of a friend"),
      "notification_blogcomment" => p_("Sounds", "Notification: new comment on your blog"),
      "notification_blogfollower" => p_("Sounds", "Notification: new follower of your blog"),
      "notification_blogmention" => p_("Sounds", "Notification: new blog mention"),
      "notification_followedblog" => p_("Sounds", "Notification: new post on a followed blog"),
      "notification_followedblogpost" => p_("Sounds", "Notification: new comment to a followed blog post"),
      "notification_followedforum" => p_("Sounds", "Notification: new thread on a followed forum"),
      "notification_followedforumpost" => p_("Sounds", "Notification: new post on a followed forum"),
      "notification_followedthread" => p_("Sounds", "Notification: new post in a followed thread"),
      "notification_friend" => p_("Sounds", "Notification: new friend"),
      "notification_mention" => p_("Sounds", "Notification: new mention"),
      "notification_message" => p_("Sounds", "Notification: new message"),
      "conference_userjoin" => p_("Sounds", "New user joined conference"),
      "conference_userleave" => p_("Sounds", "User left conference"),
      "conference_message" => p_("Sounds", "New chat message"),
      "conference_whisper" => p_("Sounds", "Whisper in the conference"),
      "conference_pushin" => p_("Sounds", "Push To Talk enabled in conferences"),
      "conference_pushout" => p_("Sounds", "Push To Talk disabled in conferences"),
      "calling" => p_("Sounds", "Calling user"),
      "ringing" => p_("Sounds", "Incoming voice call"),
      "recording_start" => p_("Sounds", "Recording started"),
      "recording_stop" => p_("Sounds", "Recording stopped"),
      "recording_nearlimit" => p_("Sounds", "Only five seconds of recording left"),
      "right" => p_("Sounds", "Error"),
      "clock" => p_("Sounds", "Clock sound"),
      "alarm" => p_("Sounds", "Alarm Sound"),
      "waiting" => p_("Sounds", "Waiting for an action to be completed"),
      "signal" => p_("Sounds", "Signal")
    }
    if @file != nil
      if @file != ""
        @name = @theme.name
        @changed = false
      else
        @name = input_text(p_("Sounds", "Type name of the soundtheme"), 0, "by #{Session.name}", true)
        path = ""
        return $scene = Scene_SoundThemes.new if @name == nil
        @name = @name[0..255] if @name.size > 255
        n = @name.split(" ")
        ind = n.size
        for i in 0...n.size
          ind = i if n[i].downcase == "by"
        end
        for i in 0...n.size
          break if i == ind
          s = n[i]
          t = s.split("")[0].upcase + s.split("")[1..-1].join.downcase
          path += t
        end
        @file = Dirs.soundthemes + "\\" + path.delspecial + ".elsnd"
        @theme = SoundTheme.new(@name, @file)
        @changed = true
      end
    end
    @snd = []
    for file in @soundnames.keys.sort
      @snd.push(Struct_Sounds_Sound.new(file, @soundnames[file], @theme))
    end
    return $scene = Scene_Main.new if @snd.size == 0
    h = p_("Sounds", "Sounds guide, press space to play")
    h = p_("Sounds", "Editing sound theme %{theme}") % { "theme" => @name } if @theme != nil
    @sel = ListBox.new(@snd.map { |o| o.description }, h, 0, ListBox::Flags::Silent, true)
    @fields = [@sel, Button.new(p_("Sounds", "Play")), Button.new(p_("Sounds", "Stop"))]
    if @theme != nil
      @fields.push(Button.new(p_("Sounds", "Change")))
      @fields.push(Button.new(p_("Sounds", "Save")))
      @fields.push(Button.new(p_("Sounds", "Export"))) if @changed == false
    end
    @form = Form.new(@fields)
    a = nil
    loop do
      loop_update
      @form.update
      break if escape
      if (space and @form.index == 0) or @form.fields[1].pressed?
        a.close if a != nil
        snd = @snd[@sel.index].sound
        if snd != nil
          a = Bass::Sound.new(nil, 1, false, false, snd)
          a.volume = 0.01 * Configuration.volume
          a.play
        end
      end
      if @form.fields[2].pressed?
        if a != nil
          a.close
          a = nil
        end
      end
      if @theme != nil
        if (enter and @form.index == 0) or @form.fields[3].pressed?
          file = getfile(p_("Sounds", "Select new sound"), "", false, nil, [".ogg", ".mp3", ".wav", ".opus", ".aac", ".wma", ".m4a", ".flac", ".aiff", ".w64"])
          loop_update
          if file != nil
            snd = Bass::Sound.new(file, 1)
            if snd.length > 0 && snd.length < 300
              @snd[@sel.index].newfile = file
            else
              alert(p_("Sounds", "The sound must not last longer than 5 minutes"))
            end
            snd.close
            @form.fields[5] = nil
            @changed = true
          end
          @form.fields[@form.index].focus
        end
        if @form.fields[4].pressed?
          save
          @changed = false
          @form.fields[5] = Button.new(p_("Sounds", "Export"))
          @form.fields[@form.index].focus
        end
        if @form.fields[5] != nil and @form.fields[5].pressed?
          loc = getfile(p_("Sounds", "Where to save this theme"), Dirs.user + "\\", true, "Documents")
          if loc != nil
            compress(@theme.file, loc + "\\" + File.basename(@theme.file, ".elsnd") + ".zip")
          end
          @form.fields[@form.index].focus
        end
      end
    end
    if @changed and @theme != nil
      confirm(p_("Sounds", "Do you want to save this soundtheme?")) { save }
    end
    a.close if a != nil
    if @theme == nil
      $scene = Scene_Main.new
    else
      $scene = Scene_SoundThemes.new
    end
  end

  def save
    waiting
    magic = "EltenSoundThemePackageFileCMPSMC"
    cnt = ""
    for s in @snd
      snd = s.sound(true)
      next if snd == getsound(s.file, true)
      cnt += [s.file.size, s.file, snd.size, snd].pack("Ca*Ia*")
    end
    zcnt = Zlib::Deflate.deflate(cnt, Zlib::BEST_COMPRESSION)
    fcnt = [magic, Time.now.to_i, @theme.name.size, @theme.name, zcnt.size, zcnt].pack("a*QCa*Ia*")
    writefile(@file, fcnt)
    waiting_end
  end
end

class Struct_Sounds_Sound
  attr_reader :description, :file
  attr_accessor :newfile

  def initialize(f, d, t = nil)
    @description = d
    @file = f
    @newfile = nil
    @theme = t
  end

  def sound(mustVorbis = false)
    if @newfile == nil
      sound = nil
      sound = @theme.getsound(@file) if @theme != nil
      sound = getsound(@file, @theme != nil) if sound == nil
      sound
    else
      if mustVorbis == false || (File.extname(@newfile).downcase == ".ogg" && readfile(@newfile, 4) == "OggS")
        return readfile(@newfile)
      else
        return VorbisRecorder.get_encoded_file(@newfile)
      end
    end
  end
end
