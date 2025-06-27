@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::NativeProject < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "project"

  def build : Nil
    fetch("project", "https://github.com/skinnyjames/hokusai-native/tarball/main", extension: ".tar.gz", strip: 1)

    emit("hello from native project task")
    emit_error("ahhh! real monsteres")
  end
end