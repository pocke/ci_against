module CIAgainst
  class TravisYML
    def initialize(yaml_string)
      @nleol = yaml_string[-1] == "\n"
      @tree = parse(yaml_string)
      @lines = yaml_string.lines(chomp: true)
      @line_offest = @lines.map{0}
    end

    attr_reader :tree, :lines

    def insert_line(line, lineno)
      offset = @line_offest[0..lineno].sum
      @lines = [*lines[0...(lineno+offset)], line, *lines[(lineno+offset)..]]
      @line_offest[lineno] += 1
    end

    def replace_line(line, lineno)
      @lines[lineno] = line
    end

    def code
      res = @lines.join("\n")
      if @nleol
        res << "\n"
      end
      res
    end

    private

    def parse(yaml_string)
      Psych::Parser.new(Psych::TreeBuilder.new).parse(yaml_string).handler.root
    end
  end
end
