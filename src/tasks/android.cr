# @[Barista::BelongsTo(Hokusai::Native::Builder)]
# class Hokusai::Native::Tasks::Android < Barista::Task
#   include_behavior Software

#   nametag "android"

#   getter :config

#   def build : Nil
#     command("#{gem} #{gem_command}", env: env)
#   end

#   def gem
#     "#{config.directory}/useNative"
#   end


#   def env
#     {
#       "HOKUSAI_RUBY_HOME" => "#{config.directory}/truffleruby",
#       "JAVA_HOME" => "#{config.directory}/graalvm/Contents/Home",
#       "GRAALVM_HOME" => "#{config.directory}/graalvm/Contents/Home"
#     }
#   end
# end