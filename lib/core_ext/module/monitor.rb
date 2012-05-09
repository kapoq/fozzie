require 'fozzie/sniff'

class Module

  def _monitor
    self.class_eval { include Fozzie::Sniff }
    @_monitor_flag = true
  end

end