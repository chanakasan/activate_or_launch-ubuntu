require "csv"

module Aol
  App = Struct.new(:name, :launch_command, :wm_class)

  APPS_CSV_PATH = ENV['HOME'] + '/.config/activate_or_launch/apps.csv'
  APPS = []

  CSV.foreach(APPS_CSV_PATH) do |row|
    APPS << App.new(row[0], row[1], row[2])
  end

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
    APPS.find {|item| item.name == name}
  end

  def find_wmctrl_id(wm_class)
    debug "find_wmctrl_id: #{wm_class}"
    wmctrl_id=`wmctrl -x -l | grep "#{wm_class}" | awk '{ print $1; exit }'`
    debug "find_wmctrl_id result: #{wmctrl_id}"
    wmctrl_id
  end
end
