#!/usr/bin/env ruby

require_relative 'compute'

module Main
  @@bin = "genea-viewer"

  def self.usage
    $stderr.puts "Usage: #{@@bin} file"
    return false
  end

  def self.show_error err
      $stderr.puts "#{@@bin}: error: #{err}"
  end

  def self.parse_args(args)
    file = nil

    len = args.length
    i = 0
    while i < len
      if args[i] == '-h'
          exit usage
      else
          file = args[i]
      end
      i += 1
    end
    if file == nil
        show_error "Missing file argument"
        exit usage
    end
    return file
  end

  def self.run(args)
    begin
      file = parse_args(args)

      graph = Compute.parse_graph file

      Compute.display_dot(@@bin, graph)

    # rescue StandardError => info
    rescue SecurityError => info
      puts "#{@@bin}: #{info}"
      return false
    end
    return true
  end

end
