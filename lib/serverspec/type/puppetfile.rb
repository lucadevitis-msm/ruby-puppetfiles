require 'puppetfiles'
module Serverspec
  module Type
    # Puppetfile type for serverspec
    class Puppetfile < File
      def content_as_puppetfile
        @content_as_puppetfile ||= Puppetfiles.load(@name)
      end
    end
  end
end
