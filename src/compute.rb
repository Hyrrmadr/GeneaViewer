#!/usr/bin/env ruby

require 'graphviz'
require 'genea'

require_relative 'gui'

module Compute
  @@temp_file = "output.png"

  def self.parse_graph file
    Genea.parse(file)
  end

  def self.display_dot(title, graph)
    g = GraphViz.new(title, :type => :graph)

    self.add_nodes(g, graph)
    self.add_links(g, graph)

    g.output(:png => @@temp_file)

    Gui.run(title, @@temp_file)

    #File.delete @@temp_file
  end

  private

  def self.add_nodes(g, graph)
    graph.people.each do |id,person|
      name = self.gen_label(person.name, person.birthday, person.deathday, person.alive)
      color = self.gen_color(person.sex)
      shape = self.gen_shape(person.sex)

      options = {:label => name, :color => color, :shape => shape}

      if person.deathday != nil or not person.alive
        options[:fillcolor] = :grey92
        options[:style] = :filled
      end

      g.add_node(id, options)
    end
  end

  def self.add_links(g, graph)

    graph.families.each do |family|
      name1 = ""
      if family.parent1 == nil
        name1 = "family-spouse1-#{family.hash}"
        g.add_node(name1, {:label => self.gen_label("???", nil, nil, false), :color => self.gen_spouse_color(family, :parent1), :shape => self.gen_spouse_shape(family, :parent1)})
      else
        name1 = family.parent1.id
      end

      name2 = ""
      if family.parent2 == nil
        name2 = "family-spouse2-#{family.hash}"
        g.add_node(name2, {:label => self.gen_label("???", nil, nil, false), :color => self.gen_spouse_color(family, :parent2), :shape => self.gen_spouse_shape(family, :parent2)})
      else
        name2 = family.parent2.id
      end

      node_id = "family-node1-#{family.hash}"
      g.add_node(node_id, {:label => self.gen_label_family(family.type, family.begin, family.end), :color => self.gen_color_family(family.type, family.end), :shape => :diamond, :style => :filled})
      node = g.find_node(node_id)

      # cluster_parents = g.add_graph("family-parents-#{family.hash}", {:rank => :same})
      g.add_edges(g.find_node(name1), node)
      g.add_edges(g.find_node(name2), node)
      # cluster_parents.add_edges(g.find_node(name1), node)
      # cluster_parents.add_edges(node, g.find_node(name2))

      if family.issues.size > 1
        # prev_edge = nil
        # middle_node = nil
        # cluster_iedges = g.add_graph("family-iedges-#{family.hash}", {:rank => :same})
        node_id = "family-middlenode-#{family.hash}"
        middle_node = node_edge = g.add_node(node_id, {:shape => :point, :height => 0.01, :width => 0.01})

        family.issues.each_with_index do |child, i|
          # node_id = "family-node-#{family.hash}-#{child.hash}"
          # node_edge = g.add_node(node_id, {:shape => :point, :height => 0.01, :width => 0.01})
          # if prev_edge != nil
          #   cluster_iedges.add_edges(prev_edge, node_edge)
          # end

          # if family.issues.size % 2 != 0
          #   if (i + 1) * 2 - 1 == family.issues.size
          #     middle_node = node_edge
          #   end
          # else
          #   if family.issues.size == i * 2
          #     middle_node = node_edge
          #     node_id = "family-middlenode-#{family.hash}"
          #     node_edge = g.add_node(node_id, {:shape => :point, :height => 0.01, :width => 0.01})
          #     cluster_iedges.add_edges(middle_node, node_edge)
          #   end
          # end

          g.add_edges(middle_node, g.find_node(child.id))
          # g.add_edges(node_edge, g.find_node(child.id))
          # prev_edge = node_edge
        end

        g.add_edges(node, middle_node)
      elsif not family.issues.empty?
        g.add_edges(node, g.find_node(family.issues[0].id))
      end
    end
  end

  def self.gen_label(name, birthday, deathday, alive)
    label = name + '\n'
    label += "* " + (birthday != nil ? birthday.to_s : "???")
    if not alive
      label += '\n' + "+ " + (deathday != nil ? deathday.to_s : "???")
    end
    label
  end

  def self.gen_color(sex)
    if sex == :male
      color = :blue
    elsif sex == :female
      color = :pink
    else
      color = :grey
    end
    color
  end

  def self.gen_shape(sex)
    if sex == :male
      shape = :box
    elsif sex == :female
      shape = :ellipse
    else
      shape = :octagon
    end
    shape
  end

  def self.gen_label_family(type, bdate, edate)
    if type == :wedding
      bsymbol = "oo "
      esymbol = "o/o"
      label = "Wedding" + '\n'
    elsif type == :illegitimate
      bsymbol = "(oo) "
      esymbol = "(o-o)"
      label = "Illegitimate" + '\n'
    else
      bsymbol = "o-o "
      esymbol = "o-/o"
      label = "Relationship" + '\n'
    end
    label = ""
    label += bsymbol + " " + (bdate != nil ? bdate.to_s : "???") + '\n'
    if edate != nil
      label += esymbol + " " + edate.to_s
    end
    label
  end

  def self.gen_color_family(type, edate)
    if edate != nil
      color = :red
    elsif type == :wedding
      color = :gold
    elsif type == :illegitimate
      color = :brown
    else
      color = :gray
    end
    color
  end

  def self.gen_spouse_color(family, spouse)
    if spouse == :parent1
      ospouse = family.parent2
    else
      ospouse = family.parent1
    end
    osex = ospouse != nil ? ospouse.sex : :unknown
    if osex == :male
      sex = :female
    elsif osex == :female
      sex = :male
    else
      sex = osex
    end
    gen_color(sex)
  end

  def self.gen_spouse_shape(family, spouse)
    if spouse == :parent1
      ospouse = family.parent2
    else
      ospouse = family.parent1
    end
    osex = ospouse != nil ? ospouse.sex : :unknown
    if osex == :male
      sex = :female
    elsif osex == :female
      sex = :male
    else
      sex = osex
    end
    gen_shape(sex)
  end
end
