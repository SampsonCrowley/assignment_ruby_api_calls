require "github_api"
require 'figaro'

Figaro.application = Figaro::Application.new(
  path: File.expand_path("../../config/application.yml", __FILE__)
  )
Figaro.load

class GithubReader

  attr_reader :github, :user

  def initialize
    @github = Github.new(oauth_token: ENV['GITHUB_KEY'])

    sleep(0.5)

    @user = github.users.get.login

    sleep(0.5)
  end

  def fetch_repos
    puts "Fetching repos...\n\n"
    parse_repos(get_repos)
  end

  def pretty_print
    puts "\n\n"

    fetch_repos.each do |repo|
      puts
      puts "------------------------------------"
      puts repo[:name]
      puts "------------------------------------"
      puts
      repo[:commits].each do |commit|
        puts "\t" + commit[:message]
      end
    end

    puts "\n\n"
  end

  private

    def get_repos
      repos = github.repos.list

      sleep(0.5)

      repos.sort_by{ |k| k.created_at }
    end

    def parse_repos(repo_list)
      repo_list.map do |repo|
        commits = get_commits(repo.name)

        {
          name: repo.name,
          commits:commits
        }
      end
    end

    def get_commits(repo)
      commits = github.repos.commits.list(user, repo)

      sleep(0.5)

      commits = commits.map do |commit|
        {
          message: commit.commit.message,
          date: commit.commit.author.date
        }
      end.sort_by{ |k| k[:date] }

      commits
    end


end


