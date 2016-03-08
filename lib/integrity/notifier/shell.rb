require "byebug"
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
        @success_cmd = config["success_script"] + " -i succeeded  commit by: #{build.author}" #\ncommit: #{build.commit.message} id: #{}\ncommit made by: #{build.author}\n " 
        @failed_cmd = config["failed_script"] + " -i " + build_output.reverse[0..50].reverse
        #byebug
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
