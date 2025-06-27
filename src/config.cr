module Hokusai
  module Native
    enum JDKVersion
      JDK17 = 17
      JDK21 = 21
      JDK24 = 24
    end

    class Config
      getter :directory, :graalvm_version, :jdk_version

      def self.build
        config = new
        yield config
        config
      end

      def initialize
        @directory = Path[Dir.current].join("hokusai-native-build").to_s
        @graalvm_version = "24.0.1"
        @jdk_version = JDKVersion::JDK21
      end

      def set_directory(dir : String)
        @directory = dir

        self
      end

      def set_graalvm_version(version : String)
        @graalvm_version = version

        self
      end

      def set_jdk_version(version : Int32)
        @jdk_version = JDKVersion.new(version)

        self
      end
    end
  end
end