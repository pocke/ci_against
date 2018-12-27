module CIAgainst
  class Runner
    # repo: owner/repo
    def initialize(repo, github_access_token:)
      @repo = repo
      @octokit = Octokit::Client.new(access_token: github_access_token)
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
      converter = Converter.new(content)
      new_content = converter.convert
      if new_content == content
        log "No difference. Skipped"
        return
      end

      if dry_run
        display_diff(content, new_content, log: converter.log)
      else
        create_pull_request(new_content, log: converter.log)
      end
    end

    private

    attr_reader :octokit

    def display_diff(content, new_content, log:)
      puts title(log)
      puts
      puts description(log)
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

    def create_pull_request(new_content, log:)
      repo = octokit.repository(@repo)
      base_branch = octokit.branch(@repo, repo.default_branch)

      blob = octokit.create_blob(@repo, new_content)
      tree = octokit.create_tree(@repo, [{
        path: '.travis.yml',
        mode: '100644',
        type: 'blob',
        sha: blob,
      }], base_tree: base_branch.commit.commit.tree.sha)
      commit = octokit.create_commit(@repo, title(log) + "\n\n" + description(log), tree.sha, base_branch.commit.sha)

      head_branch_name = "ci-against-#{SecureRandom.hex(6)}"
      octokit.create_ref(@repo, "refs/heads/#{head_branch_name}", commit.sha)

      pr = octokit.create_pull_request(@repo, base_branch.name, head_branch_name, title(log), description(log) + "\n----\n\n<sub>Opend by [CI Against](https://github.com/pocke/ci_against)</sub>")
      log "PR created: #{pr.html_url}"
    end

    def title(log)
      if log[:added].empty?
        ruby = log[:changed].size == 1 ? 'Ruby' : 'Rubies'
        "CI against new #{ruby}"
      else
        "CI against Ruby #{log[:added].join(" and ")}"
      end
    end

    def description(log)
      res = +''
      unless log[:added].empty?
        res << <<~END
          ## Added

          #{log[:added].map{|x| "* #{x}"}.join("\n")}
        END
      end

      unless log[:changed].empty?
        res << <<~END


          ## Changed

          #{log[:changed].map{|x| "* #{x[:from]} => #{x[:to]}"}.join("\n")}
        END
      end
      res
    end

    def exist_file?(path)
      octokit.contents(@repo, path: path)
      true
    rescue Octokit::NotFound
      false
    end

    # TODO: use logger
    def log(msg)
      puts msg
    end
  end
end
