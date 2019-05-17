module CIAgainst
  class Converter
    LATEST_RUBIES = %w[
      2.6.3
      2.5.5
      2.4.6
      2.3.8
      2.2.10
      2.1.10
    ]
    VERSION_REGEXP = /\d+\.\d+\.\d+/

    attr_reader :log

    def initialize(yml_string)
      @yml = TravisYML.new(yml_string)
      @log = {
        changed: [],
        added: [],
      }
    end

    def convert
      update_to_latest_rubies
      insert_new_rubies
      @yml.code
    end

    private

    attr_reader :yml

    def update_to_latest_rubies
      rvm = find_rvm(yml.tree)
      case rvm
      when Psych::Nodes::Sequence
        return unless rvm.style == Psych::Nodes::Sequence::BLOCK
        rvm.children.each do |child|
          update_to_latest_ruby(child) if child.is_a?(Psych::Nodes::Scalar)
        end
      when Psych::Nodes::Scalar
        update_to_latest_ruby(rvm)
      end
    end

    def update_to_latest_ruby(scalar)
      version = scalar.value
      return unless version.match?(VERSION_REGEXP)
      latest_version = LATEST_RUBIES.find{|v| v.start_with?(minor_version(version))}
      return unless latest_version
      return if latest_version == version
      return unless scalar.start_line == scalar.end_line

      yml.replace_line(yml.lines[scalar.start_line].sub(version, latest_version), scalar.start_line)
      log[:changed] << {from: version, to: latest_version}
    end

    def insert_new_rubies
      rvm = find_rvm(yml.tree)
      case rvm
      when Psych::Nodes::Sequence
        return unless rvm.style == Psych::Nodes::Sequence::BLOCK
        biggest_version_node = rvm
          .children
          .select{|node| node.is_a?(Psych::Nodes::Scalar) && node.value.match?(VERSION_REGEXP)}
          .max_by{|scalar| Gem::Version.new(scalar.value)}
        return unless biggest_version_node
        minor_version = Gem::Version.new(minor_version(biggest_version_node.value))

        line_base = yml.lines[biggest_version_node.start_line]
        LATEST_RUBIES
          .select{|v| Gem::Version.new(minor_version(v)) > minor_version}
          .reverse
          .each do |v|
            yml.insert_line(line_base.sub(VERSION_REGEXP, v), biggest_version_node.start_line + 1)
            log[:added] << v
          end
      else
        # Do nothing, because if other than sequence is specified as rvm, it cannot insert new version.
      end
    end

    def find_rvm(stream)
      return unless stream.is_a?(Psych::Nodes::Stream)
      doc = stream.children.first
      return unless doc.is_a?(Psych::Nodes::Document)
      mapping = doc.children.first
      return unless mapping.is_a?(Psych::Nodes::Mapping)

      mapping.children.each_slice(2) do |key, value|
        return value if key.value == 'rvm'
      end
      return nil
    end


    def minor_version(version)
      version.split('.')[0..1].join('.')
    end
  end
end
