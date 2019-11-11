# frozen_string_literal: true

require_relative 'locale_file_walker'
require_relative 'yaml_tree_reader'
require 'yaml'

module TranslationsManager
  class DuplicateRemover
    def initialize(source_filename, target_filename)
      @source_filename = source_filename
      @target_filename = target_filename
    end

    def clean
      @source_yaml = YAML.load_file(@source_filename)
      target_tree_reader = YamlTreeReader.new(@target_filename)
      target_tree = target_tree_reader.read

      remove_duplicates(target_tree, [])
      target_tree_reader.to_yaml
    end

    def clean!
      write_yaml(clean, @target_filename)
    end

    protected

    def remove_duplicates(parent, keys)
      parent[:children].dup.each do |key, child|
        current_keys = Array.new(keys) << key
        remove_duplicates(child, current_keys)

        if child[:scalar] && child[:value] && duplicate_value?(current_keys, child[:value].value)
          parent[:children].delete(key)
          parent[:mapping].children.delete(child[:scalar])
          parent[:mapping].children.delete(child[:value])
        end
      end
    end

    def duplicate_value?(keys, value)
      source = @source_yaml.values.first

      keys.each do |key|
        return false if !source.is_a?(Hash)
        source = source[key]
      end

      return source == value
    end

    def write_yaml(yaml, filename)
      File.open(filename, 'w') do |file|
        file.write(yaml)
      end
    end
  end
end
