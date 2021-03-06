module Integrity
  class Notifier
    class Shell < Notifier::Base
      def self.to_haml
        <<-HAML
%p.normal
  %label{ :for => "build_success" } On build success
  %input.text#build_success{                       |
    :name => "notifiers[Shell][success_script]",   |
    :type => "text",                               |
    :value => config["success_script"] || "" }     |
%p.normal
  %label{ :for => "build_failed" } On build fail
  %input.text#build_failed{                 |
    :name => "notifiers[Shell][failed_script]",    |
    :type => "text",                               |
    :value => config["failed_script"] ||  "" }     |
%p.normal
  %label{ :for => "shell_announce_success" } Notify on success?
  %input#shell_announce_success{                                |
    :name => "notifiers[Shell][announce_success]",              |
    :type => "checkbox",                                        |
    :checked => config['announce_success'], :value => "1" }     |
        HAML
      end

      def initialize(build, config={})
        super(build, config)
        @build = build       
        @output_link = "http://ci.boundlessdrop.com/#{build.project.name.downcase}/builds/#{build.id}/raw"
        @coverage = build.output.empty? ? "n/a" : build.output[-20..-1].split(" ")[-2..-1].join(" ")
        @success_cmd = config["success_script"] + " -i '#{build.project.name} build succeeded\nTest coverage: #{@coverage}\nCommit: #{build.commit.message}\nCommit id: #{build.commit.identifier}\nCommit by: #{build.author}' " 
        @failed_cmd = config["failed_script"] + " -i '#{build.project.name} build failed\nOutput: #{@output_link}\nCommit: #{build.commit.message}\nCommit id: #{build.commit.identifier}\nCommit by: #{build.author}'"
      end

      def deliver!
        @cmd = build.successful? ? @success_cmd : @failed_cmd
        `#{@cmd}`
      end

      private
        def announce_build?
          build.failed? || config["announce_success"]
        end
    end
  end
end
