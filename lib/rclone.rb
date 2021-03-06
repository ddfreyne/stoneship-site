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
          '--auto-confirm'
        ].freeze

        def run
          # Get params
          src = source_path + '/'
          dst = config.fetch(:dst)
          options = config.fetch(:options, DEFAULT_OPTIONS)

          # Validate
          raise 'No dst found in deployment configuration' if dst.nil?
          raise 'dst requires no trailing slash' if dst[-1, 1] == '/'

          # Run
          if dry_run
            warn 'Performing a dry-run; no actions will actually be performed'
            run_shell_cmd(['rclone', 'sync', '--dry-run', options, src, dst].flatten)
          else
            run_shell_cmd(['rclone', 'sync', options, src, dst].flatten)
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
