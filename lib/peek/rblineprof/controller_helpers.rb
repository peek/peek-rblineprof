module Peek
  module Rblineprof
    module ControllerHelpers
      extend ActiveSupport::Concern

      included do
        around_filter :inject_rblineprof, :if => [:peek_enabled?, :rblineprof_enabled?]
      end

      protected

      def rblineprof_enabled?
        params[:lineprofiler].present?
      end

      def inject_rblineprof
        escaped_rails_root = Regexp.escape(Rails.root.to_s)
        regex = case params[:lineprofiler]
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

        ret = nil
        profile = lineprof(regex) do
          ret = yield
        end

        if response.content_type =~ %r|text/html|
          sort = params[:lineprofiler_sort]
          mode = params[:lineprofiler_mode]
          min  = (params[:lineprofiler_min] || 5).to_i * 1000
          summary = params[:lineprofiler_summary]

          per_file = profile.map do |file, lines|
            total, child, excl, total_cpu, child_cpu, excl_cpu = lines[0]

            wall = summary == 'exclusive' ? excl : total
            cpu  = summary == 'exclusive' ? excl_cpu : total_cpu
            idle = summary == 'exclusive' ? (excl-excl_cpu) : (total-total_cpu)

            [
              file, lines,
              wall, cpu, idle,
              sort == 'idle' ? idle : sort == 'cpu' ? cpu : wall
            ]
          end.sort_by{ |a,b,c,d,e,f| -f }

          output = ''
          per_file.each do |file_name, lines, file_wall, file_cpu, file_idle, file_sort|
            show_src = file_sort > min
            tmpl = show_src ? "<a href='#' class='js-lineprof-file'>%s</a>" : "%s"

            if mode == 'cpu'
              output << sprintf("% 8.1fms + % 8.1fms   #{tmpl}\n", file_cpu / 1000.0, file_idle / 1000.0, file_name.sub(Rails.root.to_s + '/', ''))
            else
              output << sprintf("% 8.1fms   #{tmpl}\n", file_wall/1000.0, file_name.sub(Rails.root.to_s + '/', ''))
            end

            next unless show_src

            File.readlines(file_name).each_with_index do |line, i|
              wall, cpu, calls = lines[i + 1]

              if calls && calls > 0
                if mode == 'cpu'
                  idle = wall - cpu
                  output << sprintf("% 8.1fms + % 8.1fms (% 5d) | %s", cpu / 1000.0, idle / 1000.0, calls, Rack::Utils.escape_html(line))
                else
                  output << sprintf("% 8.1fms (% 5d) | %s", wall / 1000.0, calls, Rack::Utils.escape_html(line))
                end
              else
                if mode == 'cpu'
                  output << sprintf("                                | %s", Rack::Utils.escape_html(line))
                else
                  output << sprintf("                   | %s", Rack::Utils.escape_html(line))
                end
              end
            end
          end

          response.body += "<div style='display: none' id='line-profile'><pre style='overflow-x: scroll'>#{output}</pre></div>".html_safe
        end

        ret
      end
    end
  end
end
