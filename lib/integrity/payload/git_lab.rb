module Integrity
  module Payload
    class GitLab < Base
      def deleted?
        @payload['after'] == '0000000000000000000000000000000000000000'
      end

      def uri
        @payload['repository']['ssh_url']
      end

      def name
        @payload['repository']['name']
      end
    end
  end
end
