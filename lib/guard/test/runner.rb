module Guard
  class Test
    module Runner
      class << self
        attr_reader :test_unit_runner
        
        AVAILABLE_TEST_UNIT_RUNNERS = %w[default fastfail]
        
        def set_test_unit_runner(options = {})
          @test_unit_runner = AVAILABLE_TEST_UNIT_RUNNERS.include?(options[:runner]) ? options[:runner] : 'default'
        end
        
        def run(paths, options = {})
          message = "\n" + (options[:message] || "Running (#{@test_unit_runner} runner): #{paths.join(' ') }")
          UI.info(message, :reset => true)
          system(test_unit_command(paths, options))
        end
        
      private
        
        def test_unit_command(files, options = {})
          cmd_parts = []

            cmd_parts << "rvm #{options[:rvm].join(',')} exec" if options[:rvm].is_a?(Array)
            cmd_parts << "bundle exec" if bundler? && options[:bundler] != false
            cmd_parts << "ruby -rubygems"
            cmd_parts << "-r#{File.dirname(__FILE__)}/runners/#{@test_unit_runner}_test_unit_runner"
            cmd_parts << "-Itest"

          if Gem.available?('spork-testunit') && Gem.available?('guard-spork')
            cmd_parts << Gem.bin_path('spork-testunit')
            cmd_parts << files.join(' ')
          else
            cmd_parts << "-e \"%w[#{files.join(' ')}].each { |f| load f }\""
            cmd_parts << files.map { |f| "\"#{f}\"" }.join(' ')
            cmd_parts << "--runner=guard-#{@test_unit_runner}"
          end
          cmd_parts.join(' ')
        end
        
        def bundler?
          @bundler ||= File.exist?("#{Dir.pwd}/Gemfile")
        end
        
      end
    end
  end
end
