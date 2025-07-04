@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::NativeImage < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "native-image"

  def ensure_standalone_libssl
    raise "Need to run setup - openssl.so not found" unless File.exists?(openssl_path)
  end

  def ext
    macos? ? "bundle" : "so"
  end

  # def openssl_path
  #   "#{config.directory}/truffleruby/src/main/c/openssl/openssl.#{ext}"
  # end

  # def target_openssl_path
  #   "#{config.directory}/project/build/native/nativeCompile/resources/ruby/ruby-home/lib/mri"
  # end

  # def libpath
  #   "#{config.directory}/project/build/native/nativeCompile/hokusai-native.so"
  # end

  # def generate_queries
  #   mkdir("#{ndk_path}/sysroot/usr/include/asm", parents: true)
  #   sync("#{ndk_path}/sysroot/usr/include/aarch64-linux-android/asm", "#{ndk_path}/sysroot/usr/include/asm")

  #   # command("gradle clean", env: env, chdir: "#{config.directory}/project")
  #   # generate the queries
  #   # command("gradle --settings-file=query-code.gradle nativeCompile", env: env, chdir: "#{config.directory}/project")

  #   Dir.children(query_dir).each do |file|
  #     env["LIBRARY_PATH"] = ""
  #     env["LD_LIBRARY_PATH"] = ""
  #     command("gcc #{file} #{includes_paths} -o generate && chmod 775 generate && ./generate > ../cap/#{file.gsub(/c$/, "cap")}", env: env, chdir: query_dir)
  #   end
  # end

  # def includes_paths
  #   "-I#{ndk_path}/sysroot/usr/include -I#{graalvm_home}/lib/svm/macros/truffle-svm/builder/include"
  # end

  def graalvm_home
    "#{config.directory}/graalvm/Contents/Home"
  end

  def build : Nil
    # command("ls #{android_home}/ndk/#{ndk_version}/toolchains/llvm/prebuilt/")
    # ensure_clang_script

    # generate_queries

    # # run gradle native build
    command("gradle nativeCompile", env: env, chdir: "#{config.directory}/project")
    command("cp #{config.directory}/project/tmp/*/libhokusai-native.o ##{config.directory}/project/build/native/nativeCompile/.")
    # # copy openssl.so
    # copy(openssl_path, target_openssl_path)

    mkdir("#{config.directory}/project/build/native/nativeCompile/truffle", parents: true)
    # # sync truffle installation
    sync("#{config.directory}/truffleruby", "#{config.directory}/project/build/native/nativeCompile/truffle")
    # # package contents
    command("tar -czvf #{config.directory}/package.tar.gz #{config.directory}/project/build/native/nativeCompile")
  end

  # def resource_dir
  #   "#{config.directory}/project/build-resources"
  # end

  # def cap_dir
  #   "#{resource_dir}/cap"
  # end

  # def query_dir
  #   "#{resource_dir}/query"
  # end

  # def generate_queries_command
  #   String.build do |io|
  #     io.print native_image_cmd
  #     io.print " -Dhokusai.ext=#{project_dir}/include/hokusai-native-ext.h"
  #     add_query_args(io)
  #     add_android_args(io)
  #     add_config_args(io)
  #     io.print " -H:+ExitAfterQueryCodeGeneration"
  #   end
  # end

  # def add_query_args(io)
  #   io.print " -H:QueryCodeDir=#{project_dir}/build-resources/query"
  #   io.print " -H:-UseCAPCache -H:+QueryIfNotInCAPCache"
  # end

  # def add_android_args(io)
  #   io.print " --native-compiler-path=#{config.directory}/bin/clang -H:-CheckToolchain"
  #   io.print " -Dsvm.targetName=android -Dsvm.targetArch=arm64"
  #   io.print " -Dsvm.platform=org.graalvm.nativeimage.Platform\$ANDROID_AARCH64"
  # end

  # def add_config_args(io)
  #   io.print " -H:IncludeResources=META-INF"
  #   io.print "-H:DynamicProxyConfigurationFiles=#{project_dir}/META-INF/native-image/proxy-config.json"
  #   io.print " -H:ReflectionConfigurationFiles=${projectDir}/META-INF/native-image/reflect-config.json"
  # end

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
