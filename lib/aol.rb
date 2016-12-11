require "pathname"

module Aol
  App = Struct.new(:launch_command, :wm_class)

  APPS = {
    chrome: App.new('google-chrome', 'google-chrome.google-chrome'),
    firefox: App.new('firefox', 'Navigator.Firefox'),
    terminal: App.new('gnome-terminal', 'gnome-terminal-server.Gnome-terminal'),
    desktop: App.new('wmctrl -k on'),
  }

  def debug(msg)
    puts "[DEBUG] #{msg}"
  end

  def aol_start(desktop_filename)
    app = find_app(desktop_filename)
    activate_or_launch(app)
  end

  def activate_or_launch(app)
    wm_class = app.wm_class
    launch_command = app.launch_command

    debug "WM_CLASS: #{wm_class}"
    debug "LAUNCH_COMMAND: #{launch_command}"

    if launch_command.to_s == ""
      debug "nothing to do"
      return
    end

    if wm_class.to_s == ""
      launch(launch_command)
    else
      wmctrl_id = find_wmctrl_id(wm_class)
      if wmctrl_id.to_s == ""
        debug "no existing window"
        launch(launch_command)
      else
        activate(wmctrl_id)
      end
    end
  end

  def launch(command)
    debug "launch: #{command}"
    `nohup #{command} &`
  end

  def activate(wmctrl_id)
    debug "activate: #{wmctrl_id}"
    `wmctrl -i -a #{wmctrl_id}`
  end

  def get_app_name(desktop_filename)
    File.basename(desktop_filename, ".*")
  end

  def find_app(desktop_filename)
    name = get_app_name(desktop_filename)
    APPS[name.to_sym]
  end

  def find_wmctrl_id(wm_class)
    debug "find_wmctrl_id: #{wm_class}"
    wmctrl_id=`wmctrl -x -l | grep "#{wm_class}" | awk '{ print $1; exit }'`
    debug "find_wmctrl_id result: #{wmctrl_id}"
    wmctrl_id
  end
end
