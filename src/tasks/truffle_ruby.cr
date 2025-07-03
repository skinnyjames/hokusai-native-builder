@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::TruffleRuby < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "ruby"

  dependency Android

  def arm?
    case ENV["RUNNER_ARCH"]?
    when .nil?
      false
    when "x64"
      false
    else
      true
    end
  end

  def build : Nil
    version = config.graalvm_version
    architecture = arm? ? "aarch64" : "amd64"
    os = macos? ? "macos" : "linux"

    fetch("truffleruby", "https://github.com/oracle/truffleruby/releases/download/graal-#{version}/truffleruby-community-#{version}-#{os}-#{architecture}.tar.gz")

    command(after_script, env: env)
  end

  def after_script
    "#{config.directory}/truffleruby/lib/truffle/post_install_hook.sh"
  end
  
  def env
    {
      "PATH" => "#{config.directory}/bin:#{ENV["PATH"]}"
    }
  end
end