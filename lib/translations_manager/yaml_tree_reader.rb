# frozen_string_literal: true

require_relative 'locale_file_walker'

module TranslationsManager
  class YamlTreeReader < LocaleFileWalker
    attr_reader :tree, :anchors

    def initialize(filename)
      @filename = filename
      @tree = { children: {} }
      @anchors = {}
    end

    def read
      @stream = parse_stream(@filename)
      handle_stream(@stream)
      @tree
    end

    def to_yaml
      @stream.to_yaml(nil, line_width: -1)
    end

    protected

    def handle_value(node, parents)
      super
      subtree(parents)[:value] = node
    end

    def handle_scalar(node, depth, parents)
      super
      subtree(parents)[:scalar] = node
    end

    def handle_mapping(node, depth, parents)
      super
      subtree(parents)[:mapping] = node
      @anchors[node.anchor] = node if node.anchor
    end

    def handle_alias(node, depth, parents)
      super
      subtree(parents)[:alias] = node
    end

    def subtree(parents)
      nodes = @tree

      parents.each do |p|
        nodes = nodes[:children]
        nodes[p] = { children: {} } unless nodes.key?(p)
        nodes = nodes[p]
      end

      nodes
    end
  end
end
