#!/usr/bin/env ruby

module Gui

  def self.run(title, file)
    system("open #{file}")
  end
end
