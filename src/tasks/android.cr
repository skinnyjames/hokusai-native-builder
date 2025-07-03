@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::Android < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "android"

  dependency Graalvm

  getter :config

  def ndk_version
    "29.0.13113456"
  end

  def build : Nil
    mkdir(android_home, parents: true)
    # Install android cli
    fetch("android-tools", "https://file.skinnyjames.net/cmdline-tools-#{macos? ? "mac" : "linux"}.tar.gz")
    
    # install android platform tools
    install("platforms;android-35")
    # install ndk
    install("ndk;#{ndk_version}")
  end

  def install(tool)
    command("echo y | #{sdkmanager} --sdk_root=#{android_home} \"#{tool}\"", env: env)
  end

  def sdkmanager
    "#{config.directory}/android-tools/bin/sdkmanager"
  end

  def env
    {
      "ANDROID_HOME" => android_home,
      "HOKUSAI_RUBY_HOME" => "#{config.directory}/truffleruby",
      "JAVA_HOME" => macos? ? "#{config.directory}/graalvm/Contents/Home" : "#{config.directory}/graalvm",
      "GRAALVM_HOME" => macos? ? "#{config.directory}/graalvm/Contents/Home" : "#{config.directory}/graalvm"
    }
  end
end