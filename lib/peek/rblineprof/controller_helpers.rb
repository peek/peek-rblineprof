begin
  require 'pygments.rb'
rescue LoadError
  # Doesn't have pygments.rb installed
end

module Peek
  module Rblineprof
    module ControllerHelpers
      extend ActiveSupport::Concern

      included do
        around_filter :inject_rblineprof, :if => [:peek_enabled?, :rblineprof_enabled?]
      end

      protected

      def pygmentize?
        defined?(Pygments)
      end

      def pygmentize(file_name, code, lexer = nil)
        if pygmentize? && lexer.present?
          Pygments.highlight(code, :lexer => lexer_for_filename(file_name))
        else
          code
        end
      end

      def rblineprof_enabled?
        params[:lineprofiler].present?
      end

      def lexer_for_filename(file_name)
        case file_name
        when /\.rb$/ then 'ruby'
        when /\.erb$/ then 'erb'
        end
      end

      def rblineprof_profiler_regex
        escaped_rails_root = Regexp.escape(Rails.root.to_s)
        case params[:lineprofiler]
        when 'app'
          %r{^#{escaped_rails_root}/(app|lib)}
        when 'views'
          %r{^#{escaped_rails_root}/app/view}
        when 'gems'
          %r|^#{escaped_rails_root}/vendor/gems|
        when 'all'
          %r|^#{escaped_rails_root}|
        when 'stdlib'
          %r|^#{Regexp.escape RbConfig::CONFIG['rubylibdir']}|
        else
          %r{^#{escaped_rails_root}/(app|config|lib|vendor/plugin)}
        end
      end

      def inject_rblineprof
        ret = nil
        profile = lineprof(rblineprof_profiler_regex) do
          ret = yield
        end

        if response.content_type =~ %r|text/html|
          sort = params[:lineprofiler_sort]
          mode = params[:lineprofiler_mode] || 'cpu'
          min  = (params[:lineprofiler_min] || 5).to_i * 1000
          summary = params[:lineprofiler_summary]

          # Sort each file by the longest calculated time
          per_file = profile.map do |file, lines|
            total, child, excl, total_cpu, child_cpu, excl_cpu = lines[0]

            wall = summary == 'exclusive' ? excl : total
            cpu  = summary == 'exclusive' ? excl_cpu : total_cpu
            idle = summary == 'exclusive' ? (excl - excl_cpu) : (total - total_cpu)

            [
              file, lines,
              wall, cpu, idle,
              sort == 'idle' ? idle : sort == 'cpu' ? cpu : wall
            ]
          end.sort_by{ |a,b,c,d,e,f| -f }

          output = ''
          per_file.each do |file_name, lines, file_wall, file_cpu, file_idle, file_sort|

            output << "<div class='peek-rblineprof-file'><div class='heading'>"

            show_src = file_sort > min
            tmpl = show_src ? "<a href='#' class='js-lineprof-file'>%s</a>" : "%s"

            if mode == 'cpu'
              output << sprintf("<span class='duration'>% 8.1fms + % 8.1fms</span> #{tmpl}\n", file_cpu / 1000.0, file_idle / 1000.0, file_name.sub(Rails.root.to_s + '/', ''))
            else
              output << sprintf("<span class='duration'>% 8.1fms</span> #{tmpl}\n", file_wall/1000.0, file_name.sub(Rails.root.to_s + '/', ''))
            end

            output << "</div>" # .heading

            next unless show_src

            output << "<div class='data'>"
            code = []
            times = []
            File.readlines(file_name).each_with_index do |line, i|
              code << line
              wall, cpu, calls = lines[i + 1]

              if calls && calls > 0
                if mode == 'cpu'
                  idle = wall - cpu
                  times << sprintf("% 8.1fms + % 8.1fms (% 5d)", cpu / 1000.0, idle / 1000.0, calls)
                else
                  times << sprintf("% 8.1fms (% 5d)", wall / 1000.0, calls)
                end
              else
                times << ' '
              end
            end
            output << "<pre class='duration'>#{times.join("\n")}</pre>"
            output << "<div class='code'>#{pygmentize(file_name, code.join, 'ruby')}</div>"
            output << "</div></div>" # .data then .peek-rblineprof-file
          end

          response.body += "<div class='peek-rblineprof-modal' id='line-profile'>#{output}</div>".html_safe
        end

        ret
      end
    end
  end
end
