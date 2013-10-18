gem_group :development do
  gem 'awesome_print'
  gem 'hirb'
  gem 'pry-rails'
  gem 'pry-debugger'
  gem 'pry-vterm_aliases'
  gem 'pry-git'
  gem 'pry-doc'
  gem 'better_errors' unless yes?("API only app?")
end

file '~/.pryrc', <<-'CODE'
#######################################
# Pry Debugger                        #
#######################################
if defined?(PryDebugger)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
else
  puts "no pry-debugger :("  
end

#######################################
# Awesome Print                       #
#######################################
begin
  require 'awesome_print' 
  Pry.config.print = proc { |output, value| Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output) }
rescue LoadError => err
  puts "no awesome_print :("
end

########################################
# Hirb                                 #
########################################
begin
  require 'hirb'
rescue LoadError
  puts "no hirb :("
end
if defined? Hirb
  # Slightly dirty hack to fully support in-session Hirb.disable/enable toggling
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      @old_print = Pry.config.print
      Pry.config.print = proc do |output, value|
        Hirb::View.view_or_page_output(value) || @old_print.call(output, value)
      end
    end
    def disable_output_method
      Pry.config.print = @old_print
      @output_method = nil
    end
  end
  Hirb.enable
end
CODE
