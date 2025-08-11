@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::Raylib < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "raylib"

  def build : Nil
    fetch("raylib", "https://github.com/raysan5/raylib/archive/refs/tags/5.5.tar.gz")

    mkdir(build_dir, parents: true)
    command("make PLATFORM=PLATFORM_DESKTOP", chdir: build_dir)
    command("cp libraylib.a ../.", chdir: build_dir)
  end

  def build_dir : String
    File.join(config.directory, "raylib", "src")
  end
end