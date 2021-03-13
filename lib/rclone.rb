# frozen_string_literal: true

module Nanoc
  module Deploying
    module Deployers
      class Rclone < ::Nanoc::Deploying::Deployer
        identifier :rclone

        DEFAULT_OPTIONS = [
          '--exclude',
          '.git/**/*',
          '--exclude',
          '.git/*',
          '--auto-confirm',
          '--verbose',
          '--ignore-times'
        ].freeze

        def run
          # Get params
          src = source_path + '/'
          dst = config.fetch(:dst)
          options = config.fetch(:options, DEFAULT_OPTIONS)

          # Validate
          raise 'No dst found in deployment configuration' if dst.nil?
          raise 'dst requires no trailing slash' if dst[-1, 1] == '/'

          # Copy stylesheets
          filter = ['--filter', '+ *.css', '--filter', '- *']
          if dry_run
            run_shell_cmd(['rclone', 'copy', '--dry-run', filter, options, src, dst].flatten)
          else
            run_shell_cmd(['rclone', 'copy', filter, options, src, dst].flatten)
          end

          # Sync
          if dry_run
            run_shell_cmd(['rclone', 'copy', '--dry-run', '--delete-after', options, src, dst].flatten)
          else
            run_shell_cmd(['rclone', 'copy', '--delete-after', options, src, dst].flatten)
          end
        end

        private

        def run_shell_cmd(cmd)
          TTY::Command.new.run(*cmd)
        end
      end
    end
  end
end
