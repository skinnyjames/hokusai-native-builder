@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::NativeImage < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "native-image"

  def ext
    macos? ? "bundle" : "so"
  end

  def shared_ext
    macos? ? "dylib" : "so"
  end

  def graalvm_home
    "#{config.directory}/graalvm/Contents/Home"
  end

  def build : Nil
    # run gradle native build
    command("gradle nativeCompile", env: env, chdir: "#{config.directory}/project")
    # sync c backend and include
    command("cp -rf #{config.directory}/project/include/*  #{native_compile_dir}")
    # compile c backend
    if macos?
      command("gcc -lhokusai-native hashmap.c #{config.directory}/raylib/libraylib.a hokusai-backend.c -L. -I. -framework CoreVideo -framework IOKit -framework Cocoa -framework GLUT -framework OpenGL -o hokusai-backend", chdir: native_compile_dir, env: env)
      command("install_name_tool -change #{native_compile_dir}/libhokusai-native.dylib libhokusai-native.dylib hokusai-backend", chdir: native_compile_dir)
    else
      command("patchelf --set-soname libhokusai-native.so #{native_compile_dir}/libhokusai-native.so")
      command("gcc -lhokusai-native hashmap.c #{config.directory}/raylib/libraylib.a hokusai-backend.c -L. -I. -o hokusai-backend", chdir: native_compile_dir, env: env)
    end

    # prepare for packaging
    mkdir("#{native_compile_dir}/build/truffle", parents: true)
    command("cp -Rf resources build/.", chdir: native_compile_dir)
    command("mv libhokusai-native.#{shared_ext} build/.", chdir: native_compile_dir)
    command("mv hokusai-backend build/.", chdir: native_compile_dir)
    command("mv test.rb build/.", chdir: native_compile_dir) # move hello world script
    command("rm -Rf build/resources/ruby", chdir: native_compile_dir)

    # sync truffle installation
    sync("#{config.directory}/truffleruby", "#{native_compile_dir}/build/truffle")
    # # package contents
    command("tar -czvf #{config.directory}/hokuasi-native.tar.gz -C #{native_compile_dir}/build --strip-components 1 .")
  end

  def native_compile_dir
    "#{config.directory}/project/build/native/nativeCompile"
  end

  def project_dir
    "#{config.directory}/project"
  end

  def env
    {
      "PATH" => "#{ENV["PATH"]}:#{config.directory}/gradle/bin",
      "HOKUSAI_RUBY_HOME" => "#{config.directory}/truffleruby",
      "JAVA_HOME" => macos? ? "#{config.directory}/graalvm/Contents/Home" : "#{config.directory}/graalvm",
      "GRAALVM_HOME" => macos? ? "#{config.directory}/graalvm/Contents/Home" : "#{config.directory}/graalvm"
    }
  end
end
