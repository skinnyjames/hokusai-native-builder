@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::TruffleRuby < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "ruby"

  def build : Nil
    ensure_clang_script

    version = config.graalvm_version
    architecture = arm? ? "aarch64" : "amd64"
    os = macos? ? "macos" : "linux"

    fetch("truffleruby", "https://github.com/oracle/truffleruby/releases/download/graal-#{version}/truffleruby-community-#{version}-#{os}-#{architecture}.tar.gz")

    command("ls #{config.directory}/bin")
    command("which gcc", env: env)

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