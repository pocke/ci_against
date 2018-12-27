module CIAgainst
  class CLI
    def initialize(argv)
      @argv = argv
      @params = {}
      @args = nil
    end

    def run
      parse_option
      if @params[:all]
        raise NotImplementedError
      else
        @args.each do |repo|
          Runner.new(repo).run(dry_run: @params[:'dry-run'])
        end
      end
      return 0
    end

    private

    def parse_option
      opt = OptionParser.new
      opt.on('-a', '--all')
      opt.on('--dry-run')

      @args = opt.parse(@argv, into: @params)
      raise "#{@args} is meaningless when --all option is passed" if @params[:all] && !@args.empty?
      raise "Please specify repository names or --all option" if !@params[:all] && @args.empty?
    end
  end
end
