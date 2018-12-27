module CIAgainst
  class Runner
    # repo: owner/repo
    def initialize(repo)
      @repo = repo
    end

    def run(dry_run:)
      begin
        content = Base64.decode64(octokit.contents(@repo, path: '.travis.yml').content)
      rescue Octokit::NotFound
        log ".travis.yml does not exist in #{@repo}"
        return
      end
      if exist_file?('.ruby-version')
        log ".ruby-version exists in #{@repo}. So skipped." 
        return
      end
      new_content = Converter.new(content).convert
      if new_content == content
        log "No difference. Skipped"
        return
      end

      if dry_run
        display_diff(content, new_content)
      else
        create_pull_request(new_content)
      end
    end

    private

    def display_diff(content, new_content)
      # TODO: Do not use git-diff
      Tempfile.open('ci-against') do |f1|
        Tempfile.open('ci-against') do |f2|
          f1.write(content)
          f1.flush
          f2.write(new_content)
          f2.flush
          system('git', 'diff', '--no-index', f1.path, f2.path)
        end
      end
    end

    def create_pull_request(new_content)
      octokit.create_blob(@repo, new_content)
    end

    def exist_file?(path)
      octokit.contents(@repo, path: path)
      true
    rescue Octokit::NotFound
      false
    end

    def octokit
      @octokit ||= Octokit::Client.new(access_token: ENV.fetch('GITHUB_ACCESS_TOKEN'))
    end

    # TODO: use logger
    def log(msg)
      puts msg
    end
  end
end
